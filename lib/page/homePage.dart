import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'shoppingCartPage.dart';
import 'package:provider/provider.dart';
import 'shoppingCartService.dart';
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
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Logo/background.jpg'),
                  fit: BoxFit.cover, // Atur sesuai kebutuhan
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/Logo/logo.png',
                  height: 50,
                ),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Shopping Cart'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const CartPage()));
              },
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            pinned: true,
            expandedHeight: 80,
            toolbarHeight: 60,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.0,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/Logo/background.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
            ),
            title: Row(
              children: [
                Image.asset(
                  'assets/Logo/logo.png',
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            actions: [
              Stack(
                alignment: Alignment
                    .center, // Tambahkan ini untuk memastikan alignment konsisten
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartPage()),
                      );
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Consumer<CartService>(
                      builder: (context, cart, child) => cart.itemCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cart.itemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox(
                              width: 16,
                              height:
                                  16), // Gunakan SizedBox alih-alih Container kosong
                    ),
                  ),
                ],
              ),
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey[100],
              child: Padding(
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
                              imagePath: 'assets/Logo/logo_asus.png',
                              label: 'Asus',
                              onTap: () {
                                setState(() {
                                  selectedBrand = 'Asus';
                                });
                              },
                            ),
                            BrandItem(
                              imagePath: 'assets/Logo/logo_lenovo.png',
                              label: 'Lenovo',
                              onTap: () {
                                setState(() {
                                  selectedBrand = 'Lenovo';
                                });
                              },
                            ),
                            BrandItem(
                              imagePath: 'assets/Logo/logo_hp.png',
                              label: 'HP',
                              onTap: () {
                                setState(() {
                                  selectedBrand = 'HP';
                                });
                              },
                            ),
                            BrandItem(
                              imagePath: 'assets/Logo/logo_acer.png',
                              label: 'Acer',
                              onTap: () {
                                setState(() {
                                  selectedBrand = 'Acer';
                                });
                              },
                            ),
                            BrandItem(
                              imagePath: 'assets/Logo/logo_apple.png',
                              label: 'Apple',
                              onTap: () {
                                setState(() {
                                  selectedBrand = 'Apple';
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
                  ],
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('laptop').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const SliverFillRemaining(
                  child: Center(child: Text('Error fetching data')),
                );
              }
              final laptops = snapshot.data?.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final matchesSearch = data['Nama_Laptop']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase());
                    final matchesBrand =
                        selectedBrand.isEmpty || data['Brand'] == selectedBrand;
                    return matchesSearch && matchesBrand;
                  }).toList() ??
                  [];

              if (laptops.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No laptops found')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data =
                          laptops[index].data() as Map<String, dynamic>;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: Image.asset(
                                  'assets/${data['Foto_Laptop']}',
                                  fit: BoxFit.contain,
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Provider.of<CartService>(context,
                                            listen: false)
                                        .addItem(
                                      laptops[index].id,
                                      data['Nama_Laptop'],
                                      data['Brand'],
                                      data['Harga'],
                                      data['Foto_Laptop'],
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Added to cart'),
                                        duration: const Duration(seconds: 1),
                                        action: SnackBarAction(
                                          label: 'VIEW CART',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CartPage()),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.black, // Background color
                                    padding: const EdgeInsets.only(
                                        left: 25, right: 25),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Icon(Icons.shopping_cart,
                                          color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Add to Cart',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: laptops.length,
                  ),
                ),
              );
            },
          ),
        ],
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
