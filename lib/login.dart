import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clinic_home.dart';
import 'home.dart';
import 'main.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      // Busca el usuario en Firestore por email
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => _errorMessage = 'El usuario no existe.');
        return;
      }

      final userData = query.docs.first.data();
      final accountType = userData['accountType'];

      // Login con Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Redirección según el tipo de cuenta
      if (accountType == 'clinic') {
        globalClinicInfo = userData['clinicInfo'];
        final clinicInfo = userData['clinicInfo'];
        final clinicName = clinicInfo is Map ? clinicInfo['name'] : clinicInfo;
        final clinicId = clinicInfo is Map ? clinicInfo['id'] : clinicInfo;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ClinicHomeScreen(clinicName: clinicName, clinicId: clinicId),
          ),
        );
      } else if (accountType == 'vet') {
        globalClinicInfo = userData['clinicInfo'];
        globalVetId = FirebaseAuth.instance.currentUser?.uid;
        globalVetName = userData['First Name'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      } else {
        setState(() => _errorMessage = 'Tipo de cuenta no reconocido.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Error desconocido');
    } catch (e) {
      setState(() => _errorMessage = 'Error inesperado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF8E2B),
              Color(0xFFFFBA7E),
              Color(0xFFF8BE8C),
              Color(0xFFF6C59A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Image(
                  image: AssetImage("assets/LogoSinFondo.png"),
                  width: 500,
                  height: 100,
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                TextField(
                  controller: emailController,
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
                  controller: passwordController,
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
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF627ECB),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  children: [
                    const Text("¿Eres una clínica sin cuenta?"),
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, '/clinic-register'),
                      child: const Text(
                        "Regístrate",
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
