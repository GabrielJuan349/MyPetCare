import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'prescription.dart';

import 'prescriptionDetails.dart';

class PrescriptionListScreen extends StatelessWidget {
  final String petId;

  const PrescriptionListScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Colors.white;
    final Color highlightColor = Colors.orange.withOpacity(0.5);
    final Color cardColor = const Color(0xFFF6F6F6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Recetas',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.orange,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        tooltip: 'Añadir receta',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PrescriptionUploadScreen(petId: petId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('prescription')
              .where('id_pet', isEqualTo: petId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final prescriptions = snapshot.data?.docs ?? [];

            if (prescriptions.isEmpty) {
              return Center(
                child: Text(
                  'No hay recetas registradas para esta mascota.',
                  style: GoogleFonts.inter(color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final doc = prescriptions[index];
                final data = doc.data() as Map<String, dynamic>;
                final name = data['name'] ?? 'Sin nombre';
                final createdAt = (data['createdAt'] as Timestamp).toDate();

                return Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: highlightColor.withOpacity(0.3)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Colors.orange),
                    title: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'Fecha: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.orange),
                      tooltip: 'Eliminar receta',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text('¿Estás segura de que quieres eliminar esta receta?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await FirebaseFirestore.instance.collection('prescription').doc(doc.id).delete();
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PrescriptionDetailsScreen(
                            prescriptionId: doc.id,
                            petId: petId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );

          },
        ),
      ),
    );
  }
}
