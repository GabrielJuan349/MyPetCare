import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'appointment.dart';
import 'data.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xfff59249);
    final user = Provider.of<OwnerModel>(context, listen: false).owner!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Appointments",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {}); // Rebuild all the widget?
            },
            tooltip: 'Refresh appointments',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: _buildAppointmentList(user),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/calendar',
          );
        },
        backgroundColor: appBarColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAppointmentList(Owner user) {
    return FutureBuilder(
        future: //getAppointmentsByUserId(user.firebaseUser.uid),
            getAppointmentsUserFromFirestore(user.firebaseUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text("We had an error loading "
                    "your appointments, please retry after"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appointments = snapshot.data ?? [];

          print(appointments);

          if (appointments.isEmpty) {
            return const Center(
                child: Text("You have no "
                    "appointments programmed yet"));
          }

          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];

              // If you return a map from Firestore, access fields like this:
              final date = appointment.date;
              final time = appointment.time;
              final reason = appointment.reason;
              final type = appointment.type;
              final petName = appointment.petName;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: const Color(0xFFE9EFFF),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.pets),
                  title: Text("$date at $time"),
                  subtitle: Text("$petName • $type\n$reason"),
                  trailing: IconButton(
                    onPressed: () {
                      _confirmCancelAppointment(context, appointment.id);
                    },
                    icon: const Icon(Icons.free_cancellation),
                    tooltip: "Cancel Appointment",
                  ),
                ),
              );
            },
          );
        });
  }

  void _confirmCancelAppointment(BuildContext context, String appointmentId) {
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
    setState(() {});
  }

  Future<List<dynamic>> getAppointmentsUserFromFirestore(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('ownerId', isEqualTo: userId)
          .orderBy('date')
          // Sort also with time => 00:00
          // string format is okay to sort
          .orderBy('time')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Appointment.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }
}
