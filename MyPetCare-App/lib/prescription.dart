import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'requests.dart';

class Prescription {
  final String name;
  final String archivo;
  final String id;
  final String miligrams;

  Prescription(
      {required this.name,
      required this.archivo,
      required this.id,
      required this.miligrams});

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      name: json['name'],
      archivo: json['text'],
      id: json['id'],
      miligrams: json['milligrams'] ?? '',
    );
  }
}

class PrescriptionListPage extends StatefulWidget {
  final String petId;

  const PrescriptionListPage({super.key, required this.petId});

  @override
  State<PrescriptionListPage> createState() => _PrescriptionListPageState();
}

class _PrescriptionListPageState extends State<PrescriptionListPage> {
  late Future<List<Prescription>> prescriptionsFuture;
  Map<String, bool> showTextMap = {};

  @override
  void initState() {
    super.initState();
    prescriptionsFuture = fetchPrescriptions(widget.petId);
  }

  void toggleShowText(String id) {
    setState(() {
      showTextMap[id] = true;
    });

    Timer(const Duration(seconds: 10), () async {
      await deletePrescription(id);
      setState(() {
        showTextMap[id] = false;
        prescriptionsFuture = prescriptionsFuture.then(
          (prescriptions) => prescriptions.where((p) => p.id != id).toList(),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xfff59249);
    const cardColor = Color(0xFFE9EFFF);
    const textColor = Color(0xFF627ECB);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Prescriptions",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Prescription>>(
        future: prescriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: appBarColor));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No prescriptions found",
                style: TextStyle(color: textColor),
              ),
            );
          }

          final prescriptions = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              final showText = showTextMap[prescription.id] ?? false;

              return Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    prescription.name,
                    style: const TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: showText
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prescription.archivo,
                              style: const TextStyle(color: textColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Miligrams: ${prescription.miligrams}',
                              style: const TextStyle(
                                  color: textColor,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        )
                      : null,
                  onTap: () => toggleShowText(prescription.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
