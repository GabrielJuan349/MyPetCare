import 'package:flutter/material.dart';
import 'package:lis_project/pet.dart';
import 'package:lis_project/pet_details.dart';

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
        backgroundColor: Color(0xfff59249),
        title: Text("Edit Pet details"),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
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
                        _buildButton()
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
    late TextEditingController _textController;
    if (label == "Name") {
      _textController = _textControllerName;
    } else if (label == "Gender") {
      _textController = _textControllerGender;
    } else if (label == "Breed") {
      _textController = _textControllerBreed;
    } else if (label == "Weight") {
      _textController = _textControllerWeight;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          TextField(
            controller: _textController,
            obscureText: obscureText,
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFE9EFFF),
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
          onPressed: () {
            myPet.name = _textControllerName.text;
            myPet.gender = _textControllerGender.text;
            myPet.breed = _textControllerBreed.text;
            myPet.weight = double.tryParse(_textControllerWeight.text) ?? 0.0;
            /*
            setState(() {
              //myPet = updatedPet;
              for (int i = 0; i < pets.length; i++) {
                if (pets[i].id == myPet.id) {
                  pets[i] = updatedPet;
                }
              }
            });*/
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PetDetails(myPet: myPet),
              ),
            );
          },
          child: Text('Submit'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
            textStyle: TextStyle(fontSize: 18),
            backgroundColor: Color(0xFF627ECB),
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
