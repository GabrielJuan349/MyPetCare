import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pet_details.dart';
import 'assign_appointment.dart';

class DayScheduleScreen extends StatelessWidget {
  final DateTime date;
  final String? petId;

  const DayScheduleScreen({required this.date, this.petId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final displayDate = DateFormat('dd/MM/yyyy').format(date);
    final primaryOrange = Colors.orange;
    final lightOrange = primaryOrange.withOpacity(0.1);
    final borderOrange = primaryOrange.withOpacity(0.1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Agenda del $displayDate',
          style: GoogleFonts.inter(
            color: primaryOrange,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('date', isEqualTo: formattedDate)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: 36,
            itemBuilder: (context, index) {
              final startHour = 8 + (index ~/ 4);
              final startMinute = (index % 4) * 15;
              final time = TimeOfDay(hour: startHour, minute: startMinute);
              final timeLabel = time.format(context);
              final appointmentList = docs.where((doc) => doc['id'] == index).toList();
              final appointment = appointmentList.isNotEmpty ? appointmentList.first : null;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: lightOrange,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderOrange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20, color: primaryOrange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$timeLabel - ${appointment != null ? 'Cita asignada' : 'Disponible'}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (appointment != null)
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black45),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PetDetailsScreen(petId: appointment['petId']),
                            ),
                          );
                        },
                      )
                    else
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryOrange,
                          side: BorderSide(color: primaryOrange.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        child: const Text('Asignar'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssignAppointmentScreen(
                                date: formattedDate,
                                slot: index,
                                petId: petId,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
