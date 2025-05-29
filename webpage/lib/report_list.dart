import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'report.dart';
import 'reportDetails.dart';

class ReportsListScreen extends StatefulWidget {
  final String petId;

  const ReportsListScreen({super.key, required this.petId});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final Color _backgroundColor = Colors.white;
  final Color _highlightColor = Colors.orange.withOpacity(0.50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Informes de la mascota',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.orange,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: _buildReportsList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _highlightColor.withOpacity(0.9),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportFormScreen(petId: widget.petId),
            ),
          ).then((_) => setState(() {}));
        },
      ),
    );
  }

  Widget _buildReportsList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadReportsForPet(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text(
                'Error cargando informes: ${snapshot.error}',
                style: GoogleFonts.inter(color: Colors.black87),
              ));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final reports = snapshot.data!;
        if (reports.isEmpty) {
          return Center(
              child: Text(
                'No hay informes para esta mascota.',
                style: GoogleFonts.inter(color: Colors.black87),
              ));
        }

        return ListView.separated(
          itemCount: reports.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final report = reports[index];
            final createdAt = (report['createdAt'] as Timestamp?)?.toDate();
            final createdAtStr = createdAt != null
                ? '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}'
                : 'Fecha desconocida';

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _highlightColor.withOpacity(0.3)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const Icon(Icons.description_outlined, color: Colors.orange ),
                title: Text(
                  createdAtStr,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.orange),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Eliminar informe'),
                        content: const Text('¿Estás segura de que quieres eliminar este informe?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancelar'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: const Text('Eliminar'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection('report')
                          .doc(report['id'])
                          .delete();
                      setState(() {});
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportDetailsScreen(
                        reportId: report['id'],
                        reportText: report['reportText'],
                        createdAt: createdAtStr,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadReportsForPet() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('report')
          .where('petId', isEqualTo: widget.petId)
          .orderBy('createdAt', descending: true)
          .get();

      final reports = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'reportText': data['reportText'] ?? '',
          'createdAt': data['createdAt'],
        };
      }).toList();

      return reports;
    } catch (e) {
      print('Error al cargar informes: $e');
      return [];
    }
  }
}
