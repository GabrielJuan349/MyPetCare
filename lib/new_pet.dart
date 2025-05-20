import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:lis_project/data.dart';
import 'package:lis_project/requests.dart';
import 'package:lis_project/pet.dart';
//import 'package:lis_project/scanAllModule.dart';

class NewPetScreen extends StatefulWidget {
  const NewPetScreen({super.key});

  @override
  State<NewPetScreen> createState() => _NewPetScreenState();
}

class _NewPetScreenState extends State<NewPetScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController chipController = TextEditingController();
  final TextEditingController cartillaController = TextEditingController();
  final TextEditingController fotoController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  
  final appBarColor = const Color(0xfff59249);

  String? cartillaFileName;
  String? fotoFileName;
  String? selectedPetType;
  String? selectedGender;

  List<String> petTypes = ['dog', 'cat', 'rodent', 'other'];
  List<String> genders = ['male', 'female'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "New Pet",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              dispose();
              Navigator.pushNamed(
                    context,
                    '/profile',
                );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildField("Name", nameController),
            buildDropdown("Type of Pet", petTypes, typeController),
            buildField("Breed", breedController),
            buildDropdown("Gender", genders, genderController),
            buildDateSelector("Date of Birth", birthDateController),
            buildField("Weight", weightController),
            buildField("Chip Number", chipController),
            buildFileGetter("Cartilla", cartillaFileName),
            buildFileGetter("Foto", fotoFileName),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async{
                // Lógica guardado de datos
                // Connect to backend to create the new pet + add to frontend
                await createPet();
                // Navigate back to the previous screen
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: const Color(0xFF627ECB),
                foregroundColor: Colors.white,
              ),
              child: const Text("Add Pet"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFECF1FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFileGetter(String label, String? fileName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: () => pickPdfFile(label),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
              textStyle: const TextStyle(fontSize: 18),
              backgroundColor: const Color(0xFF627ECB),
              foregroundColor: Colors.white,
            ),
            child: Text(fileName ?? "Upload PDF"),
          )
        ],
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: controller.text.isNotEmpty ? controller.text : null,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.text = value;
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFECF1FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDateSelector(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFECF1FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2050),
              );
              if (pickedDate != null) {
                controller.text = "${pickedDate.toLocal()}".split(' ')[0];
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> createPet() async {
    try {
      final String? userId = Provider.of<OwnerModel>(context, listen: false).owner?.firebaseUser.uid;

      final petData = {
        "id": "",
        "name": nameController.text.trim(),
        "type": typeController.text.trim(),
        "breed": breedController.text.trim(),
        "gender": genderController.text.trim(),
        "birthDate": birthDateController.text.trim(),
        "weight": double.tryParse(weightController.text.trim()) ?? 0.0,
        "chip": chipController.text.trim()?? "",
        "image": fotoFileName ?? "",
        "cartilla": cartillaFileName ?? "",
        "owner": userId,
        "age": _calculateAge(birthDateController.text.trim()),
      };

      print("Pet data: $petData");

      final String petId = await addPet(petData);
      print("Pet created: $petId");

      
      Pet newPet = Pet(
        id: nameController.text.trim(),
        name: nameController.text.trim(),
        id: petId,
        image: fotoFileName ?? "",
        gender: genderController.text.trim(),
        age: _calculateAge(birthDateController.text.trim()).toString(),
        weight: double.tryParse(weightController.text.trim()) ?? 0.0,
        type: typeController.text.trim(),
        breed: breedController.text.trim(),
        owner: userId ?? "",
        chip: chipController.text.trim(),
      );
      print("New pet: $newPet");

      Provider.of<OwnerModel>(context, listen: true).addPet(newPet);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mascota registrada correctamente')),
      );
    } catch (e) {
      print("Error al registrar mascota: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar mascota')),
      );
    }
  }

  Future<void> pickPdfFile(String label) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (label == "Cartilla") {
          cartillaFileName = result.files.single.name;
        } else {
          fotoFileName = result.files.single.name;
        }
      });
    }
  }

  int _calculateAge(String birthDate) {
    DateTime dateOfBirth = DateTime.parse(birthDate);
    DateTime today = DateTime.now();
    int age = (today.year - dateOfBirth.year).toInt();
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    breedController.dispose();
    birthDateController.dispose();
    chipController.dispose();
    cartillaController.dispose();
    fotoController.dispose();
    genderController.dispose();
    super.dispose();
  }
}