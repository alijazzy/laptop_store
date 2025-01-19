import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddLaptopPage extends StatefulWidget {
  @override
  _AddLaptopPageState createState() => _AddLaptopPageState();
}

class _AddLaptopPageState extends State<AddLaptopPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stockController =
      TextEditingController(text: '0');
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _fotoPathController = TextEditingController();

  bool _isLoading = false;

  void _incrementStock() {
    final currentValue = int.tryParse(_stockController.text) ?? 0;
    _stockController.text = (currentValue + 1).toString();
  }

  void _decrementStock() {
    final currentValue = int.tryParse(_stockController.text) ?? 0;
    if (currentValue > 0) {
      _stockController.text = (currentValue - 1).toString();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('laptop').add({
        'Brand': _brandController.text,
        'Deskripsi': _deskripsiController.text,
        'Foto_Laptop': _fotoPathController.text,
        'Harga': int.tryParse(_hargaController.text) ?? 0,
        'Nama_Laptop': _namaController.text,
        'Stok': int.tryParse(_stockController.text) ?? 0,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laptop berhasil ditambahkan!')),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan, coba lagi nanti.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Laptop',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: _buildInputDecoration('Nama Laptop'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Laptop harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _brandController,
                  decoration: _buildInputDecoration('Brand Laptop'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Brand Laptop harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _hargaController,
                  decoration: _buildInputDecoration('Harga'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga harus diisi';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Harga harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: _buildInputDecoration('Stok').copyWith(
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _decrementStock,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _incrementStock,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Stok harus diisi';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Stok harus berupa angka';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _deskripsiController,
                  decoration: _buildInputDecoration('Deskripsi'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fotoPathController,
                  decoration: _buildInputDecoration('Path Foto').copyWith(
                    hintText: 'Contoh: FotoLaptop/namaLaptop.jpg',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Path Foto harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Submit'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
