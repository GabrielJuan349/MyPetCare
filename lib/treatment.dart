import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TreatmentFormScreen extends StatefulWidget {
  final String petId;

  const TreatmentFormScreen({super.key, required this.petId});

  @override
  State<TreatmentFormScreen> createState() => _TreatmentFormScreenState();
}

class _TreatmentFormScreenState extends State<TreatmentFormScreen> {
  final TextEditingController _treatmentController = TextEditingController();
  final int durationDays = 30;

  Future<void> _addTreatment(String name) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: durationDays));

    await FirebaseFirestore.instance.collection('treatment').add({
      'id_pet': widget.petId,
      'id_vet': 'default_vet', // no tengo claro como recibirlo, creo que no esta implementado el login
      'name': name,
      'date_start': Timestamp.fromDate(now),
      'date_end': Timestamp.fromDate(endDate),
      'createdAt': Timestamp.now(),
    });

    _treatmentController.clear();

  }

  Future<void> _deleteTreatment(String docId) async {
    await FirebaseFirestore.instance.collection('treatment').doc(docId).delete();
  }



  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
          backgroundColor: const Color(0xFFF6F6F6),
          elevation: 0,
          title: const Text('Tratamientos'),
          foregroundColor: Colors.orange

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('treatment')
                    .where('id_pet', isEqualTo: widget.petId)
                    .orderBy('date_start', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error charging treatment'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();

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
                          color: const Color(0xFFFFF2D6),
                        shadowColor: Colors.orange,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            style: const TextStyle(
                                fontWeight: FontWeight.bold
                            ),
                              data['name']
                          ),
                          subtitle: Text(
                            'Desde: ${DateFormat('dd/MM/yyyy').format(dateStart)}\nHasta: ${DateFormat('dd/MM/yyyy').format(dateEnd)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isExpired)
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Renovar',
                                  onPressed: () => _addTreatment(data['name']),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete),
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
            const Divider(),
            TextField(
              controller: _treatmentController,
              decoration: const InputDecoration(
                labelText: 'Nombre del tratamiento',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final name = _treatmentController.text.trim();
                if (name.isNotEmpty) {
                  _addTreatment(name);
                }
              },
              child: const Text('Añadir tratamiento'),
            ),
          ],
        ),
      ),
    );
  }
}