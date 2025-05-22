import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clinic_user_register.dart';

class ClinicRegisterScreen extends StatefulWidget {
  const ClinicRegisterScreen({super.key});

  @override
  State<ClinicRegisterScreen> createState() => _ClinicRegisterScreenState();
}

class _ClinicRegisterScreenState extends State<ClinicRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoriesController = TextEditingController();
  final _cityController = TextEditingController();
  final _cpController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> categories = _categoriesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      String latStr = _latitudeController.text.trim();
      String lngStr = _longitudeController.text.trim();

      if (latStr.isEmpty || lngStr.isEmpty) {
        throw Exception('Latitude and Longitude are required');
      }

      final latitude = double.parse(latStr);
      final longitude = double.parse(lngStr);

      final clinicData = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'categories': categories,
        'city': _cityController.text.trim(),
        'cp': _cpController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'website': _websiteController.text.trim(),
        'latitude': latitude,       // como número
        'longitude': longitude,     // como número
      };

      await FirebaseFirestore.instance.collection('clinic').add(clinicData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clinic created successfully!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClinicUserRegisterScreen(
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            locality: _cityController.text.trim(),
            clinicName: _nameController.text.trim()
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
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
          fillColor: const Color(0xFFE9EFFF),
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
        title: const Text('Create Clinic'),
        backgroundColor: const Color(0xfff59249),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextField(label: 'Name', controller: _nameController),
                _buildTextField(label: 'Address', controller: _addressController),
                _buildTextField(
                  label: 'Categories (comma separated)',
                  controller: _categoriesController,
                  keyboardType: TextInputType.text,
                ),
                _buildTextField(label: 'City', controller: _cityController),
                _buildTextField(label: 'Postal Code (CP)', controller: _cpController),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter Email';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'Phone',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(
                  label: 'Website',
                  controller: _websiteController,
                  keyboardType: TextInputType.url,
                ),
                _buildTextField(
                  label: 'Latitude',
                  controller: _latitudeController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                _buildTextField(
                  label: 'Longitude',
                  controller: _longitudeController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF627ECB),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Create Clinic'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
