import 'package:flutter/material.dart';

class AdoptionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> adoption;

  const AdoptionDetailScreen({super.key, required this.adoption});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(adoption['name'] ?? 'Adoption Detail'),
        backgroundColor: Color(0xfff59249),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              adoption['name'] ?? 'Unknown',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Type: ${adoption['type'] ?? 'unknown'}"),
            Text("Age: ${adoption['age'] ?? 'N/A'} years old"),
            SizedBox(height: 10),
            Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(adoption['description'] ?? 'No description'),
            SizedBox(height: 10),
            Text("Found on: ${adoption['dateFound'] ?? 'N/A'}"),
            SizedBox(height: 10),
            Text("Contact email:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(adoption['email'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }
}
