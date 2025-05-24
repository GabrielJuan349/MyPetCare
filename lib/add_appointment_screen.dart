import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lis_project/appointment.dart';
import 'package:provider/provider.dart';
import 'package:lis_project/data.dart';
import 'package:lis_project/requests.dart';
import 'package:intl/intl.dart';
//import 'package:lis_project/scanAllModule.dart';

class NewAppointmentScreen extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedTime;

  const NewAppointmentScreen(
      {super.key, required this.selectedDate, required this.selectedTime});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  final TextEditingController petController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController vetController = TextEditingController();

  final appBarColor = const Color(0xfff59249);

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
    // TODO: Missing a getVetsByClinicId
    dateController.text = DateFormat('dd/MM/yyyy').format(widget.selectedDate);
    timeController.text = widget.selectedTime;
    clinicController.text =
        Provider.of<OwnerModel>(context, listen: false).owner?.clinicInfo ?? '';
  }

  @override
  Widget build(BuildContext context) {
    List<String> petNames = Provider.of<OwnerModel>(context).getPetNames();
    List<String> vetNames = ['Vet 1', 'Vet 2', 'Vet 3', 'Vet 4', 'Vet 5'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "New Appointment",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              dispose();
              Navigator.pushNamed(
                context,
                '/profile',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
          child: Column(
            children: [
              buildDropdown("Pet", petNames, petController),
              buildDropdown(
                  "Type of Appointment", appointmentTypes, typeController),
              buildField("Reason", reasonController),
              buildField("Clinic", clinicController),
              buildField("Day of the appointment", dateController),
              buildField("Time", timeController),
              buildDropdown("Veterinarian", vetNames, vetController),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await createAppointment();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: const Color(0xFF627ECB),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Add Appointment"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller) {
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
              fillColor: const Color(0xFFECF1FF),
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
              fillColor: const Color(0xFFECF1FF),
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

  Future<void> createAppointment() async {
    try {
      final ownerId = Provider.of<OwnerModel>(context, listen: false)
          .owner!
          .firebaseUser
          .uid;

      // Pass date to Datetime? => NNecessary to short in ascending order after
      final appointment = Appointment(
          id: '',
          ownerId: ownerId,
          petName: petController.text,
          date: dateController.text,
          time: timeController.text,
          type: typeController.text,
          reason: reasonController.text,
          clinicName: clinicController.text,
          vetName: vetController.text);

      print('Appointment created successfully $appointment');
      /*
      TODO: Change this to call the API request - now is
       directly calling firebase
      */
      final appointmentRef =
          await FirebaseFirestore.instance.collection('appointments');

      // Add the new appointment inside firestore
      final docRef = await appointmentRef.add(appointment.toJson());
      print(docRef.id);

    } catch (e) {
      print('Failed to create appointment: $e');
    }
  }

  @override
  void dispose() {
    petController.dispose();
    typeController.dispose();
    reasonController.dispose();
    dateController.dispose();
    timeController.dispose();
    clinicController.dispose();
    vetController.dispose();
    super.dispose();
  }
}
