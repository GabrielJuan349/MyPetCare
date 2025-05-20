import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ClinicAdoptionsScreen extends StatefulWidget {
  final String clinicId;

  const ClinicAdoptionsScreen({super.key, required this.clinicId});

  @override
  State<ClinicAdoptionsScreen> createState() => _ClinicAdoptionsScreenState();
}

class _ClinicAdoptionsScreenState extends State<ClinicAdoptionsScreen> {
  List<Map<String, dynamic>> adoptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAdoptions();
  }

  Future<void> fetchAdoptions() async {
    final url = Uri.parse("http://localhost:6055/api/getAdoptionsByClinic/${widget.clinicId}");

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        setState(() {
          adoptions = List<Map<String, dynamic>>.from(json.decode(res.body));
          isLoading = false;
        });
      } else {
        throw Exception("Error del servidor");
      }
    } catch (e) {
      print("Error al obtener adopciones: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xfff59249),
        foregroundColor: Colors.white,
        title: Text('Clinic Adoptions'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : adoptions.isEmpty
              ? Center(child: Text('There are no adoptions available'))
              : ListView.builder(
                  itemCount: adoptions.length,
                  itemBuilder: (context, index) {
                    final adoption = adoptions[index];
                    return Card(
                      margin: EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adoption['name'] ?? 'unknown',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6),
                            Text("Type: ${adoption['type'] ?? 'unknown'}"),
                            Text("Age: ${adoption['age'] ?? 'N/A'} years old"),
                            Text("If you are interested in adopting, please contact the mail: ${adoption['email'] ?? 'unknown'}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
