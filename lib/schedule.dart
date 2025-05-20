import 'package:flutter/material.dart';
import 'daily_schedule.dart';

class ScheduleScreen extends StatelessWidget {
  final String? petId;

  const ScheduleScreen({Key? key, this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: index));
          return ListTile(
            title: Text('${date.day}/${date.month}/${date.year}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DayScheduleScreen(date: date, petId: petId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
