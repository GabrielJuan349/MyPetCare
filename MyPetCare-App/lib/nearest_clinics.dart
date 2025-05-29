import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Import para geolocalización
import 'package:lis_project/data.dart';
import 'package:lis_project/clinic_info_screen.dart';
import 'package:lis_project/requests.dart';


class NearestClinicsScreen extends StatelessWidget {
  final List<Clinic> clinics;

  const NearestClinicsScreen({super.key, required this.clinics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clínicas más cercanas'),
        backgroundColor: const Color(0xfff59249),
      ),
      body: ListView.builder(
        itemCount: clinics.length,
        itemBuilder: (context, index) {
          final clinic = clinics[index];
          return ListTile(
            leading: const Icon(Icons.local_hospital, color: Colors.green),
            title: Text(clinic.name),
            subtitle: Text('Lat: ${clinic.latitude}, Lon: ${clinic.longitude}'),
            onTap: () {
              Navigator.pop(context, clinic); // Devuelve la clínica seleccionada
            },
          );
        },
      ),
    );
  }
}
