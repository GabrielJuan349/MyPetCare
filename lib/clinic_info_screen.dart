import 'package:flutter/material.dart';
import 'data.dart';

class ClinicInfoScreen extends StatelessWidget {
  final Clinic clinic;

  const ClinicInfoScreen({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff59249),
        foregroundColor: Colors.white,
        title: const Text('Clinic Info'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              clinic.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(child: Text(clinic.address)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.grey),
                const SizedBox(width: 8),
                Text(clinic.phone),
              ],
            ),
            const SizedBox(height: 10),
            Text('Website: ${clinic.website}'),
            const SizedBox(height: 20),
            const Text(
              'Coordenadas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Lat: ${clinic.latitude}'),
            Text('Lng: ${clinic.longitude}'),
<<<<<<< Updated upstream
            SizedBox(height: 30)

=======
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ClinicAdoptionsScreen(clinicId: clinic.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff59249),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text(
                  'Ver adopciones',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
>>>>>>> Stashed changes
          ],
        ),
      ),
    );
  }
}
