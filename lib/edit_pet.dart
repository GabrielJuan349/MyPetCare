import 'package:flutter/material.dart';
import 'package:lis_project/data.dart';
import 'package:lis_project/pet.dart';
import 'package:lis_project/pet_details.dart';
import 'package:lis_project/requests.dart';
import 'package:provider/provider.dart';

class EditPet extends StatefulWidget {
  Pet myPet;

  EditPet({super.key, required this.myPet});

  @override
  State<EditPet> createState() => _EditPetState();
}

class _EditPetState extends State<EditPet> {
  late Pet myPet;
  //final TextEditingController _textControllerName = TextEditingController(text: 'Texto predeterminado');
  late TextEditingController _textControllerName;
  late TextEditingController _textControllerGender;
  late TextEditingController _textControllerBreed;
  late TextEditingController _textControllerWeight;

  @override
  void initState() {
    super.initState();
    myPet = widget.myPet;
    String name = myPet.name;
    String gender = myPet.gender;
    String breed = myPet.breed;
    double weight = myPet.weight;
    _textControllerName = TextEditingController(text: name);
    _textControllerGender = TextEditingController(text: gender);
    _textControllerBreed = TextEditingController(text: breed);
    _textControllerWeight = TextEditingController(text: weight.toString());

  }

  _EditPetState();

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
          onPressed: () {
            Navigator.pop(context);
          },
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
                  )
              )
            ],
          ),
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    late TextEditingController textController;
    if (label == "Name") {
      textController = _textControllerName;
    } else if (label == "Gender") {
      textController = _textControllerGender;
    } else if (label == "Breed") {
      textController = _textControllerBreed;
    } else if (label == "Weight") {
      textController = _textControllerWeight;
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
          onPressed: () async{
            await editPet();
            // Navigate back to the previous screen
            Navigator.pop(context, true);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PetDetails(myPet: myPet),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
            textStyle: const TextStyle(fontSize: 18),
            backgroundColor: const Color(0xFF627ECB),
            foregroundColor: Colors.white,
          
          ),
          child: Text('Submit'),
        ),
      ),
    );
  }

  Future<void> editPet() async {
    try {
      
      final petData = {
        "name": _textControllerName.text.trim(),
        "gender": _textControllerGender.text.trim(),
        "breed": _textControllerBreed.text.trim(),
        "weight": double.tryParse(_textControllerWeight.text.trim()) ?? 0.0,
      };

      print("Pet data: $petData");

      final String petId = await updatePet(myPet.id,petData);
      print("Pet updated: $petId");

      myPet.name = _textControllerName.text.trim();
      myPet.breed = _textControllerBreed.text.trim();
      myPet.weight = double.tryParse(_textControllerWeight.text.trim()) ?? 0.0;
      myPet.gender = _textControllerGender.text.trim();

      // Update the pet in the provider
      Provider.of<OwnerModel>(context, listen: false).updatePet(myPet);

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
