import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Para geolocalización
import 'package:lis_project/data.dart';
import 'package:lis_project/clinic_info_screen.dart';
import 'package:lis_project/requests.dart';

// Pantalla para mostrar las clínicas más cercanas en lista
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
            subtitle: Text('Lat: ${clinic.latitude.toStringAsFixed(5)}, Lon: ${clinic.longitude.toStringAsFixed(5)}'),
            onTap: () {
              Navigator.pop(context, clinic); // Devuelve la clínica seleccionada
            },
          );
        },
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Clinic> clinics = [];

  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    fetchClinics();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Servicio de ubicación desactivado.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permiso de ubicación denegado');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permiso de ubicación denegado permanentemente');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentLocation!, 15);
    });
  }

  Future<void> fetchClinics() async {
    try {
      List<Clinic> fetchedClinics = await getAllClinics();
      setState(() {
        clinics = fetchedClinics;
      });
      if (clinics.isNotEmpty && _currentLocation == null) {
        _mapController.move(LatLng(clinics[0].latitude, clinics[0].longitude), 13);
      }
    } catch (e) {
      print("Error obteniendo clínicas: $e");
    }
  }

  final LatLng _defaultLocation = const LatLng(41.3825, 2.176944);

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

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const Distance distance = Distance();
    return distance(LatLng(lat1, lon1), LatLng(lat2, lon2));
  }

  // Obtener las 3 clínicas más cercanas ordenadas por distancia a _currentLocation
  List<Clinic> _getNearestClinics(int count) {
    if (_currentLocation == null || clinics.isEmpty) return [];

    final Distance distance = const Distance();

    List<Clinic> sortedClinics = List.from(clinics);
    sortedClinics.sort((a, b) {
      final da = distance(_currentLocation!, LatLng(a.latitude, a.longitude));
      final db = distance(_currentLocation!, LatLng(b.latitude, b.longitude));
      return da.compareTo(db);
    });

    return sortedClinics.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff59249),
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
          center: _currentLocation ?? _defaultLocation,
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
              if (_currentLocation != null)
                Marker(
                  point: _currentLocation!,
                  width: 40,
                  height: 40,
                  builder: (BuildContext context) =>
                      const Icon(Icons.my_location, color: Colors.blue),
                )
              else
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
              }),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'locationBtn',
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.move(_currentLocation!, 15);
              } else {
                _mapController.move(_defaultLocation, 15);
              }
            },
            child: const Icon(Icons.my_location),
            tooltip: "Ir a mi ubicación",
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'nearestListBtn',
            onPressed: () async {
              final nearestClinics = _getNearestClinics(3);
              if (nearestClinics.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ubicación o clínicas no disponibles')),
                );
                return;
              }
              final selectedClinic = await Navigator.push<Clinic>(
                context,
                MaterialPageRoute(
                  builder: (context) => NearestClinicsScreen(clinics: nearestClinics),
                ),
              );

              if (selectedClinic != null) {
                _mapController.move(
                  LatLng(selectedClinic.latitude, selectedClinic.longitude),
                  16,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClinicInfoScreen(clinic: selectedClinic),
                  ),
                );
              }
            },
            backgroundColor: Colors.orange,
            child: const Icon(Icons.list),
            tooltip: "Ver las 3 clínicas más cercanas",
          ),
        ],
      ),
    );
  }
}
