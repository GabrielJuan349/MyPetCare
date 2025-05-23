import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class ClinicHomeScreen extends StatefulWidget {
  final String clinicName;
  final String clinicId;

  const ClinicHomeScreen({super.key, required this.clinicName, required this.clinicId});

  @override
  State<ClinicHomeScreen> createState() => _ClinicHomeScreenState();
}

class _ClinicHomeScreenState extends State<ClinicHomeScreen> {
  bool _showForm = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerVet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'userId': userId,
        'email': _emailController.text.trim(),
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'accountType': 'vet',
        'clinicInfo': widget.clinicName,
        'clinicId': widget.clinicId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veterinario registrado exitosamente')),
      );

      setState(() {
        _showForm = false;
        _emailController.clear();
        _passwordController.clear();
        _firstNameController.clear();
        _lastNameController.clear();
        _phoneController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            Image.asset('assets/LogoSinFondoOrange.png', height: 45),
            const SizedBox(width: 12),
            Expanded(child: _buildTitle()),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.orange, size: 30),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'clinic',
                enabled: false,
                child: Text('Clínica: ${widget.clinicName}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Log out'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderImage(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _showForm = !_showForm);
                    },
                    icon: Icon(_showForm ? Icons.close : Icons.add),
                    label: Text(_showForm ? 'Cancelar' : 'Añadir Veterinario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_showForm) _buildVetForm(),
                  const SizedBox(height: 16),
                  _buildVetList(widget.clinicName),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
            children: const [
              TextSpan(text: 'My', style: TextStyle(color: Colors.black)),
              TextSpan(text: 'Pet', style: TextStyle(color: Colors.orange)),
              TextSpan(text: 'Care', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
        Text(
          'Welcome, ${widget.clinicName}',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildVetForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildField('Nombre', _firstNameController),
          _buildField('Apellido', _lastNameController),
          _buildField('Email', _emailController, TextInputType.emailAddress),
          _buildField('Teléfono', _phoneController, TextInputType.phone),
          _buildField('Contraseña', _passwordController, TextInputType.text, true),
          const SizedBox(height: 12),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _registerVet,
            child: const Text('Registrar Veterinario'),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      String label,
      TextEditingController controller, [
        TextInputType type = TextInputType.text,
        bool obscure = false,
      ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        validator: (value) =>
        value == null || value.trim().isEmpty ? 'Campo requerido' : null,
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

  Widget _buildVetList(String clinicName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('accountType', isEqualTo: 'vet')
          .where('clinicInfo', isEqualTo: clinicName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final vets = snapshot.data?.docs ?? [];

        if (vets.isEmpty) {
          return const Center(
            child: Text(
              'Añade a tus veterinarios para verlos aquí.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vets.length,
          itemBuilder: (context, index) {
            final vetDoc = vets[index];
            final vet = vetDoc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.orange),
                title: Text('${vet['firstName']} ${vet['lastName']}'),
                subtitle: Text('Email: ${vet['email']}\nTeléfono: ${vet['phone']}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: Text('¿Eliminar a ${vet['firstName']} ${vet['lastName']}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    try {
                      final userId = vet['userId'];

                      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veterinario eliminado')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al eliminar: $e')),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

}

class HeaderImage extends StatelessWidget {
  const HeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 350,
          width: double.infinity,
          child: Image.asset(
            'assets/web_imagen.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.5),
          ),
        ),
        Container(
          height: 350,
          width: double.infinity,
          color: Colors.black.withOpacity(0.35),
        ),
        Positioned(
          left: 20,
          top: 100,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.75),
            ),
            child: Text(
              'WELCOME TO MYPETCARE!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Managing Your Clinic\'s Vets\nIn One Place',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
