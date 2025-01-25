import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/menu.dart';
import '../services/api_service.dart';

class EditDataScreen extends StatefulWidget {
  final Menu menu;

  const EditDataScreen({super.key, required this.menu});

  @override
  _EditDataScreenState createState() => _EditDataScreenState();
}

class _EditDataScreenState extends State<EditDataScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  XFile? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu.name);
    _descriptionController =
        TextEditingController(text: widget.menu.description);
    _priceController =
        TextEditingController(text: widget.menu.price.toString());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submitEdit() async {
    if (_formKey.currentState!.validate()) {
      final success = await _apiService.updateMenu(
        id: widget.menu.id,
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imageFile: _selectedImage,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu berhasil diperbarui")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memperbarui menu")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String baseUrl = "https://api.megasatriahiciter.com/";
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Menu")),
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
                  : widget.menu.image.isNotEmpty
                      ? Image.network(baseUrl + widget.menu.image, height: 150)
                      : const Text("Belum ada gambar dipilih"),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pilih Gambar"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitEdit,
                child: const Text("Simpan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
