import 'package:flutter/material.dart';
import 'package:lis_project/pet_num_screen.dart';
import 'package:lis_project/pet.dart';
import 'package:lis_project/requests.dart';
import 'package:lis_project/new_pet.dart';
import 'dart:io';

import 'package:provider/provider.dart';

import 'data.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});


  @override
  _MyPetsScreenState createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  bool isLoading = true; //Default value when it first enters in this screen
  late List<Pet> pets;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  //https://stackoverflow.com/questions/58371874/what-is-the-difference-between-didchangedependencies-and-initstate
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPets();
  }

  void _loadPets() async {
  final ownerModel  = Provider.of<OwnerModel>(context, listen: false);
  final userId = ownerModel.owner?.firebaseUser.uid;

  if (userId == null) {
    print("userId is null — owner or firebaseUser not yet loaded");
    return;
  }

  // SIEMPRE hacemos la petición al backend para tener los datos actualizados
  List<Pet> loadedPets = await getUserPets(userId);
  ownerModel.setPets(loadedPets); // Opcional: si quieres que esté actualizado también en el modelo global

  if (!mounted) return;

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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                // Recharge the page
              });
            },
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
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetNumScreen(myPet: pets[index]),
                ),
              );
              _loadPets(); // Reload pets after returning from PetNumScreen
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (pets.length < 20) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewPetScreen(), // ← Tu nueva pantalla
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No puedes añadir más de 20 mascotas.'),
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
