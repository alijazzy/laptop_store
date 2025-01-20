import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_store/page/homePage.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

import 'addProduct.dart';
import 'shoppingCartPage.dart';
import 'package:laptop_store/page/form_edit.dart';

class ManageScreen extends StatefulWidget {
  final String collection;
  final String title;
  final Function(List<List<dynamic>>) onlaptopImported;

  const ManageScreen({
    super.key,
    required this.collection,
    required this.title,
    required this.onlaptopImported,
  });

  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Fungsi untuk mengimpor data dari file CSV
  Future<void> importData(BuildContext context) async {
    print(
        "Import Data function called"); // Log untuk memastikan fungsi dipanggil
    try {
      // Memilih file CSV menggunakan FilePicker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, // Hanya file dengan tipe tertentu yang diizinkan
        allowedExtensions: ['csv'], // Ekstensi file yang diizinkan
      );

      if (result != null) {
        print(
            "File picked: ${result.files.single.name}"); // Menampilkan nama file yang dipilih
        final fileBytes =
            result.files.single.bytes; // Membaca byte dari file yang dipilih

        // Memastikan byte file berhasil dibaca
        if (fileBytes != null) {
          final csvData = CsvToListConverter().convert(
            String.fromCharCodes(fileBytes), // Mengonversi byte ke string
            eol: '\n', // Menentukan akhir baris sebagai pemisah
          );

          print("CSV Data: $csvData"); // Log data CSV untuk debugging

          // Mengirim data CSV ke callback untuk diperbarui di tampilan lain
          widget.onlaptopImported(csvData.skip(1).toList());

          // Memasukkan data CSV ke Firestore
          for (var row in csvData.skip(1)) {
            // Melewati header (baris pertama)
            if (row.length >= 6) {
              // Memastikan jumlah kolom mencukupi
              try {
                await FirebaseFirestore.instance.collection('laptop').add({
                  'Brand': row[0],
                  'Deskripsi': row[1],
                  'Foto_Laptop': row[2],
                  'Harga': int.tryParse(row[3].toString()) ??
                      0, // Konversi ke integer
                  'Nama_Laptop': row[4],
                  'Stok': int.tryParse(row[5].toString()) ??
                      0, // Konversi ke integer
                });
                print(
                    'Data added: ${row[0]}, ${row[4]}'); // Log data yang berhasil ditambahkan
              } catch (e) {
                print('Error adding data: $e'); // Log jika terjadi kesalahan
              }
            }
          }

          // Menampilkan dialog sukses impor
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Successful'),
              content: const Text('CSV file successfully imported!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Menampilkan dialog jika byte file gagal dibaca
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Failed'),
              content: const Text('Failed to read file bytes!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        print("No file selected"); // Log jika pengguna tidak memilih file
      }
    } catch (e) {
      print("Error importing data: $e"); // Log jika terjadi kesalahan
      // Menampilkan dialog jika terjadi kesalahan saat impor
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to import CSV file.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

// Fungsi untuk mengekspor data ke format PDF
  Future<void> exportDataToPDF() async {
    try {
      final pdf = pw.Document(); // Membuat dokumen PDF baru
      final data =
          await FirebaseFirestore.instance.collection(widget.collection).get();

      // Menambahkan font kustom
      final font = await PdfGoogleFonts.nunitoRegular();
      final boldFont = await PdfGoogleFonts.nunitoBold();

      // Menambahkan halaman ke PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape, // Format halaman horizontal
          build: (pw.Context context) {
            return [
              // Header laporan
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Laptop Report',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 24,
                  ),
                ),
              ),
              pw.SizedBox(height: 20), // Spasi kosong
              // Daftar data laptop
              pw.Column(
                children: data.docs.map((doc) {
                  final d = doc.data(); // Mengambil data dari dokumen
                  final deskripsi = d['Deskripsi'] ?? '';
                  final truncatedDeskripsi = deskripsi.length > 100
                      ? '${deskripsi.substring(0, 100)}...' // Memotong deskripsi panjang
                      : deskripsi;

                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 20),
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 1),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Menampilkan informasi laptop
                        pw.Text(
                          'Brand: ${d['Brand'] ?? ''}',
                          style: pw.TextStyle(
                            font: boldFont,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Deskripsi: ${truncatedDeskripsi}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Nama Laptop: ${d['Nama_Laptop'] ?? ''}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Harga: Rp. ${d['Harga'] ?? 0}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Stok: ${(d['Stok'] ?? 0).toString()}',
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ];
          },
        ),
      );

      // Membagikan PDF melalui aplikasi lain
      await Printing.sharePdf(
        bytes: await pdf.save(), // Menyimpan dokumen PDF
        filename:
            '${widget.collection}-report-${DateTime.now().toString()}.pdf', // Nama file PDF
      );
    } catch (e) {
      print("Error exporting PDF: $e"); // Log jika terjadi kesalahan ekspor
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  String formatRupiah(int price) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(price);
  }

  void _editDocument(
      BuildContext context, String docId, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FormEditScreen(documentId: docId, initialData: data),
      ),
    );
  }

  void _deleteDocument(BuildContext context, String docId) async {
    bool deleteConfirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Record'),
              content:
                  const Text('Are you sure you want to delete this record?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (deleteConfirmed) {
      await FirebaseFirestore.instance
          .collection(widget.collection)
          .doc(docId)
          .delete();

      // Menampilkan dialog untuk notifikasi
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Successful'),
          content: const Text('Record deleted successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/Logo/background.jpg',
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ],
        ),
        title: const Text(
          'Manage Screen',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddLaptopPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Logo/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/Logo/logo.png',
                  height: 50,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Shopping Cart'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const CartPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Manage Screen'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageScreen(
                      collection: 'laptop',
                      title: 'Manage Laptop Data',
                      onlaptopImported: (List<List<dynamic>> data) {},
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Data Laptop'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddLaptopPage()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushNamed(context, 'login_screen');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/Logo/background.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
              Container(
                height: 200,
                color: Colors.black.withOpacity(0.3),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Search by laptop name...",
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => importData(context),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Import CSV'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 40),
                        ElevatedButton.icon(
                          onPressed: exportDataToPDF,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Export PDF'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20, // Jarak dari bawah stack
                left: 16, // Jarak dari kiri
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('transaksi')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading total...',
                          style: TextStyle(color: Colors.white));
                    }

                    double totalTransaksi = 0;
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      totalTransaksi += (data['Total'] ?? 0);
                    }

                    return Text(
                      'Total Transaksi: Rp ${formatRupiah(totalTransaksi.toInt())}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Warna teks
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Laptop Data Table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(widget.collection)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No data available'));
                        }

                        final data = snapshot.data!.docs;

                        // Filter data based on search query
                        final filteredData = data.where((doc) {
                          final laptop = doc.data() as Map<String, dynamic>;
                          final searchString =
                              '${laptop['Nama_Laptop']} ${laptop['Brand']}'
                                  .toLowerCase();
                          return searchString.contains(searchQuery);
                        }).toList();

                        return DataTable(
                          columnSpacing: 50.0,
                          columns: const [
                            DataColumn(label: Text('Nama Laptop')),
                            DataColumn(label: Text('Brand')),
                            DataColumn(label: Text('Harga')),
                            DataColumn(label: Text('Stok')),
                            DataColumn(label: Text('Deskripsi')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: filteredData.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            final deskripsi = d['Deskripsi'] ?? '';
                            final truncatedDeskripsi = deskripsi.length > 50
                                ? '${deskripsi.substring(0, 50)}...'
                                : deskripsi;
                            return DataRow(
                              cells: [
                                DataCell(Text(d['Nama_Laptop'] ?? '')),
                                DataCell(Text(d['Brand'] ?? '')),
                                DataCell(Text(formatRupiah(d['Harga']))),
                                DataCell(Text(d['Stok']?.toString() ?? '0')),
                                DataCell(
                                  Tooltip(
                                    message: deskripsi,
                                    child: Text(truncatedDeskripsi),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _editDocument(context, doc.id, d),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            _deleteDocument(context, doc.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Data Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('transaksi')
                          .orderBy('tanggal_transaksi', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('No transaction data available'));
                        }

                        return DataTable(
                          columnSpacing: 50.0,
                          columns: const [
                            DataColumn(label: Text('Tanggal Transaksi')),
                            DataColumn(label: Text('Barang')),
                            DataColumn(label: Text('Total')),
                          ],
                          rows: snapshot.data!.docs.map((doc) {
                            final transaction =
                                doc.data() as Map<String, dynamic>;
                            final items =
                                transaction['Barang'] as List<dynamic>;
                            final itemsText = items.map((item) {
                              return '${item['Nama_Laptop']} (${item['Brand']}) x${item['Quantity']}';
                            }).join('\n');

                            return DataRow(
                              cells: [
                                DataCell(Text(
                                    transaction['tanggal_transaksi'] ?? '')),
                                DataCell(
                                  Tooltip(
                                    message: itemsText,
                                    child: Text(
                                      items.length > 1
                                          ? '${items.length} items'
                                          : itemsText,
                                    ),
                                  ),
                                ),
                                DataCell(transaction['Total'] != null
                                    ? Text(formatRupiah(transaction['Total']))
                                    : const Text('0')),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
