import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatelessWidget {
  final DateTime date;

  ScheduleScreen({required this.date});

  List<DateTime> _generateTimeSlots() {
    final List<DateTime> slots = [];
    DateTime start = DateTime(date.year, date.month, date.day, 8, 0);
    DateTime end = DateTime(date.year, date.month, date.day, 17, 0);

    while (start.isBefore(end) || start.isAtSameMomentAs(end)) {
      slots.add(start);
      start = start.add(Duration(minutes: 15));
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slots = _generateTimeSlots();
    final formatter = DateFormat.Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text("Horario - ${DateFormat.yMMMMd().format(date)}"),
      ),
      body: ListView.builder(
        itemCount: slots.length,
        itemBuilder: (context, index) {
          final time = slots[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ElevatedButton(
              onPressed: () {
                //TODO: HAY QUE CONECTARLO CON LA BASE DE DATOS.
                // Acción al seleccionar una hora
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hora seleccionada: ${formatter.format(time)}')),
                );
              },
              child: Text(formatter.format(time)),
            ),
          );
        },
      ),
    );
  }
}
