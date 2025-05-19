import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lis_project/data.dart';
import 'package:lis_project/requests.dart';
import 'package:provider/provider.dart';

class RegisterFormScreen extends StatefulWidget {
  const RegisterFormScreen({super.key});

  @override
  State<RegisterFormScreen> createState() => _RegisterFormScreenState();
}

class _RegisterFormScreenState extends State<RegisterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _localityController = TextEditingController();
  final _clinicController = TextEditingController();

  bool _isLoading = false;
  String? _selectedValue;
  List<String> _options = ['Pet owner', 'Vet', 'Vet clinic', 'Admin'];
  List<String> _clinics = [];
String? _selectedClinic;


  @override
void initState() {
  super.initState();
  _selectedValue = _options.isNotEmpty ? _options[0] : null;
  _loadClinics();
}

Future<void> _loadClinics() async {
  try {
    final clinics = await getClinics(); 
    setState(() {
      _clinics = clinics.map<String>((clinic) => clinic['name'] as String).toList();
      _selectedClinic = _clinics.isNotEmpty ? _clinics[0] : null;
    });
  } catch (e) {
    print('Failed to load clinics: $e');
  }
}


  Future<void> _addUserInfo(User firebaseUser) async{
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });
    print(_selectedValue);
    Owner user = Owner(firebaseUser);
    user.setUserData(
        _selectedValue,
        _nameController.text,
        _surnameController.text,
        _clinicController.text,
        _phoneController.text,
        _localityController.text);
    // Save user data in firestore
    await addUser(user.getUserData());
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data submitted successfully!')),
    );
    Provider.of<OwnerModel>(context, listen: false).setOwner(user);
    // Navigate to home page
    Navigator.pushNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = ModalRoute.of(context)!.settings.arguments as User;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color(0xfff59249),
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Hey, welcome to MyPetCare!\n',
                          style: TextStyle(
                            fontSize: 23,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Please tell us more about you',
                          style: TextStyle(
                            fontSize: 17,
                        ),
                        ),
                      ),
                      Form(
                        key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField('Name', _nameController),
                              _buildTextField('Surname', _surnameController),
                               _buildClinicDropdown(),
                              _buildTextField('Phone Number', _phoneController),
                              _buildTextField('Locality', _localityController),
                              _buildUserTypeSelector(),
                              _buildButton(firebaseUser)
                            ],
                          )
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(User firebaseUser) {
    return _isLoading ? const Center(child: CircularProgressIndicator())
        : Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: (){
            _addUserInfo(firebaseUser);
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
            textStyle: TextStyle(fontSize: 18),
            backgroundColor: Color(0xFF627ECB),
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select an option:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedValue,
              hint: Text('Choose an option'),
              isExpanded: true,
              items: _options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedValue = newValue;
                });
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController textController,{bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            obscureText: obscureText,
            controller: textController,
            validator: (value){
              if (value == null || value.trim().isEmpty) {
                return 'Enter a valid $label';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Color(0xFFE9EFFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicDropdown() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      value: _clinics.contains(_selectedClinic) ? _selectedClinic : null,
      decoration: InputDecoration(
        labelText: 'Clinic',
        filled: true,
        fillColor: Color(0xFFE9EFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
      ),
      items: _clinics.toSet().toList().map((clinic) {  // elimina duplicados
        return DropdownMenuItem<String>(
          value: clinic,
          child: Text(clinic),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedClinic = value!;
          _clinicController.text = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a clinic';
        }
        return null;
      },
    ),
  );
}


}
