import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lis_project/requests.dart';
import 'package:lis_project/data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _signOut() async{
    await FirebaseAuth.instance.signOut();
  }

  // https://stackoverflow.com/questions/52293129/how-to-change-password-using-firebase-in-flutter
  Future<void> _changePassword(String password) async{
    //Create an instance of the current user.
    User user = await FirebaseAuth.instance.currentUser!;

    //Pass in the password to updatePassword.
    user.updatePassword(password).then((_){
      print("Successfully changed password");
    }).catchError((error){
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }


  Future<void> _dialogConfirmDelete(BuildContext context, Owner user) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to delete your account?'),
          content: const Text(
            'This action is permanent and cannot be undone.\n'
              'All your data, preferences, and saved content will be permanently deleted.'
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('yes, delete my account'),
              onPressed: () {
                deleteUser(user.firebaseUser.uid);
                Navigator.pushNamed(context, '/init');
              },
            ),
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //TODO: Check if it's okay. Integración de back and front.
    final user = ModalRoute.of(context)!.settings.arguments as Owner;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff59249),
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Imagen de perfil
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('animals/cat.png'), // Cambia por la ruta de tu imagen
              ),
              const SizedBox(height: 24),

              // Campos editables
              _buildEditableField("Name", user.name, (val) => user.name = val),
              _buildEditableField("Surname", user.surname, (val) => user.surname = val),
              _buildEditableField("Phone", user.phoneNumber, (val) => user.phoneNumber = val, keyboardType: TextInputType.phone),
              _buildEditableField("Location", user.locality, (val) => user.locality = val),
              _buildReadonlyField("Email", user.firebaseUser.email!),

              const SizedBox(height: 24),

              // Botón de actualizar
              ElevatedButton(
                onPressed: () {
                  // Acción para eliminar
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Changes updated')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF339551),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 10),

              // Sign put button
              ElevatedButton(
                onPressed: () {
                  _signOut();
                  Navigator.pushNamed(context, '/init');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: const Text("Sign out", style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 50),

              // Botón de eliminar cuenta
              ElevatedButton(
                onPressed: () {
                  _dialogConfirmDelete(context, user);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                ),
                child: const Text("Delete Account", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String initialValue, Function(String) onSaved,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Required';
          return null;
        },
        onSaved: (val) => onSaved(val!),
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          TextField(
            obscureText: obscureText,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE9EFFF),
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

  Widget _buildReadonlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}