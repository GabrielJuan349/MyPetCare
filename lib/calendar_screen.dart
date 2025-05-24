import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'schedule_screen.dart';
import 'add_appointment_screen.dart';
import 'requests.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
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
        backgroundColor: Color(0xfff59249),
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
                  //TODO: Use here real data
                  child: _buildTimeSlots("clinic_123", _selectedDay!),
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

  List<String> getTimeSlots(int startHour, int endHour) {
    List<String> timeSlots = [];
    // https://stackoverflow.com/questions/15193983/is-there-a-built-in-method-to-pad-a-string
    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += 15) {
        final h = hour.toString().padLeft(2, '0');
        final m = minute.toString().padLeft(2, '0');
        timeSlots.add('$h:$m');
      }
    }
    return timeSlots;
  }

  Future<List<bool>> getAvailabilityList(
      List<String> allSlots, clinicId, date) async {
    final bookedSlots = await getAppointmentsByClinicId(clinicId, date);
    // true = available, false = booked
    return allSlots.map((slot) => !bookedSlots.contains(slot)).toList();
  }

  // Show time slots, according the clinic working hours
  Widget _buildTimeSlots(String clinicId, DateTime date) {
    // TODO: Make this dynamic
    final startHour = 9;
    final endHour = 17;
    List<String> allSlots = getTimeSlots(startHour, endHour);

    return FutureBuilder(
        future: getAvailabilityList(allSlots, clinicId, date),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text("We had an error loading available time slots, "
                    "please retry after"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final availableSlots = snapshot.data ?? [];

          if (availableSlots.isEmpty) {}

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of columns
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.5,
            ),
            padding: const EdgeInsets.all(8),
            itemCount: allSlots.length,
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
                          // TODO: Navigate to open form
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
