import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pet_details.dart';

class Patients extends StatefulWidget {
  const Patients({super.key});

  @override
  State<Patients> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<Patients> {
  String _searchQuery = '';
  final Color _backgroundColor = Colors.white;
  final Color _highlightColor = Colors.orange.withOpacity(0.50);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSearchField(),
          const SizedBox(height: 12),
          Expanded(child: _buildPetsDataTable()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search pets',
              labelStyle: GoogleFonts.inter(color: Colors.black54, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: _highlightColor.withOpacity(0.6), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: _highlightColor, width: 1.5),
              ),
              prefixIcon: Icon(Icons.search, color: _highlightColor),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            style: GoogleFonts.inter(color: Colors.black87, fontSize: 14),
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          ),
        ),
      ),
    );
  }

  Widget _buildPetsDataTable() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadPetsWithOwners(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading pets: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final pets = snapshot.data!;
        final filteredPets = pets.where((pet) {
          final name = (pet['name'] ?? '').toLowerCase();
          final type = (pet['type'] ?? '').toLowerCase();
          final breed = (pet['breed'] ?? '').toLowerCase();
          final ownerName = (pet['ownerName'] ?? '').toLowerCase();

          return name.contains(_searchQuery) ||
              type.contains(_searchQuery) ||
              breed.contains(_searchQuery) ||
              ownerName.contains(_searchQuery);
        }).toList();

        if (filteredPets.isEmpty) {
          return const Center(child: Text('No pets found'));
        }

        return ListView(
          children: [
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              color: _highlightColor,
              child: Row(
                children: [
                  _buildHeaderCell('Name'),
                  _buildHeaderCell('Type'),
                  _buildHeaderCell('Breed'),
                  _buildHeaderCell('Owner'),
                ],
              ),
            ),
            const Divider(height: 0, thickness: 1),
            // Data rows
            ...filteredPets.map((pet) {
              return InkWell(
                onTap: () => _openPetDetails(pet['petId']),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      child: Row(
                        children: [
                          _buildDataCell(pet['name'] ?? ''),
                          _buildDataCell(pet['type'] ?? ''),
                          _buildDataCell(pet['breed'] ?? ''),
                          _buildDataCell(pet['ownerName'] ?? 'Unknown'),
                        ],
                      ),
                    ),
                    const Divider(height: 0, thickness: 0.5),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCell(String label) {
    return Expanded(
      flex: 1,
      child: Text(
        label,
        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDataCell(String value) {
    return Expanded(
      flex: 1,
      child: Text(
        value,
        style: GoogleFonts.inter(),
      ),
    );
  }

  void _openPetDetails(String petId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PetDetailsScreen(petId: petId),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _loadPetsWithOwners() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final petsSnapshot = await FirebaseFirestore.instance.collection('pets').get();

      final usersByDocId = <String, String>{};
      for (var userDoc in usersSnapshot.docs) {
        final data = userDoc.data();
        final fullName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
        usersByDocId[userDoc.id] = fullName;
      }

      final petsWithOwners = petsSnapshot.docs.map((petDoc) {
        final data = petDoc.data();
        final ownerId = data['owner'];
        final ownerName = usersByDocId[ownerId] ?? 'Unknown';

        return {
          'petId': petDoc.id,
          'name': data['name'],
          'type': data['type'],
          'breed': data['breed'],
          'ownerName': ownerName,
        };
      }).toList();

      return petsWithOwners;
    } catch (e) {
      print('Error loading data: $e');
      return [];
    }
  }
}
