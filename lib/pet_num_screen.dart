import 'package:flutter/material.dart';

class PetNumScreen extends StatefulWidget {
  final String petName;

  PetNumScreen({super.key, required this.petName});

  @override
  State<PetNumScreen> createState() => _PetNumScreenState();
}

class _PetNumScreenState extends State<PetNumScreen> {
  late String petName;

  @override
  void initState() {
    super.initState();
    petName = widget.petName;
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = Color(0xfff59249);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          petName,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildGridItem(context, Icons.info_outline, 'Pet details'),
            _buildGridItem(context, Icons.receipt_long_outlined, 'Reports'),
            _buildGridItem(context, Icons.medical_services_outlined, 'Medical prescriptions'),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE9EFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(16),
      child: InkWell(
        onTap: () {

        },
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Color(0xFF627ECB),
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF627ECB),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
