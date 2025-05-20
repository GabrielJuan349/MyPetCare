import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'report.dart';
import 'schedule.dart';
import 'treatment.dart';
import 'prescription.dart';

class PetDetailsScreen extends StatelessWidget {
  final String petId;

  const PetDetailsScreen({required this.petId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('pets').doc(petId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle de mascota')),
            body: const Center(child: Text('No se encontró la mascota')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(title: Text(data['name'] ?? 'Mascota')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${data['name'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                Text('Raza: ${data['breed'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                Text('Edad: ${data['age']?.toString() ?? 'N/A'} años', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReportFormScreen(petId: petId)),
                    );
                  },
                  child: const Text('Generar informe'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ScheduleScreen(petId: petId)),
                    );
                  },
                  child: const Text('Reprogramar cita'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TreatmentFormScreen(petId: petId)),
                    );
                  },
                  child: const Text('Tratamiento'),
                ),
                ElevatedButton(
                  onPressed: () {/*TODO: file_picker es el que me da problemas con versiones, necesito que otra persona se encargue.
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PrescriptionScreen(petId: petId)),
                    );
                  */},
                  child: const Text('Recetas'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
