import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormAddScreen extends StatefulWidget {
  const FormAddScreen({super.key});

  @override
  _FormAddScreenState createState() => _FormAddScreenState();
}

class _FormAddScreenState extends State<FormAddScreen> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk form
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _laptopNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  // Fungsi untuk menambahkan data ke Firestore
  Future<void> addDataToFirestore() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Menambahkan data ke koleksi 'laptop' di Firestore
        await FirebaseFirestore.instance.collection('laptop').add({
          'Brand': _brandController.text,
          'Deskripsi': _descriptionController.text,
          'Foto_Laptop': _imageController.text,
          'Harga': int.tryParse(_priceController.text) ?? 0,
          'Nama_Laptop': _laptopNameController.text,
          'Stok': int.tryParse(_stockController.text) ?? 0,
        });

        // Menampilkan snackbar untuk sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil ditambahkan!')),
        );

        // Membersihkan form setelah data berhasil dikirim
        _brandController.clear();
        _descriptionController.clear();
        _laptopNameController.clear();
        _priceController.clear();
        _stockController.clear();
        _imageController.clear();
      } catch (e) {
        print("Error adding data: $e");
        // Menampilkan snackbar jika gagal menambahkan data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan data!')),
        );
      }
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
              'assets/Logo/background.jpg', // Gambar latar belakang
              fit: BoxFit.cover,
            ),
            Container(
              color:
                  Colors.black.withOpacity(0.4), // Transparansi di atas gambar
            ),
          ],
        ),
        title: const Text(
          'Form Add',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Menyambungkan form dengan _formKey
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field Brand
                _buildTextField(
                    _brandController, 'Brand', 'Mohon masukkan brand'),

                // Field Deskripsi
                _buildTextField(_descriptionController, 'Deskripsi',
                    'Mohon masukkan deskripsi'),

                // Field Nama Laptop
                _buildTextField(_laptopNameController, 'Nama Laptop',
                    'Mohon masukkan nama laptop'),

                // Field Harga
                _buildTextField(
                    _priceController, 'Harga', 'Mohon masukkan harga',
                    keyboardType: TextInputType.number),

                // Field Stok
                _buildTextField(_stockController, 'Stok', 'Mohon masukkan stok',
                    keyboardType: TextInputType.number),

                // Field URL Gambar
                _buildTextField(_imageController, 'URL Gambar',
                    'Mohon masukkan URL gambar'),

                const SizedBox(height: 20),

                // Tombol Submit
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Menambahkan data ke Firestore
                      await addDataToFirestore();

                      // Kembali ke halaman sebelumnya setelah data berhasil ditambahkan
                      Navigator.pop(context);
                    },
                    child: const Text('Tambah Data'),
                    style: ElevatedButton.styleFrom(
                      // Penataan tombol
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 24.0),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuat text field dengan validasi
  Widget _buildTextField(
      TextEditingController controller, String label, String errorMessage,
      {TextInputType keyboardType = TextInputType.text}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(
                Icons.text_fields), // Menambahkan ikon ke setiap field
          ),
          keyboardType: keyboardType,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return errorMessage; // Pesan error jika field kosong
            }
            return null;
          },
        ),
      ),
    );
  }
}
