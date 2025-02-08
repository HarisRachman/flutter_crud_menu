import 'package:flutter/material.dart';
import 'add_data_screen.dart';
import 'detail_screen.dart';
import '../models/menu.dart';
import '../services/api_service.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  late Future<List<Menu>> _menusFuture;

  List<Menu> _allMenus = []; // Semua data menu
  List<Menu> _filteredMenus = []; // Data menu yang difilter

  @override
  void initState() {
    super.initState();
    _menusFuture =
        apiService.getMenus(); // Mendapatkan data menu saat pertama kali dimuat

    // Mendengarkan perubahan pencarian
    _searchSubject.stream.listen((query) {
      setState(() {
        if (query.isEmpty) {
          _filteredMenus = _allMenus;
        } else {
          _filteredMenus = _allMenus
              .where((menu) =>
                  menu.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      });
    });

    // Muat data menu saat pertama kali
    _menusFuture.then((menus) {
      setState(() {
        _allMenus = menus;
        _filteredMenus = menus;
      });
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _menusFuture = apiService.getMenus(); // Memuat ulang data
    });

    // Perbarui data setelah refresh
    final menus = await _menusFuture;
    setState(() {
      _allMenus = menus;
      _filteredMenus = menus;
    });
  }

  @override
  void dispose() {
    _searchSubject.close(); // Tutup stream saat widget dihancurkan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Makanan"),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) => _searchSubject.add(query),
              decoration: InputDecoration(
                hintText: "Cari menu...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: LiquidPullToRefresh(
        onRefresh: _refreshData,
        color: Colors.green[200],
        backgroundColor: Colors.green[900],
        showChildOpacityTransition: false,
        child: _filteredMenus.isEmpty
            ? const Center(child: Text("Tidak ada menu yang sesuai."))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(8),
                itemCount: _filteredMenus.length,
                itemBuilder: (context, index) {
                  final menu = _filteredMenus[index];
                  String baseUrl = "https://api.megasatriahiciter.com/";
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(menu: menu),
                        ),
                      );

                      // Jika berhasil menghapus data (result == true), refresh data
                      if (result == true) {
                        _refreshData();
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.green[100],
                      elevation: 4,
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                baseUrl + menu.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menu.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green[800],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Rp. ${NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 2).format(menu.price)}",
                                  style: TextStyle(
                                    color: Colors.green[900],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDataScreen()),
          );

          // Jika berhasil menambahkan data (result == true), refresh data
          if (result == true) {
            _refreshData();
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
