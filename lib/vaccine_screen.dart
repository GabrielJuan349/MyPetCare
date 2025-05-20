import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VaccineScreen extends StatefulWidget {
  final String petId;

  const VaccineScreen({super.key, required this.petId});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  List<dynamic> vaccines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVaccines();
  }

  Future<void> fetchVaccines() async {
    final uri = Uri.parse('http://localhost:6055/api/getVaccineByPetID/pet/${widget.petId}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          vaccines = data;
          isLoading = false;
        });
      } else {
        throw Exception('Error en la respuesta del servidor');
      }
    } catch (e) {
      print('Error al obtener vacunas: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildVaccineCard(dynamic vaccine) {
    String date = vaccine['Date'] ?? 'Sin fecha';
    String name = vaccine['name'] ?? 'Sin nombre';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF627ECB))),
            const SizedBox(height: 8),
            Text(date,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vacunas'),
        backgroundColor: const Color(0xfff59249),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vaccines.isEmpty
              ? const Center(child: Text('No hay vacunas registradas'))
              : ListView.builder(
                  itemCount: vaccines.length,
                  itemBuilder: (context, index) {
                    return buildVaccineCard(vaccines[index]);
                  },
                ),
    );
  }
}
