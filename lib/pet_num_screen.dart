import 'package:flutter/material.dart';
import 'package:lis_project/data.dart';
import 'package:lis_project/pet.dart';
import 'package:lis_project/pet_details.dart';
import 'package:lis_project/reports_screen.dart';
import 'package:lis_project/vaccine_screen.dart';
import 'package:lis_project/prescription.dart';
import 'package:lis_project/requests.dart';
import 'package:provider/provider.dart'; 

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

  Future<void> _confirmDeletePet() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm delete'),
        content: const Text('Are you sure you want to delete this pet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await deletePet(myPet.id); 
        if (!mounted) return;
        Provider.of<OwnerModel>(context, listen: false).removePet(myPet);
        Navigator.of(context).pop(true); 
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete pet')),
        );
      }
    }
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
        child: Column(
          children: [
            Expanded(
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: _confirmDeletePet,
              icon: const Icon(Icons.delete),
              label: const Text("Delete Pet"),
            ),
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
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => PetDetails(myPet: myPet)))
                .then((_) => setState(() {}));
          } else if (label == "Reports") {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => PetReports(idPet: myPet.id)))
                .then((_) => setState(() {}));
          } else if (label == "Medical prescriptions") {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => PrescriptionListPage(petId: myPet.id)))
                .then((_) => setState(() {}));
          } else if (label == "Vaccines") {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => VaccineScreen(petId: myPet.id)))
                .then((_) => setState(() {}));
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF627ECB), size: 60),
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
