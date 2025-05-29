import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'addTreatment.dart';
import 'treatmentDetails.dart';

class TreatmentFormScreen extends StatelessWidget {
  final String petId;

  const TreatmentFormScreen({super.key, required this.petId});

  Future<void> _deleteTreatment(String docId) async {
    await FirebaseFirestore.instance.collection('treatment').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        title: Text(
          'Tratamientos',
          style: GoogleFonts.inter(color: Colors.orange, fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('treatment')
              .where('id_pet', isEqualTo: petId)
              .orderBy('date_start', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error cargando tratamientos'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return const Text('No hay tratamientos asignados.');
            }

            return ListView(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final dateStart = (data['date_start'] as Timestamp).toDate();
                final dateEnd = (data['date_end'] as Timestamp).toDate();
                final now = DateTime.now();
                final isExpired = dateEnd.isBefore(now);

                return Card(
                  color: const Color(0xFFF6F6F6),
                  elevation: 3,
                  shadowColor: Colors.orange.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.orange.withOpacity(0.3), width: 1),
                  ),
                  child: ListTile(
                    title: Text(
                      data['name'],
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Desde: ${DateFormat('dd/MM/yyyy').format(dateStart)}\nHasta: ${DateFormat('dd/MM/yyyy').format(dateEnd)}',
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TreatmentDetailsScreen(
                            treatmentId: doc.id,
                            treatmentData: data,
                          ),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isExpired)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Renovar',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddTreatmentScreen(
                                    petId: petId,
                                    treatmentNameToRenew: data['name'],
                                  ),
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete ,color: Colors.orange),
                          tooltip: 'Eliminar',
                          onPressed: () => _deleteTreatment(doc.id),
                        ),
                      ],
                    ),
                  ),
                );

              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTreatmentScreen(petId: petId),
            ),
          );
        },
        backgroundColor: Colors.orange.withOpacity(0.85),
        child: const Icon(Icons.add),
      ),
    );
  }
}
