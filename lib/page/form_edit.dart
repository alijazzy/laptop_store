import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormEditScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> initialData;

  const FormEditScreen({
    super.key,
    required this.documentId,
    required this.initialData,
  });

  @override
  State<FormEditScreen> createState() => _FormEditScreenState();
}

class _FormEditScreenState extends State<FormEditScreen> {
  late TextEditingController brandController;
  late TextEditingController deskripsiController;
  late TextEditingController fotoLaptopController;
  late TextEditingController hargaController;
  late TextEditingController namaLaptopController;
  late TextEditingController stokController;

  @override
  void initState() {
    super.initState();

    brandController = TextEditingController(text: widget.initialData['Brand']);
    deskripsiController =
        TextEditingController(text: widget.initialData['Deskripsi']);
    fotoLaptopController =
        TextEditingController(text: widget.initialData['Foto_Laptop']);
    hargaController =
        TextEditingController(text: widget.initialData['Harga']?.toString());
    namaLaptopController =
        TextEditingController(text: widget.initialData['Nama_Laptop']);
    stokController =
        TextEditingController(text: widget.initialData['Stok']?.toString());
  }

  @override
  void dispose() {
    brandController.dispose();
    deskripsiController.dispose();
    fotoLaptopController.dispose();
    hargaController.dispose();
    namaLaptopController.dispose();
    stokController.dispose();
    super.dispose();
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
          'Edit Laptop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: fotoLaptopController,
              decoration: const InputDecoration(
                labelText: 'Foto Laptop',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: namaLaptopController,
              decoration: const InputDecoration(
                labelText: 'Nama Laptop',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: stokController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stok',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool isDataChanged =
                    brandController.text != widget.initialData['Brand'] ||
                        deskripsiController.text !=
                            widget.initialData['Deskripsi'] ||
                        fotoLaptopController.text !=
                            widget.initialData['Foto_Laptop'] ||
                        hargaController.text !=
                            widget.initialData['Harga']?.toString() ||
                        namaLaptopController.text !=
                            widget.initialData['Nama_Laptop'] ||
                        stokController.text !=
                            widget.initialData['Stok']?.toString();

                if (isDataChanged) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('laptop')
                        .doc(widget.documentId)
                        .update({
                      'Brand': brandController.text,
                      'Deskripsi': deskripsiController.text,
                      'Foto_Laptop': fotoLaptopController.text,
                      'Harga': int.tryParse(hargaController.text) ?? 0,
                      'Nama_Laptop': namaLaptopController.text,
                      'Stok': int.tryParse(stokController.text) ?? 0,
                    });

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Success'),
                          content: const Text('Data Berhasil diperbarui'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text('Error: $e'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('No Changes'),
                        content: const Text('Tidak ada data yang diubah'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                textStyle: const TextStyle(fontSize: 16),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
