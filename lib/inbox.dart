import 'package:flutter/material.dart';
import 'package:lis_project/home_screen.dart';
import 'package:lis_project/inbox_history.dart';
import 'package:lis_project/inbox_message.dart';
import 'package:lis_project/inbox_message_detail.dart';

class Inbox extends StatefulWidget {
  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  @override
  Widget build(BuildContext context) {
    // Filtramos los no leídos
    List<InboxMessage> unreadMessages = myMessages.where((msg) => !msg.read).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Inbox"),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: Color(0xfff59249),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
      body: unreadMessages.isEmpty
          ? Center(child: Text("No tienes mensajes sin leer."))
          : ListView.builder(
        itemCount: unreadMessages.length,
        itemBuilder: (context, index) {
          final msg = unreadMessages[index];

          return InkWell(
            onTap: () {
              // Marcar como leído en la lista global
              setState(() {
                final original = myMessages.firstWhere((m) => m.id == msg.id);
                original.read = true;
              });

              // Ir al detalle
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InboxMessageDetail(message: msg),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFE9EFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          msg.message,
                          style: TextStyle(color: Colors.black54),
                        ),
                        SizedBox(height: 4),
                        Text(
                          msg.id,
                          style: TextStyle(color: Colors.black38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.notifications_none),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => InboxHistory()),
          );
        },
        child: Icon(Icons.history, color: Colors.white),
        backgroundColor: Color(0xFF627ECB),
      ),
    );
  }
}
