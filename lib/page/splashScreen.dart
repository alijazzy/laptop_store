import 'package:flutter/material.dart';
import 'package:laptop_store/page/loginPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _GotonavigateToHome();
  }

  _GotonavigateToHome() async {
    await Future.delayed(Duration(seconds: 4));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(), // Ganti dengan WelcomePage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/Logo/background.jpg'), // Ganti dengan nama file gambar background Anda
            fit: BoxFit.cover, // Mengatur gambar untuk menutupi seluruh area
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('assets/Logo/logo.png'),
                width: 220,
                height: 220, // Ganti height agar tidak terlalu tinggi
              ),
            ],
          ),
        ),
      ),
    );
  }
}
