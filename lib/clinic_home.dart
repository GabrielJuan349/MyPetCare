import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicHomeScreen extends StatelessWidget {
  final String clinicName;

  const ClinicHomeScreen({super.key, required this.clinicName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        toolbarHeight: 80,
        title: Row(
          children: [
            Image.asset('assets/LogoSinFondoOrange.png', height: 45),
            const SizedBox(width: 12),
            _buildTitle(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderImage(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildVetList(clinicName),
            ),
          ],
        ),
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
            children: const [
              TextSpan(text: 'My', style: TextStyle(color: Colors.black)),
              TextSpan(text: 'Pet', style: TextStyle(color: Colors.orange)),
              TextSpan(text: 'Care', style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
        Text(
          'Welcome, $clinicName',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildVetList(String clinicName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('accountType', isEqualTo: 'vet')
          .where('clinicInfo', isEqualTo: clinicName)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final vets = snapshot.data?.docs ?? [];

        if (vets.isEmpty) {
          return const Center(
            child: Text(
              'No veterinarians assigned to this clinic yet.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vets.length,
          itemBuilder: (context, index) {
            final vet = vets[index].data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.orange),
                title: Text('${vet['firstName']} ${vet['lastName']}'),
                subtitle: Text('Email: ${vet['email']}\nPhone: ${vet['phone']}'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
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
          height: 350,
          width: double.infinity,
          child: Image.asset(
            'assets/web_imagen.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.5),
          ),
        ),
        Container(
          height: 350,
          width: double.infinity,
          color: Colors.black.withOpacity(0.35),
        ),
        Positioned(
          left: 20,
          top: 100,
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
                'Managing Your Clinic\'s Vets\nIn One Place',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
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
