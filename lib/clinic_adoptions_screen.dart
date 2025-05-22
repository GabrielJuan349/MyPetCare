import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'adoption_details_screen.dart';
import 'requests.dart';

class ClinicAdoptionsScreen extends StatefulWidget {
  final String clinicId;

  const ClinicAdoptionsScreen({super.key, required this.clinicId});

  @override
  State<ClinicAdoptionsScreen> createState() => _ClinicAdoptionsScreenState();
}

class _ClinicAdoptionsScreenState extends State<ClinicAdoptionsScreen> {
  List<Map<String, dynamic>> allAdoptions = [];
  List<Map<String, dynamic>> filteredAdoptions = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAdoptions();
    searchController.addListener(_filterAdoptions);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

Future<void> fetchAdoptions() async {
  try {
    final data = await getAdoptionsByClinic(widget.clinicId);
    setState(() {
      allAdoptions = data;
      filteredAdoptions = data;
      isLoading = false;
    });
  } catch (e) {
    print("Error al obtener adopciones: $e");
    setState(() {
      isLoading = false;
    });
  }
}


void _filterAdoptions() {
  final query = searchController.text.toLowerCase();
  setState(() {
    if (query.isEmpty) {
      filteredAdoptions = allAdoptions;
    } else {
      filteredAdoptions = allAdoptions.where((adoption) {
        final name = adoption['name']?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    }
  });
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
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: filteredAdoptions.isEmpty
                    ? Center(child: Text('No matching adoptions found'))
                    : ListView.builder(
                        itemCount: filteredAdoptions.length,
                        itemBuilder: (context, index) {
                          final adoption = filteredAdoptions[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdoptionDetailScreen(adoption: adoption),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
  );
}

}