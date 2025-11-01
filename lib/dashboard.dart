import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> items = [
    {"nama": "Kopi Hitam", "jumlah": 10, "harga": 15000},
    {"nama": "Teh Botol", "jumlah": 20, "harga": 8000},
    {"nama": "Roti Bakar", "jumlah": 5, "harga": 12000},
  ];

  void _tambahBarang() {
    _showFormDialog();
  }

  void _editBarang(int index) {
    _showFormDialog(index: index, item: items[index]);
  }

  void _hapusBarang(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Barang"),
        content: Text(
          "Apakah kamu yakin ingin menghapus '${items[index]['nama']}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                items.removeAt(index);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Barang berhasil dihapus")),
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  void _showFormDialog({int? index, Map<String, dynamic>? item}) {
    final TextEditingController namaController = TextEditingController(
      text: item != null ? item['nama'] : '',
    );
    final TextEditingController jumlahController = TextEditingController(
      text: item != null ? item['jumlah'].toString() : '',
    );
    final TextEditingController hargaController = TextEditingController(
      text: item != null ? item['harga'].toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? "Tambah Barang" : "Edit Barang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama Barang"),
            ),
            TextField(
              controller: jumlahController,
              decoration: const InputDecoration(labelText: "Jumlah"),
              keyboardType: TextInputType.number,
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
            onPressed: () {
              final nama = namaController.text.trim();
              final jumlah = int.tryParse(jumlahController.text) ?? 0;
              final harga = int.tryParse(hargaController.text) ?? 0;

              if (nama.isNotEmpty && jumlah > 0 && harga > 0) {
                setState(() {
                  if (index == null) {
                    items.add({"nama": nama, "jumlah": jumlah, "harga": harga});
                  } else {
                    items[index] = {
                      "nama": nama,
                      "jumlah": jumlah,
                      "harga": harga,
                    };
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF016B61),
            ),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF016B61), Color(0xFF70B2B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dashboard Barang - Putu Gede 5E",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              item['nama'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              "Jumlah: ${item['jumlah']} | Harga: Rp${item['harga']}",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orangeAccent,
                                  ),
                                  onPressed: () => _editBarang(index),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _hapusBarang(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahBarang,
        backgroundColor: const Color(0xFF016B61),
        icon: const Icon(Icons.add),
        label: const Text(""),
      ),
    );
  }
}
