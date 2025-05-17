import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lis_project/requests.dart';
import 'package:lis_project/data.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Owner user;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _localityController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setGlobalUser(context);
    user = Provider.of<OwnerModel>(context, listen: false).owner!;
    _nameController.text = user.name;
    _surnameController.text = user.surname;
    _phoneController.text = user.phoneNumber;
    _localityController.text = user.locality;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final updatedUser = Provider.of<OwnerModel>(context, listen: false).owner;

    if (updatedUser != null && updatedUser != user) {
      setState(() {
        user = updatedUser;
        _nameController.text = user.name;
        _surnameController.text = user.surname;
        _phoneController.text = user.phoneNumber;
        _localityController.text = user.locality;
      });
    }
  }


  Future<void> _signOut() async{
    await FirebaseAuth.instance.signOut();
    Provider.of<OwnerModel>(context).clearOwner();
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

  Future<void> _saveUserData() async{
    user.name = _nameController.text;
    user.surname = _surnameController.text;
    user.phoneNumber = _phoneController.text;
    user.locality = _localityController.text;
    context.read<OwnerModel>().updateOwner(user);
    await updateUserInfo(user.firebaseUser.uid, user.toJson());
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff59249),
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: (){
                _dialogConfirmDelete(context, user);
              },
              icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete account',
          )
        ],
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
              _buildEditableField("Name", _nameController),
              _buildEditableField("Surname", _surnameController),
              _buildEditableField("Phone", _phoneController, keyboardType: TextInputType.phone),
              _buildEditableField("Location",_localityController),
              _buildReadonlyField("Email", user.firebaseUser.email!),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      _buildChangePasswordPopUp(context);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF627ECB),
                      overlayColor: Colors.transparent,
                    ),
                    child: const Text('change password')
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // makes child buttons stretch horizontally
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _saveUserData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Changes updated successfully')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF339551),
                        padding: const EdgeInsets.symmetric(vertical: 20), // no horizontal padding
                      ),
                      child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        _signOut();
                        Navigator.pushNamed(context, '/init');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text("Sign out", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController textController,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: textController,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Enter a valid $label';
          return null;
        },
      ),
    );
  }

  Widget _buildReadonlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  Future<void> _buildChangePasswordPopUp(BuildContext context) async{
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change your password'),
          content: TextFormField(
            controller: _newPasswordController,
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New password',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length <= 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(textStyle: Theme.of(context).textTheme.labelLarge),
              child: const Text('save password'),
              onPressed: () {
                _changePassword(_newPasswordController.text);
                Navigator.of(context).pop();
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
      }
    );
  }

}