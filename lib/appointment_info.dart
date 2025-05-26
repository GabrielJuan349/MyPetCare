import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lis_web/schedule.dart';

class AppointmentInfo extends StatefulWidget {
  final String date, time;

  const AppointmentInfo({super.key, required this.date, required this.time});

  @override
  State<AppointmentInfo> createState() => _AppointmentInfoState();
}

class _AppointmentInfoState extends State<AppointmentInfo> {
  final primaryOrange = Colors.orange;
  late final lightOrange, borderOrange;

  final TextEditingController timeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    lightOrange = primaryOrange.withOpacity(0.1);
    borderOrange = primaryOrange.withOpacity(0.2);
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Colors.white;

    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F6F6),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            'Detalles cita',
            style: GoogleFonts.inter(
              color: Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: _buildAppointmentInfo(widget.date, widget.time));
  }

  Widget _buildAppointmentInfo(String date, String time) {
    final startOfDay = DateFormat('dd/MM/yyyy').parse(date);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .where('time', isEqualTo: time)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return const Center(child: Text('Error cargando la cita'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No se ha encontrado la cita'));
        }

        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        print(data);
        final formattedDate =
            DateFormat('dd/MM/yyyy').format((data['date'].toDate()));

        timeController.text = data['time'];
        dateController.text = formattedDate;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField('Mascota', data['petName'], true),
                    _buildField('Clínica', data['clinicName'], true),
                    _buildField('Veterinario', data['vetName'], true),
                    _buildChangableField('Fecha', dateController, true),
                    _buildChangableField('Hora', timeController, true),
                    _buildField('Tipo', data['type'], true),
                    _buildField('Razón', data['reason'], true),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ScheduleScreen(
                                              appointmentId: doc.id,
                                            ))).then((dateAndTime) {
                                  print(
                                      "Datime values in info are: $dateAndTime");

                                  if (dateAndTime != null &&
                                      dateAndTime.length == 3) {
                                    _reAssignAppointment(dateAndTime);
                                    // Go back
                                  } else {
                                    print("No se guardo ningun valor");
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Reasignar cita',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _confirmCancelAppointment(context, doc.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancelar cita',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reAssignAppointment(data) async {
    // Form date to Timestamp
    final String appointmentId = data[1];
    print("Inside reassign is: $appointmentId");
    final DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(data[2]);
    print("Cita reasignada a: $parsedDate - ${data[0]}");
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .update({
      'date': parsedDate,
      'time': data[0],
    });
    print("Cita reasignada a: $parsedDate - ${data[1]}");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Cita reasignada a: $parsedDate - ${data[1]}"),
    ));
    Navigator.pop(context);
  }

  void _confirmCancelAppointment(BuildContext context, String appointmentId) {
    print("Inside cancel appointment appointmentId is: $appointmentId");
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Cancel Appointment'),
              content: const Text(
                  'Are you sure you want to cancel this appointment?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _cancelAppointment(appointmentId);
                    Navigator.pop(context);
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }

  Widget _buildField(String label, String value, bool isReadOnly) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
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

  Widget _buildChangableField(
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
          TextFormField(
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
}
