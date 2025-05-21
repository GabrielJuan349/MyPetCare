import 'package:flutter/material.dart';
import 'package:lis_project/pet_num_screen.dart';
import 'package:lis_project/pet.dart';
import 'package:lis_project/new_pet.dart';
import 'dart:io';

class MyPetsScreen extends StatefulWidget {
  List<Pet> myPets;

  MyPetsScreen({super.key, required this.myPets});

  @override
  _MyPetsScreenState createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  late List<Pet> myPets;

  @override
  void initState() {
    super.initState();
    myPets = widget.myPets;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Esto se ejecutará cuando la pantalla vuelva a ser visible
    setState(() {});
  }

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
        itemCount: myPets.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(foregroundImage: FileImage(File("assets/img/bone.jpg"))),
            title: Text(myPets[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetNumScreen(myPet: myPets[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (myPets.length < 20) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewPetScreen(), // ← Tu nueva pantalla
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No puedes añadir más de 5 mascotas.'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFF627ECB),
      ),
    );
  }
}
