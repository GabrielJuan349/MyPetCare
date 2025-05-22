import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lis_web/clinic_home.dart';

class ClinicUserRegisterScreen extends StatefulWidget {
  final String email;
  final String clinicName;
  final String phone;
  final String locality;
  const ClinicUserRegisterScreen({
    super.key,
    required this.email,
    required this.phone,
    required this.locality,
    required this.clinicName,
  });

  @override
  State<ClinicUserRegisterScreen> createState() => _ClinicUserRegisterScreenState();
}

class _ClinicUserRegisterScreenState extends State<ClinicUserRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Crear usuario con email y password en Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: _passwordController.text.trim(),
      );

      final userId = userCredential.user!.uid;

      // Guardar info extra en Firestore en colección "users"
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': widget.email,
        'userId': userId,
        'accountType': 'clinic',  // según enum
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': widget.phone,
        'locality': widget.locality,
        'clinicInfo': widget.clinicName,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClinicHomeScreen(clinicName: widget.clinicName,
          ),
        ),
      );

    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.message != null) {
        message = e.message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator ??
                (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: enabled ? const Color(0xFFE9EFFF) : Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic User Registration'),
        backgroundColor: const Color(0xfff59249),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(
                  label: 'Email',
                  controller: TextEditingController(text: widget.email),
                  enabled: false,  // readonly
                ),
                _buildTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                _buildTextField(label: 'First Name', controller: _firstNameController),
                _buildTextField(label: 'Last Name', controller: _lastNameController),
                _buildTextField(
                  label: 'Phone',
                  controller: TextEditingController(text: widget.phone),
                  enabled: false,
                ),
                _buildTextField(label: 'Locality', controller: TextEditingController(text: widget.locality),
                  enabled: false,),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF627ECB),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Register User'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
