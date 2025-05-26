import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class Clients extends StatefulWidget {
  const Clients({super.key});

  @override
  State<Clients> createState() => _ClientsState();
}

class _ClientsState extends State<Clients> {
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
          Expanded(child: _buildClientsDataTable()),
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
              labelText: 'Search clients',
              labelStyle:
                  GoogleFonts.inter(color: Colors.black54, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color: _highlightColor.withOpacity(0.6), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: _highlightColor, width: 1.5),
              ),
              prefixIcon: Icon(Icons.search, color: _highlightColor),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            style: GoogleFonts.inter(color: Colors.black87, fontSize: 14),
            onChanged: (value) =>
                setState(() => _searchQuery = value.toLowerCase()),
          ),
        ),
      ),
    );
  }

  Widget _buildClientsDataTable() {
    if (globalClinicInfo == null) {
      return const Center(
          child: Text(
              'Error: no se ha podido cargar la información de la clínica.'));
    }
    print("The global clinic info is: $globalClinicInfo");
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('clinicInfo', isEqualTo: globalClinicInfo)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading clients'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('No clients found'));
        }

        final owners = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final isClient = data['accountType'] == 'owner' ||
              data['accountType'] == 'Pet owner' ||
              data['accountType'] == 'cliente';
          return isClient;
        }).toList();

        if (owners.isEmpty) {
          return const Center(child: Text('No clients found'));
        }

        final screenWidth = MediaQuery.of(context).size.width;

        return SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: screenWidth,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(_highlightColor),
                columns: [
                  DataColumn(
                    label: Text('Name',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('User ID',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Clinic',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Email',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                  DataColumn(
                    label: Text('Phone',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: owners.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name =
                      '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}';

                  return DataRow(
                    cells: [
                      DataCell(Text(name, style: GoogleFonts.inter())),
                      DataCell(Text(doc.id ?? '', style: GoogleFonts.inter())),
                      DataCell(Text(data['clinicInfo'] ?? '',
                          style: GoogleFonts.inter())),
                      DataCell(Text(data['email'] ?? '',
                          style: GoogleFonts.inter())),
                      DataCell(Text(data['phone'] ?? '',
                          style: GoogleFonts.inter())),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
