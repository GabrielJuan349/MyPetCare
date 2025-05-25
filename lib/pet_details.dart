import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lis_project/pet.dart';
import 'package:lis_project/edit_pet.dart';
import 'package:open_file/open_file.dart';

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
                  image: myPet.image != null && myPet.image!.isNotEmpty
                    ? FileImage(File(myPet.image!)) as ImageProvider
                    : AssetImage("assets/logo/LogoConFondo.png"),
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
            const SizedBox(height: 10),
            Text(
                "Weight: ${myPet.weight} kg"
            ),
            /*const SizedBox(height: 20),
            buildStarRow("Friendly", myPet.friendly),
            const SizedBox(height: 10),
            buildStarRow("Playful", myPet.playful),*/

            if (myPet.cartilla != null && myPet.cartilla!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final filePath = myPet.cartilla!;
                    if (await File(filePath).exists()) {
                      await OpenFile.open(filePath);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("This file does not exist")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Open Cartilla"),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPet(myPet: myPet),
            ),
          );
        },
        child: const Icon(Icons.edit, color: Colors.blue),
      ),
    );
  }
}
