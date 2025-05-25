import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'data.dart';
import 'add_appointment_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendario"),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: const Color(0xfff59249),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {}); // Rebuild all the widget?
            },
            tooltip: 'Refresh calendar',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TableCalendar(
              firstDay: DateTime.now(),
              // Only can book from today
              lastDay: DateTime.now().add(const Duration(
                  // To next two weeks: today(1)+13 = 14(2 weeks)
                  days: 13)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                'Franjas horarias disponibles',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _selectedDay != null
              ? Expanded(
                  child: _buildTimeSlots(_selectedDay!),
                )
              : const Expanded(
                  child: Center(
                    child: Text(
                        "Seleccione un día para ver los horarios disponibles."),
                  ),
                )
        ],
      ),
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
    while(start.isBefore(end)){
      final h = start.hour.toString().padLeft(2, '0');
      final m = start.minute.toString().padLeft(2, '0');
      timeSlots.add('$h:$m');
      start = start.add(const Duration(minutes: 15));
    }

    return timeSlots;
  }


  Future<Map<String, List>> getAvailabilityList( DateTime date) async {
    final user = Provider.of<OwnerModel>(context, listen: false).owner!;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    // final bookedSlots = await getAppointmentsByClinicId(clinicId, date);
    try{
      // Get clinic start and end hour
      print("name is ${user.clinicInfo}");
      final clinicQuery = await FirebaseFirestore.instance
          .collection('clinic')
          .where('name', isEqualTo: user.clinicInfo)
          .get();
      // If sure that name is unique and only will return one doc
      final data = clinicQuery.docs.first.data();
      final startHour = data['startHour'];
      final endHour = data['endHour'];
      List<String> allSlots = getTimeSlots(startHour, endHour);
      final appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('clinicName', isEqualTo: user.clinicInfo)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .get();

      final bookedSlots = appointmentSnapshot.docs
          .map((doc) => doc['time'] as String)
          .toList();
      // true = available, false = booked
      final availability =  allSlots.map((slot) => !bookedSlots.contains(slot)).toList();
      return {
        'allSlots': allSlots,
        'availability': availability,
      };
    }catch(e){
      print("Error getting time slots: $e");
    }

    return {
      'allSlots': [],
      'availability': [],
    };
  }

  // Show time slots, according the clinic working hours
  Widget _buildTimeSlots(DateTime date) {

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
            return const  Center(
                child: Text("The clinic has not set time slots"));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of columns
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.5,
            ),
            padding: const EdgeInsets.all(8),
            itemCount: availableSlots.length,
            itemBuilder: (context, index) {
              final time = allSlots[index];
              final isAvailable = availableSlots[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: GestureDetector(
                  onTap: isAvailable
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Hora seleccionada: $time")),
                          );
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewAppointmentScreen(
                                    selectedDate: _selectedDay!,
                                    selectedTime: time),
                              ));
                        }
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("La hora seleccionada: $time "
                                    "no está disponible")),
                          );
                        },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.shade100
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAvailable ? Colors.green : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color:
                            isAvailable ? Colors.black : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
