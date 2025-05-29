import 'package:flutter/material.dart';
import 'package:lis_project/data.dart';
import 'package:lis_project/home_screen.dart';
import 'package:lis_project/pet.dart';
import 'package:lis_project/requests.dart';
import 'package:provider/provider.dart';
import 'requests.dart';
class EditPet extends StatefulWidget {
  final Pet myPet;

  EditPet({super.key, required this.myPet});

  @override
  State<EditPet> createState() => _EditPetState();
}

class _EditPetState extends State<EditPet> {
  late TextEditingController _textControllerName;
  late TextEditingController _textControllerGender;
  late TextEditingController _textControllerBreed;
  late TextEditingController _textControllerWeight;

  @override
  void initState() {
    super.initState();
    _textControllerName = TextEditingController(text: widget.myPet.name);
    _textControllerGender = TextEditingController(text: widget.myPet.gender);
    _textControllerBreed = TextEditingController(text: widget.myPet.breed);
    _textControllerWeight = TextEditingController(text: widget.myPet.weight.toString());
  }

  @override
  void dispose() {
    _textControllerName.dispose();
    _textControllerGender.dispose();
    _textControllerBreed.dispose();
    _textControllerWeight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xfff59249),
        title: const Text("Edit Pet details"),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField('Name'),
                    _buildTextField('Gender'),
                    _buildTextField('Breed'),
                    _buildTextField('Weight'),
                    _buildButton(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    TextEditingController textController;
    switch (label) {
      case 'Name':
        textController = _textControllerName;
        break;
      case 'Gender':
        textController = _textControllerGender;
        break;
      case 'Breed':
        textController = _textControllerBreed;
        break;
      case 'Weight':
        textController = _textControllerWeight;
        break;
      default:
        textController = TextEditingController(); // fallback
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          TextField(
            controller: textController,
            obscureText: obscureText,
            keyboardType: label == 'Weight' ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE9EFFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ElevatedButton(
          onPressed: () async {
            await editPet();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
            textStyle: const TextStyle(fontSize: 18),
            backgroundColor: const Color(0xFF627ECB),
            foregroundColor: Colors.white,
          ),
          child: const Text('Submit'),
        ),
      ),
    );
  }

  Future<void> editPet() async {
    try {
      final petData = {
        "name": _textControllerName.text.trim().isNotEmpty
            ? _textControllerName.text.trim()
            : widget.myPet.name,
        "gender": _textControllerGender.text.trim().isNotEmpty
            ? _textControllerGender.text.trim()
            : widget.myPet.gender,
        "breed": _textControllerBreed.text.trim().isNotEmpty
            ? _textControllerBreed.text.trim()
            : widget.myPet.breed,
        "weight": double.tryParse(_textControllerWeight.text.trim()) ?? widget.myPet.weight,
        "age": widget.myPet.age,
        "image": widget.myPet.image,
        "cartilla": widget.myPet.cartilla,
        "owner_id": widget.myPet.owner,
      };

      print("Pet data: $petData");

      final String petId = await updatePet(widget.myPet.id, petData);
      print("Pet updated: $petId");

      // Actualizar el objeto local
      widget.myPet.name = petData['name'] as String;
      widget.myPet.gender = petData['gender'] as String;
      widget.myPet.breed = petData['breed'] as String;
      widget.myPet.weight = petData['weight'] as double;

      // Actualizar en el Provider
      Provider.of<OwnerModel>(context, listen: false).updatePet(widget.myPet);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mascota editada correctamente')),
      );
    } catch (e) {
      print("Error al editar mascota: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al editar mascota')),
      );
    }
  }
}
