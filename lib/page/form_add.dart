import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormAddScreen extends StatefulWidget {
  const FormAddScreen({super.key});

  @override
  _FormAddScreenState createState() => _FormAddScreenState();
}

class _FormAddScreenState extends State<FormAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _laptopNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  // Function to add data to Firestore
  Future<void> addDataToFirestore() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance.collection('laptop').add({
          'Brand': _brandController.text,
          'Deskripsi': _descriptionController.text,
          'Foto_Laptop': _imageController.text,
          'Harga': int.tryParse(_priceController.text) ?? 0,
          'Nama_Laptop': _laptopNameController.text,
          'Stok': int.tryParse(_stockController.text) ?? 0,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data successfully added!')),
        );

        // Clear the form after submission
        _brandController.clear();
        _descriptionController.clear();
        _laptopNameController.clear();
        _priceController.clear();
        _stockController.clear();
        _imageController.clear();
      } catch (e) {
        print("Error adding data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add data!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Field
                _buildTextField(
                    _brandController, 'Brand', 'Please enter brand'),

                // Description Field
                _buildTextField(_descriptionController, 'Description',
                    'Please enter description'),

                // Laptop Name Field
                _buildTextField(_laptopNameController, 'Laptop Name',
                    'Please enter laptop name'),

                // Price Field
                _buildTextField(_priceController, 'Price', 'Please enter price',
                    keyboardType: TextInputType.number),

                // Stock Field
                _buildTextField(_stockController, 'Stock', 'Please enter stock',
                    keyboardType: TextInputType.number),

                // Image URL Field
                _buildTextField(
                    _imageController, 'Image URL', 'Please enter image URL'),

                const SizedBox(height: 20),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Add data to Firestore
                      await addDataToFirestore();

                      // Navigate back to the ManageScreen after adding the data
                      Navigator.pop(context);
                    },
                    child: const Text('Add Record'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          ),
          keyboardType: keyboardType,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return errorMessage;
            }
            return null;
          },
        ),
      ),
    );
  }
}
