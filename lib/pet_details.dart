import 'package:flutter/material.dart';
import 'package:lis_project/pet.dart';

class PetDetails extends StatefulWidget {
  Pet myPet;

  PetDetails({super.key, required this.myPet});

  @override
  State<PetDetails> createState() => _PetDetailsState();
}

class _PetDetailsState extends State<PetDetails> {
  late Pet myPet;

  @override
  void initState() {
    super.initState();
    myPet = widget.myPet;
  }

  _PetDetailsState();

  Widget buildStarRow(String label, int rating) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xfff59249),
        title: const Text("Pet details"),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              myPet.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(
                    (myPet.image != null && myPet.image is String && myPet.image!.isNotEmpty)
                    ? myPet.image!
                    : "assets/logo/LogoConFondo.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
            
            const SizedBox(height: 5),
            Text(
              "Breed: ${myPet.breed}"
            ),
            const SizedBox(height: 20),
            Text(
                "Gender: ${myPet.gender}"
            ),
            const SizedBox(height: 10),
            Text(
                "Age: ${myPet.age}"
            ),
            /*const SizedBox(height: 20),
            buildStarRow("Friendly", myPet.friendly),
            const SizedBox(height: 10),
            buildStarRow("Playful", myPet.playful),*/
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.blue),
      ),
    );
  }
}
