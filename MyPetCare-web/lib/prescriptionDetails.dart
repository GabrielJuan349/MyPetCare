import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrescriptionDetailsScreen extends StatefulWidget {
  final String prescriptionId;
  final String petId;

  const PrescriptionDetailsScreen({
    super.key,
    required this.prescriptionId,
    required this.petId,
  });

  @override
  State<PrescriptionDetailsScreen> createState() => _PrescriptionDetailsScreenState();
}

class _PrescriptionDetailsScreenState extends State<PrescriptionDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _milligramsController;
  late TextEditingController _textController;
  DateTime? _createdAt;

  final Color _backgroundColor = Colors.white;
  final Color _highlightColor = Colors.orange.withOpacity(0.50);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _milligramsController = TextEditingController();
    _textController = TextEditingController();
    _loadPrescription();
  }

  Future<void> _loadPrescription() async {
    final doc = await FirebaseFirestore.instance
        .collection('prescription')
        .doc(widget.prescriptionId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _milligramsController.text = data['milligrams']?.toString() ?? '';
        _textController.text = data['text'] ?? '';
        _createdAt = (data['createdAt'] as Timestamp).toDate();
        _loading = false;
      });
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection('prescription')
        .doc(widget.prescriptionId)
        .update({
      'name': _nameController.text.trim(),
      'milligrams': int.tryParse(_milligramsController.text.trim()) ?? 0,
      'text': _textController.text.trim(),
    });

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receta actualizada', style: GoogleFonts.inter()),
        backgroundColor: _highlightColor,
      ),
    );
  }

  Future<void> _deletePrescription() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar receta', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('¿Estás segura de que quieres eliminar esta receta?', style: GoogleFonts.inter()),
        actions: [
          TextButton(
            child: Text('Cancelar', style: GoogleFonts.inter(color: Colors.orange)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Eliminar', style: GoogleFonts.inter(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('prescription')
          .doc(widget.prescriptionId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receta eliminada', style: GoogleFonts.inter()),
            backgroundColor: _highlightColor,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _milligramsController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF6F6F6),
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Receta',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.orange,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.orange),
            tooltip: _isEditing ? 'Guardar' : 'Editar',
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.orange),
            tooltip: 'Eliminar',
            onPressed: _deletePrescription,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _highlightColor.withOpacity(0.3)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(label: 'Nombre de la receta', controller: _nameController),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Miligramos',
                    controller: _milligramsController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Texto', controller: _textController, maxLines: 3),
                  const SizedBox(height: 16),
                  Text(
                    'Fecha de creación:',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _createdAt != null
                        ? '${_createdAt!.day}/${_createdAt!.month}/${_createdAt!.year}, ${_createdAt!.hour}:${_createdAt!.minute.toString().padLeft(2, '0')}'
                        : 'Desconocida',
                    style: GoogleFonts.inter(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: !_isEditing,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _highlightColor.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
        ),
      ],
    );
  }
}
