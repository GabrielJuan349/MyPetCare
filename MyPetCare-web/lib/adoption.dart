import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';

class CreateAdoptionScreen extends StatefulWidget {
  final String? clinicId;  // Recibimos el clinicId al crear la pantalla

  const CreateAdoptionScreen({super.key, required this.clinicId});

  @override
  _CreateAdoptionScreenState createState() => _CreateAdoptionScreenState();
}

class _CreateAdoptionScreenState extends State<CreateAdoptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  late final TextEditingController clinicIdController;

  DateTime? dateFound;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controller con el clinicId recibido
    clinicIdController = TextEditingController(text: globalClinicId);
  }

  @override
  void dispose() {
    // Liberamos los controllers
    nameController.dispose();
    ageController.dispose();
    typeController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    clinicIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Adopción')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Edad'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Tipo (Perro, Gato...)'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              // Campo clinicId solo lectura
              ListTile(
                title: Text(
                  dateFound == null
                      ? 'Fecha de hallazgo'
                      : 'Fecha: ${dateFound!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      dateFound = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      await FirebaseFirestore.instance.collection('adoption').add({
                        'name': nameController.text,
                        'age': int.tryParse(ageController.text) ?? 0,
                        'type': typeController.text,
                        'description': descriptionController.text,
                        'email': emailController.text,
                        'clinic_id': clinicIdController.text,
                        'dateFound': dateFound != null ? Timestamp.fromDate(dateFound!) : null,
                        'createdAt': Timestamp.now(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Adopción creada correctamente')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al crear adopción: $e')),
                      );
                    }
                  }
                },
                child: const Text('Guardar adopción'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdoptionFormLauncher extends StatelessWidget {
  final String clinicId;

  const AdoptionFormLauncher({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Crear nueva adopción'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateAdoptionScreen(clinicId: clinicId),
          ),
        );
      },
    );
  }
}
