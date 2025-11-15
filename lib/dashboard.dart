import 'package:flutter/material.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  final String _apiUrl = "http://127.0.0.1:8000/api/barang";

  // Sorting
  bool _sortByName = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// ---------------------------
  /// GET DATA DARI API
  /// ---------------------------
  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          items = List<Map<String, dynamic>>.from(data);
          _applySearchAndSort();
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = "Gagal memuat data. Status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Terjadi kesalahan: $e";
        _isLoading = false;
      });
    }
  }

  /// ---------------------------
  /// SEARCH DENGAN DEBOUNCE
  /// ---------------------------
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _applySearchAndSort();
    });
  }

  /// ---------------------------
  /// FILTER & SORT SEARCH
  /// ---------------------------
  void _applySearchAndSort() {
    final query = searchController.text.toLowerCase();

    filteredItems = items
        .where((item) => item['nama'].toString().toLowerCase().contains(query))
        .toList();

    if (_sortByName) {
      filteredItems.sort(
        (a, b) => a['nama'].toString().compareTo(b['nama'].toString()),
      );
    } else {
      filteredItems.sort(
        (a, b) => (a['harga'] as int).compareTo(b['harga'] as int),
      );
    }

    if (mounted) setState(() {});
  }

  /// ---------------------------
  /// POST / PUT / DELETE
  /// ---------------------------
  Future<void> _postBarang(String nama, int harga) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"nama": nama, "harga": harga}),
      );
      if (!mounted) return;
      if (response.statusCode == 201 || response.statusCode == 200) {
        _fetchData();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _updateBarang(int id, String nama, int harga) async {
    try {
      final response = await http.put(
        Uri.parse("$_apiUrl/$id"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"nama": nama, "harga": harga}),
      );
      if (!mounted) return;
      if (response.statusCode == 200) _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _deleteBarang(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$_apiUrl/$id"),
        headers: {'Accept': 'application/json'},
      );
      if (!mounted) return;
      if (response.statusCode == 200) _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  /// ---------------------------
  /// FORM TAMBAH / EDIT
  /// ---------------------------
  void _showFormDialog({Map<String, dynamic>? item}) {
    final TextEditingController namaController = TextEditingController(
      text: item != null ? item["nama"] : "",
    );
    final TextEditingController hargaController = TextEditingController(
      text: item != null ? item["harga"].toString() : "",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? "Tambah Barang" : "Edit Barang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama Barang"),
            ),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: "Harga"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () {
              final nama = namaController.text.trim();
              final harga = int.tryParse(hargaController.text) ?? 0;
              if (nama.isEmpty || harga <= 0) return;
              if (item == null) {
                _postBarang(nama, harga);
              } else {
                _updateBarang(item["id"], nama, harga);
              }
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  /// ---------------------------
  /// HAPUS DENGAN DIALOG
  /// ---------------------------
  void _hapusBarangDialog(int index) {
    final id = filteredItems[index]["id"];
    final nama = filteredItems[index]["nama"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Barang"),
        content: Text("Yakin ingin menghapus '$nama'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteBarang(id);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  /// ---------------------------
  /// UI TAMPILAN LIST BARANG
  /// ---------------------------
  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: "Cari barang...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              const Text("Sort by: "),
              DropdownButton<bool>(
                value: _sortByName,
                items: const [
                  DropdownMenuItem(value: true, child: Text("Nama")),
                  DropdownMenuItem(value: false, child: Text("Harga")),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _sortByName = value;
                    _applySearchAndSort();
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(item['nama']),
                  subtitle: Text("Rp ${item['harga']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showFormDialog(item: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusBarangDialog(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// ---------------------------
  /// HALAMAN UTAMA
  /// ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Barang"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }
}
