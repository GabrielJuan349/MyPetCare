import 'package:flutter/material.dart';
import 'clinic.dart';

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
            SizedBox(height: 20),
            Text(
              'Coordenadas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Lat: ${clinic.latitude}'),
            Text('Lng: ${clinic.longitude}'),
            SizedBox(height: 30)

          ],
        ),
      ),
    );
  }
}
