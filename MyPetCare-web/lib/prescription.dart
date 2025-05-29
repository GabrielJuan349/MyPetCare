import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class PrescriptionUploadScreen extends StatefulWidget {
  final String petId;

  const PrescriptionUploadScreen({super.key, required this.petId});

  @override
  State<PrescriptionUploadScreen> createState() => _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _milligramsController = TextEditingController();
  bool _isLoading = false;

  Future<void> _savePrescription() async {
    final name = _nameController.text.trim();
    final text = _textController.text.trim();
    final mg = int.tryParse(_milligramsController.text.trim());

    if (name.isEmpty || text.isEmpty || mg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos correctamente')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('prescription').add({
        'id_pet': widget.petId,
        'id_vet': 'vet456',
        'name': name,
        'milligrams': mg,
        'text': text,
        'createdAt': Timestamp.fromDate(DateTime(2025, 6, 1, 14, 0)), // 1 de junio, 14:00, UTC+2
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta guardada con éxito')),
      );

      _nameController.clear();
      _textController.clear();
      _milligramsController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la receta: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;
    final Color highlightColor = Colors.orange.withOpacity(0.5);
    const Color cardColor = Color(0xFFF8F8F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Nueva receta',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.orange,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalles de la receta',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),


            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Nombre de la receta'),
              style: GoogleFonts.inter(color: Colors.black87),
            ),
            const SizedBox(height: 16),


            TextField(
              controller: _milligramsController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Miligramos (mg)'),
              style: GoogleFonts.inter(color: Colors.black87),
            ),
            const SizedBox(height: 16),


            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: _inputDecoration('Instrucciones'),
              style: GoogleFonts.inter(color: Colors.black87),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _savePrescription,
              style: ElevatedButton.styleFrom(
                backgroundColor: highlightColor,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size.fromHeight(48),
              ),
              child: _isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Guardar receta', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    final highlightColor = Colors.orange.withOpacity(0.5);
    const cardColor = Color(0xFFF8F8F8);
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: Colors.black54),
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: highlightColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: highlightColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}
