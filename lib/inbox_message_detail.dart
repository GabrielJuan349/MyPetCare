import 'package:flutter/material.dart';
import 'package:lis_project/inbox_message.dart';
import 'package:lis_project/inbox.dart';

class InboxMessageDetail extends StatelessWidget {
  final InboxMessage message;

  const InboxMessageDetail({super.key, required this.message});

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mensaje: ${message.message}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16), // Espacio entre los textos
            Text(
              "Tipo: ${message.type}",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          for (int i = 0; i < myMessages.length; i++) {
            if (myMessages[i].id == message.id) {
              myMessages.remove(myMessages[i]);
            }
          }
          Navigator.pop(context);
        },
        child: Icon(Icons.delete, color: Colors.white),
        backgroundColor: Color(0xFF627ECB),
      ),
    );
  }
}
