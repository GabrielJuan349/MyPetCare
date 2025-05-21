import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lis_project/iniciar_sesion.dart';
import 'package:lis_project/data.dart';
import 'package:provider/provider.dart';

class InitScreen extends StatelessWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF8E2B),
                  Color(0xFFFFBA7E),
                  Color(0xFFF8BE8C),
                  Color(0xFFF6C59A),
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

          // StreamBuilder check user login state
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              Future.delayed(const Duration(seconds: 2), () {
                if (snapshot.hasData) {
                  // User is logged in
                  Owner user = Owner(snapshot.data!);
                  Navigator.pushNamed(
                    context,
                    '/home',
                    arguments: user,
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const IniciarSesion()),
                  );
                }
              });

              return Container();
            },
          ),
        ],
      ),
    );
  }
}
