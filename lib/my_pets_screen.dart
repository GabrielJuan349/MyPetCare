import 'package:flutter/material.dart';
import 'package:lis_project/pet_num_screen.dart';
import 'package:lis_project/pet.dart';
import 'dart:io';

class MyPetsScreen extends StatefulWidget {
  @override
  _MyPetsScreenState createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final List<Pet> pets = [
    Pet("Test Cat", "Male", "4", "cat", "assets/pets/cat.jpg", 3, 5),
    Pet("Test Dog", "Female", "6", "dog", "assets/pets/dog.jpg", 4, 3),
    Pet("Test Hamster", "Male", "2", "hamster", "assets/pets/hamster.jpg", 5, 0)
  ];

  @override
  Widget build(BuildContext context) {
    final appBarColor = Color(0xfff59249);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "My Pets",
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
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: pets.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(foregroundImage: FileImage(File("assets/img/bone.jpg"))),
            title: Text(pets[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetNumScreen(petName: pets[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String newPetName = "New Pet";
          pets.add(newPetName);
          setState(() {});
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
