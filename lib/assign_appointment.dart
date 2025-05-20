import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignAppointmentScreen extends StatefulWidget {
  final String date;
  final int slot;
  final String? petId;

  const AssignAppointmentScreen({
    required this.date,
    required this.slot,
    this.petId,
  });

  @override
  State<AssignAppointmentScreen> createState() => _AssignAppointmentScreenState();
}

class _AssignAppointmentScreenState extends State<AssignAppointmentScreen> {
  String? selectedPetId;
  List<DocumentSnapshot> pets = [];

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance.collection('pets').get().then((snapshot) {
      setState(() {
        pets = snapshot.docs;
        if (widget.petId != null) {
          selectedPetId = widget.petId;
        }
      });
    });
  }

  void assignAppointment() async {
    if (selectedPetId == null) return;

    final existing = await FirebaseFirestore.instance
        .collection('appointments')
        .where('date', isEqualTo: widget.date)
        .where('slot', isEqualTo: widget.slot)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya existe una cita en este horario')),
      );
      return;
    }
//TODO: hay que asegurarse de como funciona esto con el back de cita

    await FirebaseFirestore.instance.collection('appointments.date').add({
      'id': widget.slot,
      'petId': selectedPetId,
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar cita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text('Seleccionar mascota'),
              value: selectedPetId,
              isExpanded: true,
              items: pets.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return DropdownMenuItem(
                  value: doc.id,
                  child: Text(data['name'] ?? 'Sin nombre'),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedPetId = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: assignAppointment,
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );
  }
}
