import 'package:flutter/material.dart';
import 'package:lis_project/pet_num_screen.dart';
import 'package:lis_project/pet.dart';
import 'package:lis_project/requests.dart';
import 'package:lis_project/new_pet.dart';
import 'dart:io';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});


  @override
  _MyPetsScreenState createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  /*
  final List<Pet> pets = [
    Pet("Test Cat", "Male", "4", "cat", "assets/pets/cat.jpg", 3, 5),
    Pet("Test Dog", "Female", "6", "dog", "assets/pets/dog.jpg", 4, 3),
    //Pet("Test Hamster", "Male", "2", "hamster", "assets/pets/hamster.jpg", 5, 0)
  ];
  */
  bool isLoading = true; //Default value when it first enters in this screen
  late List<Pet> pets;

  //https://stackoverflow.com/questions/58371874/what-is-the-difference-between-didchangedependencies-and-initstate
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPets();
  }

  void _loadPets() async {
    final userId = ModalRoute.of(context)!.settings.arguments as String;
    final loadedPets = await getUserPets(userId);
    setState(() {
      pets = loadedPets;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xfff59249);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "My Pets",
          style: TextStyle(color: Colors.white),
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
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) //Loading icon
        : ListView.builder(
        itemCount: pets.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(foregroundImage: FileImage(File("assets/img/bone.jpg"))),
            title: Text(pets[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetNumScreen(myPet: pets[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewPetScreen(), // ← Tu nueva pantalla
            ),
          );
        },
        backgroundColor: const Color(0xFF627ECB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
