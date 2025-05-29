import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTreatmentScreen extends StatefulWidget {
  final String petId;
  final String? treatmentNameToRenew;

  const AddTreatmentScreen({
    super.key,
    required this.petId,
    this.treatmentNameToRenew,
  });

  @override
  State<AddTreatmentScreen> createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  final TextEditingController _treatmentController = TextEditingController();
  final int durationDays = 30;

  @override
  void initState() {
    super.initState();
    if (widget.treatmentNameToRenew != null) {
      _treatmentController.text = widget.treatmentNameToRenew!;
    }
  }

  Future<void> _submitTreatment() async {
    final name = _treatmentController.text.trim();
    if (name.isEmpty) return;

    final now = DateTime.now();
    final endDate = now.add(Duration(days: durationDays));

    await FirebaseFirestore.instance.collection('treatment').add({
      'id_pet': widget.petId,
      'id_vet': 'default_vet',
      'name': name,
      'date_start': Timestamp.fromDate(now),
      'date_end': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Nuevo tratamiento', style: GoogleFonts.inter(color: Colors.orange)),
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        foregroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _treatmentController,
              decoration: InputDecoration(
                labelText: 'Nombre del tratamiento',
                labelStyle: GoogleFonts.inter(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.withOpacity(0.85),
              ),
              onPressed: _submitTreatment,
              child: Text('Guardar', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
