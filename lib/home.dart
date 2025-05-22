import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'clients.dart';
import 'patients.dart';
import 'schedule.dart';
import 'login.dart';

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

  void onMenuTap(int index) => setState(() => selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: pages[selectedIndex],
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
              const TextSpan(text: 'Care', style: TextStyle(color: Colors.black)),
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
      future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
      builder: (context, snapshot) {
        final nameOrEmail = snapshot.data?.get('firstName') ?? currentUser.email ?? 'Perfil';

        return PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle, color: Colors.orange, size: 30),
          onSelected: (value) async {
            if (value == 'logout') {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
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
              value: 'logout',
              child: Text('Cerrar sesión'),
            ),
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

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

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

  Widget _buildCardHome(String text) {
    return Card(
      color: Colors.white70,
      shadowColor: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
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

            // Body
            Container(
              height: 400,
              color: Colors.grey.shade100,
              child: Center(
                child: Text('No $text yet'),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildCardHome('appointments')),
          const SizedBox(width: 20),
          Expanded(child: _buildCardHome('Arrivals')),
        ],
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
          color: Colors.black.withOpacity(0.35),
        ),
        Positioned(
          left: 20,
          top: 120,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.75),
            ),
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
