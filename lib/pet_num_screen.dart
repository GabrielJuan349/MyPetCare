import 'package:flutter/material.dart';
import 'package:lis_project/pet.dart';
import 'package:lis_project/pet_details.dart';
import 'package:lis_project/reports_screen.dart';
import 'package:lis_project/vaccine_screen.dart';
import 'package:lis_project/prescription.dart';

class PetNumScreen extends StatefulWidget {
  Pet myPet;

  PetNumScreen({super.key, required this.myPet});

  @override
  State<PetNumScreen> createState() => _PetNumScreenState();
}

class _PetNumScreenState extends State<PetNumScreen> {
  late Pet myPet;

  @override
  void initState() {
    super.initState();
    myPet = widget.myPet;
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xfff59249);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          myPet.name,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
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
            _buildGridItem(context, Icons.vaccines, 'Vaccines'),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          if (label == "Pet details") {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => PetDetails(myPet: myPet),
              ),
            ).then((_) {
              setState(() {});
            });
          }
          if(label == "Reports"){
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => PetReports(idPet: myPet.id),
              ),
            ).then((_) {
              setState(() {});
            });
          }
          if(label == "Medical prescriptions"){
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => PrescriptionListPage(petId: myPet.id),
              ),
            ).then((_) {
              setState(() {});
            });
          }
          if(label == "Vaccines"){
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => VaccineScreen(petId: myPet.id),
              ),
            ).then((_) {
              setState(() {});
            });
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF627ECB),
                size: 60,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
