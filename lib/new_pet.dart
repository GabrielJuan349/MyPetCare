import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class NewPetScreen extends StatefulWidget {
  const NewPetScreen({super.key});

  @override
  State<NewPetScreen> createState() => _NewPetScreenState();
}

class _NewPetScreenState extends State<NewPetScreen> {
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final breedController = TextEditingController();
  final birthDateController = TextEditingController();
  final chipController = TextEditingController();
  final cartillaController = TextEditingController();
  final fotoController = TextEditingController();
  final genderController = TextEditingController();
  
  final appBarColor = const Color(0xfff59249);

  String? cartillaFileName;
  String? fotoFileName;
  String? selectedPetType;
  String? selectedGender;

  List<String> petTypes = ['Dog', 'Cat', 'Rodent', 'Reptile', 'Fish'];
  List<String> genders = ['Male', 'Female'];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildField("Name", nameController),
            buildDropdown("Type of Pet", petTypes, typeController),
            buildField("Breed", breedController),
            buildMultipleChoice("Gender", genders),
            buildDateSelector("Date of Birth", birthDateController),
            buildField("Chip Number", chipController),
            buildFileGetter("Cartilla", cartillaFileName),
            buildFileGetter("Foto", fotoFileName),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Lógica guardado de datos
                // TODO: Connect to backend to create the new pet
                //TODO: Once added the new pet show snackbar showing success
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
          ),
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
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) => setState(() => selectedGender = value),
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

  Widget buildMultipleChoice(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8.0,
            children: items.map((String item) {
              return ChoiceChip(
                label: Text(item),
                selected: false,
                onSelected: (bool selected) {
                  // Lógica para manejar selección
                },
              );
            }).toList(),
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
