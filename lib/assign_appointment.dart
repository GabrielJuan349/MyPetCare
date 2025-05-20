import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignAppointmentScreen extends StatefulWidget {
  final String date;
  final int slot;
  final String? petId;

  const AssignAppointmentScreen({
    Key? key,
    required this.date,
    required this.slot,
    this.petId,
  }) : super(key: key);

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
        .where('id', isEqualTo: widget.slot)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya existe una cita en este horario')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('appointments').add({
      'id': widget.slot,
      'petId': selectedPetId,
      'date': widget.date,
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primaryOrange = Colors.orange;
    final lightOrange = primaryOrange.withOpacity(0.1);
    final borderOrange = primaryOrange.withOpacity(0.2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Asignar cita',
          style: GoogleFonts.inter(
            color: primaryOrange,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona una mascota:',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: lightOrange,
                border: Border.all(color: borderOrange),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPetId,
                  hint: Text(
                    'Seleccionar mascota',
                    style: GoogleFonts.inter(color: Colors.black54),
                  ),
                  isExpanded: true,
                  items: pets.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(
                        data['name'] ?? 'Sin nombre',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedPetId = value),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: assignAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Asignar cita',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
