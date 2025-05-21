import 'package:flutter/material.dart';
import 'package:lis_project/requests.dart';

class AddVaccineScreen extends StatefulWidget {
  final String petId;

  const AddVaccineScreen({super.key, required this.petId});

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String date = '';

  bool isSubmitting = false;

  Future<void> submitVaccine() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSubmitting = true);

      try {
        await createVaccine({
          "name": name,
          "Date": date,
          "PetId": widget.petId,
        });

        if (mounted) {
          Navigator.pop(context, true); // Volver a la pantalla anterior
        }
      } catch (e) {
        print("Error al crear vacuna: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al crear vacuna')),
        );
      } finally {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Vacuna'),
        backgroundColor: const Color(0xfff59249),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre de la vacuna'),
                onChanged: (value) => name = value,
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Fecha (YYYY-MM-DD)'),
                onChanged: (value) => date = value,
                validator: (value) => value!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : submitVaccine,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xfff59249)),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Vacuna'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
