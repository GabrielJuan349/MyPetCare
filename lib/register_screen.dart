import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lis_project/iniciar_sesion.dart';

import 'signInWithGoogle.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingGoogle = false;


  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? firebaseuser = credential.user;
      print("userType from firebase $firebaseuser");
      print("UID: ${firebaseuser?.uid}");
      print("Token: ${await firebaseuser?.getIdToken()}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully')),
      );

      Navigator.pushNamed(context, '/formRegister', arguments: firebaseuser);

    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else {
        message = 'Registration failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xfff59249),
          title: const Text('Register'),
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.white,
          // Delete turn back option
          automaticallyImplyLeading: false
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(35.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value != null && value.contains('@')
                            ? null
                            : 'Enter a valid email',
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) => value != null && value.length >= 6
                            ? null
                            : 'Password must be at least 6 characters',
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _register,
                        child: const Text('Register'),
                      ),
                      const Text('or'),
                      _buildInitOptionsButton('assets/logo/google.png', 'Google')
                    ],
                  ),
                ),
              )
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.white,
              width: double.infinity,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const IniciarSesion()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF627ECB),
                        overlayColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Future<void> _signInWithGoogle() async{
    final GoogleAuthService authService = GoogleAuthService();
    final firebaseuser = await authService.signInWithGoogle();
    print("userType from firebase $firebaseuser");
    print("UID: ${firebaseuser?.uid}");
    print("Token: ${await firebaseuser?.getIdToken()}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User registered successfully')),
    );

    Navigator.pushNamed(context, '/formRegister', arguments: firebaseuser,);
  }

  Widget _buildInitOptionsButton(String imagePath, String method){
    final GoogleAuthService authService = GoogleAuthService();
    return TextButton.icon(
      onPressed: () {
        setState(() {_isLoadingGoogle = true;});
        _signInWithGoogle();
        setState(() {_isLoadingGoogle = false;});
      },
      icon: Image.asset(imagePath, width: 20,),
      label: Text('Sign in with $method'),
      style: TextButton.styleFrom(
          side: const BorderSide(
              color: Colors.grey
          )
      ),
    );
  }

}
