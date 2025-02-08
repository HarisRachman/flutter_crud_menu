import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import '../models/menu.dart';
import '../services/api_service.dart';
import 'edit_data_screen.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  final Menu menu;
  final ApiService apiService = ApiService();

  DetailScreen({super.key, required this.menu});

  // Fungsi untuk menghapus menu
  void _deleteMenu(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Menu"),
        content: const Text("Apakah Anda yakin ingin menghapus menu ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await apiService.deleteMenu(menu.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu berhasil dihapus")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus menu")),
        );
      }
    }
  }

  // Fungsi untuk membagikan menu
  void _shareMenu() {
    String baseUrl = "https://api.megasatriahiciter.com/";
    final shareText =
        "Cek menu favorit kami:\n\n${menu.name}\nHarga: Rp ${menu.price}\n${menu.description}\n\nGambar: ${baseUrl + menu.image}";

    Share.share(shareText, subject: "Bagikan Menu ${menu.name}");
  }

  // Fungsi untuk mengunduh dan menyimpan gambar ke galeri
  Future<void> _downloadImage(BuildContext context, String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/menu_image.jpg');
        await file.writeAsBytes(response.bodyBytes);

        // Simpan ke galeri
        await GallerySaver.saveImage(file.path);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gambar berhasil disimpan ke galeri")),
        );
      } else {
        throw Exception("Gagal mengunduh gambar");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Terjadi kesalahan saat mengunduh gambar")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String baseUrl = "https://api.megasatriahiciter.com/";

    return Scaffold(
      appBar: AppBar(title: Text(menu.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                baseUrl + menu.image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              menu.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              menu.description,
              style: TextStyle(fontSize: 16, color: Colors.green[600]),
            ),
            const SizedBox(height: 16),
            Text(
              "Rp. ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 2).format(menu.price)}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditDataScreen(menu: menu),
                      ),
                    );

                    if (result == true) {
                      Navigator.pop(context, true);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                ),
                ElevatedButton.icon(
                  onPressed: () => _deleteMenu(context),
                  icon: const Icon(Icons.delete),
                  label: const Text("Hapus"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _shareMenu,
                  icon: const Icon(Icons.share),
                  label: const Text("Bagikan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      _downloadImage(context, baseUrl + menu.image),
                  icon: const Icon(Icons.download),
                  label: const Text("Unduh Gambar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
