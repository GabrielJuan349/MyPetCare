import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lis_web/report_list.dart';

import 'prescriptionList.dart';
import 'schedule.dart';
import 'treatment.dart';


class PetDetailsScreen extends StatelessWidget {
  final String petId;

  const PetDetailsScreen({required this.petId, super.key});

  @override
  Widget build(BuildContext context) {
    final Color highlightColor = Colors.orange.withOpacity(0.5);
    const Color backgroundColor = Colors.white;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('pets').doc(petId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(

              backgroundColor: backgroundColor,
              iconTheme: const IconThemeData(color: Colors.black87),
              title: Text(
                'Detalle de mascota',
                style: GoogleFonts.inter(color: Colors.black87),
              ),
              elevation: 0,
            ),
            body: const Center(child: Text('No se encontró la mascota')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: const Color(0xFFF6F6F6),
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text(
              data['name'] ?? 'Mascota',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.orange,
              ),
            ),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Información de la mascota',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: highlightColor.withOpacity(0.3)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Nombre', data['name']),
                      _buildInfoRow('Raza', data['breed']),
                      _buildInfoRow('Edad', '${data['age'] ?? 'N/A'} años'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Acciones disponibles',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 16),
                _buildStyledButton(
                  context,
                  label: 'Generar informe',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportsListScreen(petId: petId),
                      ),
                    );
                  },
                  color: highlightColor,
                ),
                _buildStyledButton(
                  context,
                  label: 'Programar cita',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScheduleScreen(petId: petId),
                      ),
                    );
                  },
                  color: highlightColor,
                ),
                _buildStyledButton(
                  context,
                  label: 'Tratamiento',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TreatmentFormScreen(petId: petId),
                      ),
                    );
                  },
                  color: highlightColor,
                ),
                _buildStyledButton(
                  context,
                  label: 'Recetas',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PrescriptionListScreen(petId: petId),
                      ),
                    );

                  },
                  color: highlightColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton(
      BuildContext context, {
        required String label,
        required VoidCallback onPressed,
        required Color color,
      }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
