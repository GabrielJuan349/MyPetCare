import 'package:flutter/material.dart';

class PetNumScreen extends StatefulWidget {
  String petName;

  PetNumScreen({super.key, required this.petName});

  @override
  State<PetNumScreen> createState() => _PetNumScreenState();
}

class _PetNumScreenState extends State<PetNumScreen> {
  late String petName;

  @override
  void initState() {
    super.initState();
    petName = widget.petName;  // Inicializa petName con el valor del widget padre
  }

  _PetNumScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(petName),
        centerTitle: true,
        backgroundColor: Color(0xfff59249),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.account_circle))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Dos columnas
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildGridItem(context, Icons.info_outline, 'Pet details'),
            _buildGridItem(context, Icons.receipt_long_outlined, 'Reports'),
            _buildGridItem(context, Icons.medical_services_outlined, 'Medical prescriptions')
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      /*
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(
          builder: (context) => destinationPage),
      ).then((_) {
        setState(() {});
      }),*/
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFECF1FF),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF627ECB), size: 40),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF627ECB),
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
