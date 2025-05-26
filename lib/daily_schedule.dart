import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lis_web/appointment_info.dart';
import 'assign_appointment.dart';

class DayScheduleScreen extends StatefulWidget {
  final DateTime date;
  final String? petId;
  final String? appointmentId;

  const DayScheduleScreen(
      {required this.date, this.petId, Key? key, this.appointmentId})
      : super(key: key);

  @override
  State<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends State<DayScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    final displayDate = DateFormat('dd/MM/yyyy').format(widget.date);
    final primaryOrange = Colors.orange;

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
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  // To refresh actual page
                });
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: _buildTimeSlots(widget.date),
    );
  }

  List<String> getTimeSlots(String startTime, String endTime) {
    List<String> timeSlots = [];

    final startParts = startTime.split(':').map(int.parse).toList();
    final endParts = endTime.split(':').map(int.parse).toList();

    // 09:00 => [0] = 09, [1] = 00
    // https://api.dart.dev/dart-core/DateTime/DateTime.html
    DateTime start = DateTime(0, 1, 1, startParts[0], startParts[1]);
    final end = DateTime(0, 1, 1, endParts[0], endParts[1]);

    // 10:02 => (15 - (02%15) % 15) = 13 --> 13 + 02 = 15
    int minutesToAdd = (15 - (start.minute % 15)) % 15;
    if (minutesToAdd > 0) {
      start = start.add(Duration(minutes: minutesToAdd));
    }

    // https://stackoverflow.com/questions/15193983/is-there-a-built-in-method-to-pad-a-string
    while (start.isBefore(end)) {
      final h = start.hour.toString().padLeft(2, '0');
      final m = start.minute.toString().padLeft(2, '0');
      timeSlots.add('$h:$m');
      start = start.add(const Duration(minutes: 15));
    }

    return timeSlots;
  }

  Future<Map<String, List>> getAvailabilityList(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    // final bookedSlots = await getAppointmentsByClinicId(clinicId, date);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final user = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      // Get clinic start and end hour
      final clinicName = user.data()?['clinicInfo'];
      print(clinicName);
      print("name is $clinicName");
      final clinicQuery = await FirebaseFirestore.instance
          .collection('clinic')
          .where('name', isEqualTo: clinicName)
          .get();
      // If sure that name is unique and only will return one doc
      final data = clinicQuery.docs.first.data();
      final startHour = data['startHour'];
      final endHour = data['endHour'];
      List<String> allSlots = getTimeSlots(startHour, endHour);
      final appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('clinicName', isEqualTo: clinicName)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .get();

      final bookedSlots =
          appointmentSnapshot.docs.map((doc) => doc['time'] as String).toList();
      // true = available, false = booked
      final availability =
          allSlots.map((slot) => !bookedSlots.contains(slot)).toList();
      print("Availability: $availability");
      print("Booked slots: $bookedSlots");
      return {
        'allSlots': allSlots,
        'availability': availability,
      };
    } catch (e) {
      print("Error getting time slots: $e");
    }

    return {
      'allSlots': [],
      'availability': [],
    };
  }

  Widget _buildTimeSlots(DateTime date) {
    final primaryOrange = Colors.orange;
    final lightOrange = primaryOrange.withOpacity(0.1);
    final borderOrange = primaryOrange.withOpacity(0.1);

    return FutureBuilder(
        future: getAvailabilityList(date),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text("We had an error loading available time slots, "
                    "please retry after"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final availableSlots = snapshot.data?['availability'] ?? [];
          final allSlots = snapshot.data?['allSlots'] ?? [];

          if (availableSlots.isEmpty) {
            return const Center(
                child: Text("La clinica aún no ha establecido horarios"));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: availableSlots.length,
            itemBuilder: (context, index) {
              final time = allSlots[index];
              final isAvailable = availableSlots[index];

              return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isAvailable ? lightOrange : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderOrange),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 20, color: primaryOrange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$time - ${isAvailable ? 'Disponible' : 'Cita asignada'}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      isAvailable
                          ? OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryOrange,
                                side: BorderSide(
                                    color: primaryOrange.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                textStyle: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500),
                              ),
                              child: const Text('Asignar'),
                              onPressed: () {
                                if (widget.appointmentId != null) {
                                  // Return time
                                  print("appointmentId es: $time");
                                  List<String> timeAndAppointmentId = [];
                                  timeAndAppointmentId.add(time);
                                  timeAndAppointmentId.add(widget.appointmentId!);
                                  Navigator.pop(context, timeAndAppointmentId);
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AssignAppointmentScreen(
                                          date: DateFormat('dd/MM/yyyy')
                                              .format(date),
                                          time: time,
                                        ),
                                      ));
                                }
                              },
                            )
                          : IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 16, color: Colors.black45),
                              onPressed: () {
                                final displayDate =
                                    DateFormat('dd/MM/yyyy').format(date);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AppointmentInfo(
                                            date: displayDate, time: time)));
                              },
                            )
                    ],
                  ));
            },
          );
        });
  }
}
