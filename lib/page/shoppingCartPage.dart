import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'shoppingCartService.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = ['Cash', 'Card', 'E-Wallet'];
  String? _errorMessage;

  String formatRupiah(int price) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return formatter.format(price);
  }

  Future<void> _saveTransactionToFirestore(
      List<CartItem> items, int total) async {
    final batch = FirebaseFirestore.instance.batch();
    final laptopCollection = FirebaseFirestore.instance.collection('laptop');

    try {
      for (var item in items) {
        final laptopDoc = await laptopCollection.doc(item.id).get();
        if (!laptopDoc.exists) {
          throw 'Laptop dengan ID ${item.id} tidak ditemukan';
        }

        final currentStock = laptopDoc.data()?['Stok'] ?? 0;
        if (currentStock < item.quantity) {
          throw 'Stok tidak mencukupi untuk ${item.name}. Tersisa: $currentStock';
        }
      }

      final List<Map<String, dynamic>> barang = items.map((item) {
        return {
          "ID_Laptop": item.id,
          "Nama_Laptop": item.name,
          "Brand": item.brand,
          "Quantity": item.quantity,
        };
      }).toList();

      final String tanggalTransaksi =
          DateFormat('yyyy-MM-dd').format(DateTime.now());

      final transactionRef =
          FirebaseFirestore.instance.collection('transaksi').doc();
      batch.set(transactionRef, {
        "Barang": barang,
        "tanggal_transaksi": tanggalTransaksi,
        "Total": total,
        "payment_method": _selectedPaymentMethod,
      });

      for (var item in items) {
        final laptopRef = laptopCollection.doc(item.id);
        batch.update(laptopRef, {'Stok': FieldValue.increment(-item.quantity)});
      }

      await batch.commit();

      Provider.of<CartService>(context, listen: false).clear();

      setState(() {
        _selectedPaymentMethod = null;
        _errorMessage = null;
      });

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Transaksi Berhasil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text('Terima kasih telah berbelanja!'),
                Text('Total Pembayaran: ${formatRupiah(total)}'),
                Text('Metode Pembayaran: $_selectedPaymentMethod'),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(error.toString()),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Cart'),
                  content:
                      const Text('Are you sure you want to clear the cart?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    TextButton(
                      child: const Text('Clear'),
                      onPressed: () {
                        Provider.of<CartService>(context, listen: false)
                            .clear();
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartService>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final item = cart.items.values.toList()[i];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: Image.asset(
                          'assets/${item.image}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.name),
                        subtitle: Text(formatRupiah(item.price)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                cart.updateQuantity(item.id, item.quantity - 1);
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cart.updateQuantity(item.id, item.quantity + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ...cart.items.values.map((item) {
                      return Text(
                        '${item.name} x${item.quantity} ${formatRupiah(item.price * item.quantity)}',
                      );
                    }).toList(),
                    const Divider(),
                    Text(
                      'Total: ${formatRupiah(cart.totalAmount.toInt())}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Method',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          hint: const Text('Choose Payment Method'),
                          value: _selectedPaymentMethod,
                          isExpanded: true,
                          items: _paymentMethods.map((String method) {
                            return DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPaymentMethod = newValue;
                              _errorMessage = null;
                            });
                          },
                        ),
                      ),
                    ),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedPaymentMethod == null) {
                        setState(() {
                          _errorMessage =
                              'You have to select a payment method!';
                        });
                        return;
                      }

                      _saveTransactionToFirestore(
                        cart.items.values.toList(),
                        cart.totalAmount.toInt(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Checkout'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
