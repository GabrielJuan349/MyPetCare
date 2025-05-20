import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'pet_details.dart';
import 'assign_appointment.dart';

class DayScheduleScreen extends StatelessWidget {
  final DateTime date;
  final String? petId;

  const DayScheduleScreen({required this.date, this.petId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    return Scaffold(
      appBar: AppBar(title: Text('Schedule for $formattedDate')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('date', isEqualTo: formattedDate)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final docs = snapshot.data!.docs;

          return ListView.builder(itemCount: 36,
              itemBuilder: (context, index) {
            final startHour = 8 + (index ~/ 4);
            final startMinute = (index % 4) * 15;
            final time = TimeOfDay(hour: startHour, minute: startMinute);
            final timeLabel = time.format(context);
            final appointmentList = docs.where((doc) => doc['id'] == index).toList();
            final appointment = appointmentList.isNotEmpty ? appointmentList.first : null;

            if (appointment != null && appointment['petId'] != null) {
              return ListTile(
                title: Text('$timeLabel - Cita asignada'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetDetailsScreen(petId: appointment['petId']),
                    ),
                  );
                },
              );
            } else {
              return ListTile(
                title: Text('$timeLabel - Disponible'),
                trailing: ElevatedButton(
                  child: const Text('Asignar cita'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignAppointmentScreen(date: formattedDate, slot: index, petId: petId,),
                      ),
                    );
                  },
                ),
              );
            }
          }
          );
        },
      ),
    );
  }
}
