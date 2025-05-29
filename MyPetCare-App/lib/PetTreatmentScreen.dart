import 'package:flutter/material.dart';
import 'package:lis_project/requests.dart';
import 'package:intl/intl.dart';

class PetTreatmentsScreen extends StatelessWidget {
  final String petId;

  const PetTreatmentsScreen({super.key, required this.petId});

  Future<List<dynamic>> fetchTreatments() async {
    return await getTreatmentsByPet(petId); // Usa tu endpoint aquí
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatments'),
        backgroundColor: const Color(0xfff59249),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchTreatments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading treatments"));
          }

          final treatments = snapshot.data ?? [];

          if (treatments.isEmpty) {
            return const Center(child: Text("No treatments found."));
          }

          return ListView.builder(
            itemCount: treatments.length,
            itemBuilder: (context, index) {
              final treatment = treatments[index];
              return ListTile(
                title: Text(treatment['name'] ?? 'No name'),
                subtitle: Text(
                  'From ${_formatDate(treatment['date_start'])} to ${_formatDate(treatment['date_end'])}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatDate(String isoString) {
  final date = DateTime.parse(isoString);
  return DateFormat('yyyy-MM-dd').format(date);
}
