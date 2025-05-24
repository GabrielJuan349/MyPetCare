import 'package:flutter/material.dart';
import 'package:lis_project/requests.dart';
import 'package:provider/provider.dart';

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
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, 'profile');
            },
          ),
        ],
      ),
      body: _buildAppointmentList(user),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/',
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
        future: getAppointmentsByUserId(user.firebaseUser.uid),
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
              final date = appointment['date'];
              final time = appointment['time'];
              final reason = appointment['reason'];
              final type = appointment['type'];
              final petName = appointment['pet'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.pets),
                  title: Text("$date at $time"),
                  subtitle: Text("$petName • $type\n$reason"),
                ),
              );
            },
          );
        });
  }
}
