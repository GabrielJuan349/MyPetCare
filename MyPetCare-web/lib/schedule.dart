import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'daily_schedule.dart';

class ScheduleScreen extends StatefulWidget {
  final String? petId;
  final String? appointmentId;

  const ScheduleScreen({super.key, this.petId, this.appointmentId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    const primaryOrange = Colors.orange;
    final lightOrange = primaryOrange.withOpacity(0.1);
    final borderOrange = primaryOrange.withOpacity(0.1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Agenda Semanal',
          style: GoogleFonts.inter(
            color: Colors.orange,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index));
          final weekday = _weekdayName(date.weekday);
          final formatted =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DayScheduleScreen(
                    date: date,
                    petId: widget.petId,
                    appointmentId: widget.appointmentId,
                  ),
                ),
              ).then((timeAndAppointmentId) {
                if (timeAndAppointmentId != null) {
                  String displayDate = DateFormat('dd/MM/yyyy').format(date);
                  timeAndAppointmentId.add(displayDate);
                  print("Date and time values are: $timeAndAppointmentId");
                  Navigator.pop(context, timeAndAppointmentId);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: lightOrange,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderOrange),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      date.day.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekday,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatted,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 16, color: Colors.black38),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _weekdayName(int weekday) {
    const names = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];
    return names[weekday - 1];
  }
}
