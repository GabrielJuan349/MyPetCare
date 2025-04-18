import 'package:flutter/material.dart';
import 'package:lis_project/register_screen.dart';
import 'package:lis_project/home_screen.dart';
import 'package:lis_project/test.dart';

class IniciarSesion extends StatelessWidget {

  const IniciarSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
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
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Image(
                        image: AssetImage("assets/logo/LogoSinFondo.png"),
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Email',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              //context, MaterialPageRoute(builder: (context) => HomeScreen())
                              context, MaterialPageRoute(builder: (context) => const Test())
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF627ECB),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF627ECB),
                            overlayColor: Colors.transparent,
                          ),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Color(0xFF627ECB)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            width: double.infinity,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () { Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen())

                    );},
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF627ECB),
                      overlayColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF627ECB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
