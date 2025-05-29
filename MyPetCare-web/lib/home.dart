import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'appointment.dart';
import 'edit_user.dart';
import 'clients.dart';
import 'patients.dart';
import 'schedule.dart';
import 'login.dart';
import 'main.dart';

class InboxAppointment {
  final String id;
  final String vetName;
  final DateTime date;
  final String petName;
  bool read;

  InboxAppointment({
    required this.id,
    required this.vetName,
    required this.date,
    required this.petName,
    this.read = false,
  });
}

List<InboxAppointment> inboxAppointments = [];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Color backgroundColor = const Color(0xFFF6F6F6);
  final Color highlightColor = Colors.orange;

  int selectedIndex = 0;
  final List<String> labels = ['HOME', 'CLIENTS', 'PATIENTS', 'SCHEDULE'];

  final List<Widget> pages = const [
    HomeContent(),
    Clients(),
    Patients(),
    ScheduleScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _listenToAppointments();
  }

  void _listenToAppointments() {
    FirebaseFirestore.instance
        .collection('appointments')
        .where('vetName', isEqualTo: globalVetName)
        .where('date', isGreaterThan: Timestamp.now())
        .snapshots()
        .listen((snapshot) {
      setState(() {
        inboxAppointments = snapshot.docs.map((doc) {
          final data = doc.data();
          return InboxAppointment(
            id: doc.id,
            vetName: data['vetName'],
            date: (data['date'] as Timestamp).toDate(),
            petName: data['petName'] ?? 'Unknown Pet',
          );
        }).toList();
      });
    });
  }

  void onMenuTap(int index) => setState(() => selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: selectedIndex == 0
          ? HomeContent(
              onInboxUpdate: () => setState(() {}),
            )
          : pages[selectedIndex],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      toolbarHeight: 80,
      title: Row(
        children: [
          Image.asset('assets/LogoSinFondoOrange.png', height: 45),
          const SizedBox(width: 12),
          _buildTitle(),
          const Spacer(),
          _buildMenu(),
          const SizedBox(width: 20),
          _buildProfileMenu(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
            children: [
              const TextSpan(text: 'My', style: TextStyle(color: Colors.black)),
              TextSpan(text: 'Pet', style: TextStyle(color: highlightColor)),
              const TextSpan(
                  text: 'Care', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
        Text(
          'Pet Healthcare Management',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenu() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        final nameOrEmail =
            snapshot.data?.get('firstName') ?? currentUser.email ?? 'Perfil';
        return PopupMenuButton<String>(
          icon:
              const Icon(Icons.account_circle, color: Colors.orange, size: 30),
          onSelected: (value) async {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditUserScreen()),
              );
            }
            if (value == 'logout') {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'name',
              enabled: false,
              child: Text('Hola, $nameOrEmail',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
                value: 'edit', child: Text('Editar usuario')),
            const PopupMenuItem<String>(
                value: 'logout', child: Text('Cerrar sesión')),
          ],
        );
      },
    );
  }

  Widget _buildMenu() {
    return Row(
      children: List.generate(labels.length, (index) {
        final bool isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onMenuTap(index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? highlightColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                labels[index],
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : highlightColor,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class HomeContent extends StatefulWidget {
  final VoidCallback? onInboxUpdate;

  const HomeContent({super.key, this.onInboxUpdate});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<InboxAppointment> inboxAppointments = [];

  @override
  void initState() {
    super.initState();
    _listenToAppointments();
  }

  void _listenToAppointments() {
    FirebaseFirestore.instance
        .collection('appointments')
        .where('vetName', isEqualTo: globalVetName)
        .where('date', isGreaterThan: Timestamp.now())
        .snapshots()
        .listen((snapshot) {
      setState(() {
        inboxAppointments = snapshot.docs.map((doc) {
          final data = doc.data();
          return InboxAppointment(
            id: doc.id,
            vetName: data['vetName'],
            date: (data['date'] as Timestamp).toDate(),
            petName: data['petName'] ?? 'Unknown',
          );
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const HeaderImage(),
          _buildHomeLayout(),
        ],
      ),
    );
  }

  Widget _buildCardHome(String text, {Widget? body}) {
    return Card(
      color: Colors.white70,
      shadowColor: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.orange.shade300,
              child: Text(
                "Today's $text",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              height: 400,
              color: Colors.grey.shade100,
              child: Center(
                child: body ?? Text('No $text yet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeLayout() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: _buildCardHome('appointments',
                  body: Builder(
                      builder: (context) => _buildTodaysAppointmentList()))),
          const SizedBox(width: 20),
          Expanded(child: _buildInboxCard()),
        ],
      ),
    );
  }

  Widget _buildTodaysAppointmentList() {
    return FutureBuilder(
        future: getAppointmentsClinicFromFirestore(),
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
                ),
              );
            },
          );
        });
  }

  Future<List<dynamic>> getAppointmentsClinicFromFirestore() async {
    try {
      // Get clinic name from vet
      final currentUser = FirebaseAuth.instance.currentUser;
      final vetInfo = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get();

      String clinicName = vetInfo.data()?['clinicInfo'];
      print("Clinic info: $clinicName");
      DateTime today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final appointmentSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('clinicName', isEqualTo: clinicName)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .orderBy('date')
          .orderBy('time')
          .get();
      return appointmentSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Useful to cancel/delete after the appointment
        return Appointment.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error loading appointments $e");
      return [];
    }
  }

  String _formatDate(dynamic date) {
    DateTime dateTime;

    if (date is String) {
      dateTime = DateTime.parse(date);
    } else if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'Fecha inválida';
    }

    // Devuelve solo la fecha (ej. 2025-05-25)
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }


  Widget _buildInboxCard() {
    final unreadAppointments = inboxAppointments.where((a) => !a.read).toList();

    return Card(
      color: Colors.white70,
      shadowColor: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.orange.shade300,
              child: const Text(
                "Inbox",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              height: 400,
              color: Colors.grey.shade100,
              child: unreadAppointments.isEmpty
                  ? const Center(child: Text('No messages'))
                  : ListView.builder(
                      itemCount: unreadAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = unreadAppointments[index];

                        return ListTile(
                          title:
                              Text('Appointment with ${appointment.petName}'),
                          subtitle: Text('Date: ${_formatDate(appointment.date)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green),
                            onPressed: () {
                              setState(() {
                                appointment.read = true;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderImage extends StatelessWidget {
  const HeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 400,
          width: double.infinity,
          child: Image.asset(
            'assets/web_imagen.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.5),
          ),
        ),
        Container(
            height: 400,
            width: double.infinity,
            color: Colors.black.withOpacity(0.35)),
        Positioned(
          left: 20,
          top: 120,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.75)),
            child: Text(
              'WELCOME TO MYPETCARE!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Revolutionizing Pet Healthcare\nManagement',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
