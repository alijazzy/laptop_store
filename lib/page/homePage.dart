import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'manage_screen.dart'; // Import halaman Manage Screen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  String selectedBrand = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        flexibleSpace: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ],
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Manage Screen'),
              onTap: () {
                // Navigate to ManageScreen with the collection 'laptop'
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageScreen(
                      collection: 'laptop', // The collection name is 'laptop'
                      title:
                          'Manage Laptop Data', // You can update this to any title you prefer
                      onLaptopImported: (List<List<dynamic>> data) {
                        // Implement the callback for handling imported data
                      },
                    ),
                  ),
                );
              },
            ),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushNamed(context, 'login_screen');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'BRAND',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedBrand = "";
                        });
                      },
                      child: const Text(
                        'Show All',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    BrandItem(
                      imagePath: 'assets/logo_asus.png',
                      label: 'Asus',
                      onTap: () {
                        setState(() {
                          selectedBrand = 'Asus';
                        });
                      },
                    ),
                    BrandItem(
                      imagePath: 'assets/logo_lenovo.png',
                      label: 'Lenovo',
                      onTap: () {
                        setState(() {
                          selectedBrand = 'Lenovo';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Our Laptop',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('laptop').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  }
                  final laptops = snapshot.data?.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final matchesSearch = data['Nama_Laptop']
                            .toString()
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase());
                        final matchesBrand = selectedBrand.isEmpty ||
                            data['Brand'] == selectedBrand;
                        return matchesSearch && matchesBrand;
                      }).toList() ??
                      [];

                  if (laptops.isEmpty) {
                    return const Center(child: Text('No laptops found'));
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: laptops.length,
                    itemBuilder: (context, index) {
                      final data =
                          laptops[index].data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () {
                          // TODO: Navigate to product details page
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  child: Image.network(
                                    data['Foto_Laptop'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  data['Nama_Laptop'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  formatRupiah(data['Harga']),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatRupiah(int harga) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(harga);
  }
}

class BrandItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const BrandItem({
    required this.imagePath,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                height: 50,
                width: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
