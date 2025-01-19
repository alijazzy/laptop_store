import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_store/page/form_add.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class ManageScreen extends StatefulWidget {
  final String collection;
  final String title;
  final Function(List<List<dynamic>>) onLaptopImported;

  const ManageScreen({
    super.key,
    required this.collection,
    required this.title,
    required this.onLaptopImported,
  });
  Future<void> importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result != null) {
        final fileBytes = result.files.single.bytes;
        if (fileBytes != null) {
          final csvData = CsvToListConverter()
              .convert(String.fromCharCodes(fileBytes), eol: '\n');

          // Kirim data ke callback untuk diperbarui di tampilan lain
          onLaptopImported(csvData.skip(1).toList());

          // Simpan data ke Firestore
          for (var row in csvData.skip(1)) {
            if (row.length >= 7) {
              await FirebaseFirestore.instance.collection(collection).add({
                'Brand': row[0],
                'Deskripsi': row[1],
                'Foto_Laptop': row[2],
                'Harga': int.tryParse(row[3].toString()) ?? 0,
                'Nama_Laptop': row[4],
                'Stok': int.tryParse(row[5].toString()) ?? 0,
              });
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CSV file successfully imported!')),
          );
        }
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
      final data =
          await FirebaseFirestore.instance.collection(collection).get();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('$title Report', style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: [
                    'ID',
                    'Brand',
                    'Deskripsi',
                    'Foto Laptop',
                    'Harga',
                    'Nama Laptop',
                    'Stok'
                  ],
                  data: data.docs.map((doc) {
                    final d = doc.data();
                    return [
                      doc.id,
                      d['Brand'] ?? '',
                      d['Deskripsi'] ?? '',
                      d['Foto_Laptop'] ?? '',
                      d['Harga']?.toString() ?? '0',
                      d['Nama_Laptop'] ?? '',
                      d['Stok']?.toString() ?? '',
                    ];
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '$collection-report.pdf',
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
        builder: (context) => EditScreen(docId: docId, data: data),
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
              'assets/background.jpg',
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
                'assets/background.jpg',
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

class EditScreen extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditScreen({super.key, required this.docId, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Record')),
      body: Center(
        child: Text('Implement Edit Functionality Here'),
      ),
    );
  }
}
