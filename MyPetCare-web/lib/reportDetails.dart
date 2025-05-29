import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportDetailsScreen extends StatefulWidget {
  final String reportId;
  final String reportText;
  final String createdAt;

  const ReportDetailsScreen({
    super.key,
    required this.reportId,
    required this.reportText,
    required this.createdAt,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  late TextEditingController _controller;
  bool _isEditing = false;

  final Color _backgroundColor = Colors.white;
  final Color _highlightColor = Colors.orange.withOpacity(0.50);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.reportText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateReport() async {
    await FirebaseFirestore.instance
        .collection('report')
        .doc(widget.reportId)
        .update({'reportText': _controller.text});
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Informe actualizado', style: GoogleFonts.inter()),
        backgroundColor: _highlightColor.withOpacity(0.7),
      ),
    );
  }

  Future<void> _deleteReport() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar informe', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text('¿Estás segura de que quieres eliminar este informe?', style: GoogleFonts.inter()),
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
      await FirebaseFirestore.instance.collection('report').doc(widget.reportId).delete();
      if (mounted) Navigator.of(context).pop();
    }
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
          'Informe',
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
                _updateReport();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.orange),
            tooltip: 'Eliminar',
            onPressed: _deleteReport,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _highlightColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fecha: ${widget.createdAt}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextField(
                  controller: _controller,
                  readOnly: !_isEditing,
                  maxLines: null,
                  cursorColor: Colors.orange,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Contenido del informe',
                    labelStyle: GoogleFonts.inter(color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _highlightColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _highlightColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
