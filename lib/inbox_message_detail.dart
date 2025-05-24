import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lis_project/inbox_message.dart';

class InboxMessageDetail extends StatelessWidget {
  final InboxMessage message;

  const InboxMessageDetail({super.key, required this.message});

  Future<void> deleteMessage(BuildContext context) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('inbox')
          .where('id', isEqualTo: message.id)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.delete();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mensaje eliminado')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el mensaje: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(message.title),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: Color(0xfff59249),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mensaje: ${message.message}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text("Tipo: ${message.type}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            if (message.petName.isNotEmpty)
              Text("Mascota: ${message.petName}", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => deleteMessage(context),
        child: Icon(Icons.delete, color: Colors.white),
        backgroundColor: Color(0xFF627ECB),
      ),
    );
  }
}
