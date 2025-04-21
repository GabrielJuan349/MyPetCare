import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lis_project/reminder_message.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<Reminder> reminders = [
    Reminder("Reminder 1", "Info about the reminder", DateTime(2025, 6, 10)),
    Reminder("Reminder 2", "Info about the reminder", DateTime(2025, 7, 3)),
    Reminder("Reminder 3", "Info about the reminder", DateTime(2025, 8, 1)),
  ];

  Widget _buildDateContainer(DateTime date) {
    String month = DateFormat('MMM').format(date)[0].toUpperCase() +
        DateFormat('MMM').format(date).substring(1);
    String day = DateFormat('dd').format(date);

    return Container(
      width: 60,
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF627ECB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(month, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminders"),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: const Color(0xfff59249),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE9EFFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildDateContainer(reminder.date),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reminder.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(reminder.summary, style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
