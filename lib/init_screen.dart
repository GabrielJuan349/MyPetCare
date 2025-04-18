import 'package:flutter/material.dart';
import 'package:lis_project/iniciar_sesion.dart';

class InitScreen extends StatelessWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const IniciarSesion(),
      ));
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF8E2B), // 7%
              Color(0xFFFFBA7E), // 62%
              Color(0xFFF8BE8C), // 74%
              Color(0xFFF6C59A), // 90%
            ],
            stops: [0.07, 0.62, 0.74, 0.90],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Image(
            image: AssetImage("assets/logo/nombreLogoSinFondo.png"),
            width: 300,
            height: 300,
          ),
        ),
      ),
    );
  }
}
