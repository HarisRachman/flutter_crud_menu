import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/menu.dart';

class ApiService {
  // Gantilah dengan base URL yang sesuai
  final String _baseUrl = "https://api.megasatriahiciter.com/";

  // Mengambil daftar menu
  Future<List<Menu>> getMenus() async {
    final response = await http.get(Uri.parse("$_baseUrl"));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Menu.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load menus");
    }
  }

  // Menambahkan menu baru
  Future<bool> addMenu({
    required String name,
    required String description,
    required double price,
    required XFile imageFile,
  }) async {
    final request = http.MultipartRequest("POST", Uri.parse("$_baseUrl"))
      ..fields['name'] = name
      ..fields['description'] = description
      ..fields['price'] = price.toString()
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    return response.statusCode == 200;
  }

  // Mengupdate menu
  Future<bool> updateMenu({
    required int id,
    required String name,
    required String description,
    required double price,
    XFile? imageFile,
  }) async {
    final request = http.MultipartRequest("POST", Uri.parse("$_baseUrl"))
      ..fields['id'] = id.toString()
      ..fields['name'] = name
      ..fields['description'] = description
      ..fields['price'] = price.toString();

    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final response = await request.send();
    return response.statusCode == 200;
  }

  // Menghapus menu
  Future<bool> deleteMenu(int id) async {
    final response = await http.post(
      Uri.parse("$_baseUrl"), // Menggunakan POST untuk menghapus
      body: {'delete_id': id.toString()}, // Mengirim ID melalui body POST
    );

    if (response.statusCode == 200) {
      return true; // Berhasil menghapus
    } else {
      return false; // Gagal menghapus
    }
  }
}
