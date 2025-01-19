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

    // Mengisi field dengan data awal
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
    // Membersihkan controller
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
        title: const Text('Edit Laptop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: brandController,
              decoration: const InputDecoration(labelText: 'Brand'),
            ),
            TextField(
              controller: deskripsiController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),
            TextField(
              controller: fotoLaptopController,
              decoration: const InputDecoration(labelText: 'Foto Laptop'),
            ),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),
            TextField(
              controller: namaLaptopController,
              decoration: const InputDecoration(labelText: 'Nama Laptop'),
            ),
            TextField(
              controller: stokController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Update data di Firestore
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

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data updated successfully')),
                );
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
