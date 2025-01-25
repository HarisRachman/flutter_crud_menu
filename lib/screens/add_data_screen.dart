import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedImage;

  final ApiService _apiService = ApiService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih gambar terlebih dahulu')),
        );
        return;
      }

      final success = await _apiService.addMenu(
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageFile: _selectedImage!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu berhasil ditambahkan")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan menu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Menu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nama Menu"),
                validator: (value) =>
                    value!.isEmpty ? "Nama menu wajib diisi" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                validator: (value) =>
                    value!.isEmpty ? "Deskripsi wajib diisi" : null,
              ),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Harga"),
                validator: (value) =>
                    value!.isEmpty ? "Harga wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              _selectedImage != null
                  ? Image.file(File(_selectedImage!.path), height: 150)
                  : const Text("Belum ada gambar dipilih"),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pilih Gambar"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
