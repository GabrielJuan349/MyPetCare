import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'main.dart';

class AssignAppointmentScreen extends StatefulWidget {
  final String date;
  final String time;
  final String? petId;

  const AssignAppointmentScreen({
    Key? key,
    required this.date,
    required this.time,
    this.petId,
  }) : super(key: key);

  @override
  State<AssignAppointmentScreen> createState() =>
      _AssignAppointmentScreenState();
}

class _AssignAppointmentScreenState extends State<AssignAppointmentScreen> {
  String? selectedPetId;
  List<Map<String, dynamic>> filteredPets = [];
  List<DocumentSnapshot> pets = [];
  final TextEditingController typeController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final primaryOrange = Colors.orange;
  late final lightOrange, borderOrange;

  List<String> appointmentTypes = [
    'Sick visit',
    'Vaccination',
    'General checkup',
    'Test (blood, urine, etc)',
    'Treatment',
    'Other'
  ];

  @override
  void initState() {
    super.initState();


    lightOrange = primaryOrange.withOpacity(0.1);
    borderOrange = primaryOrange.withOpacity(0.2);

    dateController.text = widget.date;
    timeController.text = widget.time;

    _loadFilteredPets();
  }
  Future<void> _loadFilteredPets() async {
    if (globalClinicInfo == null) {
      print('Error: globalClinicInfo es null');
      return;
    }

    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final petsSnapshot = await FirebaseFirestore.instance.collection('pets').get();

      final usersByDocId = <String, String>{};
      for (var userDoc in usersSnapshot.docs) {
        final data = userDoc.data();
        final clinic = data['clinicInfo'];
        final accountType = data['accountType'];

        final isClient = accountType == 'owner' || accountType == 'Pet owner' || accountType == 'cliente';
        final sameClinic = clinic == globalClinicInfo;

        if (isClient && sameClinic) {
          final fullName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
          usersByDocId[userDoc.id] = fullName;
        }
      }

      final petsResult = petsSnapshot.docs
          .where((petDoc) => usersByDocId.containsKey(petDoc.data()['owner']))
          .map((petDoc) {
        final data = petDoc.data();
        final ownerId = data['owner'];
        final ownerName = usersByDocId[ownerId] ?? 'Desconocido';

        return {
          'petId': petDoc.id,
          'name': data['name'],
          'ownerName': ownerName,
        };
      }).toList();

      setState(() {
        filteredPets = petsResult;
        if (widget.petId != null) {
          selectedPetId = widget.petId;
        }
      });
    } catch (e) {
      print('Error cargando mascotas filtradas: $e');
    }
  }


  void assignAppointment() async {
    if (selectedPetId == null ||
        typeController.text.isEmpty ||
        reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Porfavor rellena los campos')));
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final vetInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();

    final clinicName = vetInfo.data()?['clinicInfo'];
    final vetName = vetInfo.data()?['firstName'];

    final existing = await FirebaseFirestore.instance
        .collection('appointments')
        .where('date', isEqualTo: widget.date)
        .where('time', isEqualTo: widget.time)
        .get();

    print("Widget slot: ${widget.time}");

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya existe una cita en este horario')),
      );
      return;
    }

    // getOwnerId
    final owner = await FirebaseFirestore.instance
        .collection('pets')
        .doc(selectedPetId)
        .get();

    final ownerId = owner.data()?['owner'];
    final petName = owner.data()?['name'];

    final DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(widget.date);
    await FirebaseFirestore.instance.collection('appointments').add({
      'clinicName': clinicName,
      'date': parsedDate,
      'ownerId': ownerId,
      'petName': petName,
      'reason': reasonController.text,
      'type': typeController.text,
      'time': widget.time,
      'vetName': vetName,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                  items: filteredPets.map((pet) {
                    return DropdownMenuItem<String>(
                      value: pet['petId'],
                      child: Text(
                        '${pet['name']} - ${pet['ownerName']}',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedPetId = value),
                ),
              ),
            ),
            const SizedBox(height: 32),
            buildField('Fecha', dateController, true),
            buildField('Hora', timeController, true),
            buildField('Razón', reasonController, false),
            buildDropdown('Tipo', appointmentTypes, typeController),
            Center(
              child: ElevatedButton(
                onPressed: assignAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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

  Widget buildField(
      String label, TextEditingController controller, bool isReadOnly) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: lightOrange,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            readOnly: isReadOnly,
          ),
        ],
      ),
    );
  }

  Widget buildDropdown(
      String label, List<String> items, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: controller.text.isNotEmpty ? controller.text : null,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.text = value;
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: lightOrange,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
