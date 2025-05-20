import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'clients.dart';
import 'patients.dart';
import 'schedule.dart';

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
            child: Text(
              labels[index],
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : highlightColor,
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

  @override
  Widget build(BuildContext context) {
    return const Column(children: [HeaderImage()]);
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
