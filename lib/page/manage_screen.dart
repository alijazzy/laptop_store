import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_store/page/form_add.dart';
import 'package:laptop_store/page/form_edit.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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

  Future<void> importData(BuildContext context) async {
    try {
      // Memilih file CSV
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      // Jika file dipilih dan tidak kosong
      if (result != null && result.files.isNotEmpty) {
        final fileBytes = result.files.single.bytes;

        // Membaca byte file CSV jika tersedia
        if (fileBytes != null) {
          // Mengonversi byte ke format CSV
          final csvData = CsvToListConverter()
              .convert(String.fromCharCodes(fileBytes), eol: '\n');

          // Kirim data ke callback untuk diperbarui di tampilan lain (optional)
          onlaptopImported(csvData.skip(1).toList());

          // Menambahkan data ke Firestore
          for (var row in csvData.skip(1)) {
            if (row.length >= 6) {
              try {
                // Memastikan nilai yang dikirim valid
                final brand = row[0]?.toString() ?? '';
                final deskripsi = row[1]?.toString() ?? '';
                final fotoLaptop = row[2]?.toString() ?? '';
                final harga = int.tryParse(row[3].toString()) ?? 0;
                final namaLaptop = row[4]?.toString() ?? '';
                final stok = int.tryParse(row[5].toString()) ?? 0;

                // Memastikan semua data yang diperlukan ada
                if (brand.isNotEmpty &&
                    deskripsi.isNotEmpty &&
                    namaLaptop.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('laptop').add({
                    'Brand': brand,
                    'Deskripsi': deskripsi,
                    'Foto_Laptop': fotoLaptop,
                    'Harga': harga,
                    'Nama_Laptop': namaLaptop,
                    'Stok': stok,
                  });

                  print("Document added successfully.");
                } else {
                  print("Skipping row due to missing required data.");
                }
              } catch (e) {
                print("Error adding document to Firestore: $e");
              }
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CSV file successfully imported!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to read file bytes!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected!')),
        );
      }
    } catch (e) {
      print("Error importing data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to import CSV file.')),
      );
    }
  }

  Future<void> exportDataToPDF() async {
    try {
      final pdf = pw.Document();
      final data = await FirebaseFirestore.instance.collection('laptop').get();

      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) {
            return [
              // Header laporan
              pw.Text(
                'Laptop Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16), // Spasi antar elemen
              // Daftar data laptop
              ...data.docs.map((doc) {
                final d = doc.data();
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ID: ${doc.id}',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Brand: ${d['Brand'] ?? '-'}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Deskripsi: ${d['Deskripsi'] ?? '-'}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Foto Laptop: ${d['Foto_Laptop'] ?? '-'}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Harga: ${d['Harga']?.toString() ?? '0'}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Nama Laptop: ${d['Nama_Laptop'] ?? '-'}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.Text(
                        'Stok: ${d['Stok']?.toString() ?? '0'}',
                        style: pw.TextStyle(fontSize: 14),
                      ),
                      pw.Divider(), // Garis pemisah antar data
                    ],
                  ),
                );
              }).toList(),
            ];
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'laptop-report.pdf',
      );
    } catch (e) {
      print("Error exporting PDF: $e");
    }
  }

  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Function to handle search query change
  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  // Function to handle editing a document
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

  // Function to handle deleting a document
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
              color: Colors.white, // Set the icon color to white
            ),
            onPressed: () {
              // Navigate to the form to add a new record
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormAddScreen()),
              );
            },
          ),
        ],
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
                          onPressed: () =>
                              widget.importData(context), // Corrected here
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Import CSV'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            backgroundColor: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: widget
                              .exportDataToPDF, // Update this to reference the function through widget.
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Export PDF'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(widget.collection)
                    .where('Nama_Laptop', isGreaterThanOrEqualTo: searchQuery)
                    .where('Nama_Laptop', isLessThan: searchQuery + 'z')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }

                  final data = snapshot.data!.docs;

                  return Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 50.0,
                        columns: const [
                          DataColumn(label: Text('Brand')),
                          DataColumn(label: Text('Deskripsi')),
                          DataColumn(label: Text('Foto Laptop')),
                          DataColumn(label: Text('Harga')),
                          DataColumn(label: Text('Nama Laptop')),
                          DataColumn(label: Text('Stok')),
                          DataColumn(label: Text('Actions')), // Action column
                        ],
                        rows: data.map((doc) {
                          final d = doc.data() as Map<String, dynamic>;
                          return DataRow(
                            cells: [
                              DataCell(Text(d['Brand'] ?? '')),
                              DataCell(Text(
                                _truncateDescription(d['Deskripsi'] ?? '', 5),
                              )),
                              DataCell(Text(d['Foto_Laptop'] ?? '')),
                              DataCell(Text(d['Harga']?.toString() ?? '0')),
                              DataCell(Text(d['Nama_Laptop'] ?? '')),
                              DataCell(Text(d['Stok']?.toString() ?? '0')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _editDocument(context, doc.id, d);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteDocument(context, doc.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _truncateDescription(String text, int maxWords) {
  final words = text.split(' '); // Pisahkan teks berdasarkan spasi (kata)
  if (words.length <= maxWords) {
    return text; // Jika jumlah kata lebih sedikit dari batas, kembalikan teks asli
  }
  return words.take(maxWords).join(' ') +
      ' dst....'; // Gabungkan 5 kata pertama dengan "dst."
}
