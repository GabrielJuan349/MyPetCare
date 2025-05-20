import 'package:flutter/material.dart';
import 'data.dart';
import 'clinic_adoptions_screen.dart'; // Asegúrate de tener este archivo creado

class ClinicInfoScreen extends StatelessWidget {
  final Clinic clinic;

  const ClinicInfoScreen({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff59249),
        foregroundColor: Colors.white,
        title: Text('Clinic Info'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              clinic.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(child: Text(clinic.address)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey),
                SizedBox(width: 8),
                Text(clinic.phone),
              ],
            ),
            SizedBox(height: 10),
            Text('Website: ${clinic.website}'),
            SizedBox(height: 20),
            Text(
              'Coordenadas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Lat: ${clinic.latitude}'),
            Text('Lng: ${clinic.longitude}'),
            SizedBox(height: 30),
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
                  backgroundColor: Color(0xfff59249),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text(
                  'Ver adopciones',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
