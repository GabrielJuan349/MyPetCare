import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lis_project/data.dart';
import 'package:lis_project/clinic_info_screen.dart';
import 'package:lis_project/requests.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Clinic> clinics = [];
  @override
  void initState() {
    super.initState();
    fetchClinics();
  }

  Future<void> fetchClinics() async {
    
    try {
      List<Clinic> fetchedClinics = await getAllClinics();
      setState(() {
        clinics = fetchedClinics;
      });
      if (clinics.isNotEmpty) {
        _mapController.move(
            LatLng(clinics[0].latitude, clinics[0].longitude), 13);
      }
    } catch (e) {
      print("Error obteniendo clínicas: $e");
    }
  }

  // Ubicación predeterminada
  final LatLng _defaultLocation = LatLng(41.3825, 2.176944);

  void _onMapTap(TapPosition tapPosition, LatLng latLng) {
    for (final clinic in clinics) {
      double distance = _calculateDistance(
        latLng.latitude,
        latLng.longitude,
        clinic.latitude,
        clinic.longitude,
      );
      if (distance < 50) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClinicInfoScreen(clinic: clinic),
          ),
        );
        break;
      }
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const Distance distance = Distance();
    return distance(LatLng(lat1, lon1), LatLng(lat2, lon2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff59249),
        title: const Text("Clinics Map", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _defaultLocation,
          zoom: 13,
          onTap: _onMapTap,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _defaultLocation,
                width: 40,
                height: 40,
                builder: (BuildContext context) =>
                    const Icon(Icons.my_location, color: Colors.blue),
              ),
              ...clinics.map((clinic) {
                return Marker(
                  point: LatLng(clinic.latitude, clinic.longitude),
                  width: 50,
                  height: 50,
                  builder: (BuildContext context) => const Icon(
                      Icons.local_hospital,
                      color: Colors.green,
                      size: 40),
                );
              }).toList(),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(_defaultLocation, 15);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
