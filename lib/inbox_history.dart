import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lis_project/home_screen.dart';
import 'package:lis_project/inbox_message.dart';
import 'package:lis_project/inbox.dart';
import 'package:lis_project/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lis_project/inbox_message_detail.dart';


class InboxHistory extends StatefulWidget {
  @override
  State<InboxHistory> createState() => _InboxHistoryState();
}

class _InboxHistoryState extends State<InboxHistory> {

  @override
  void initState() {
    super.initState();
  }

  _InboxHistoryState();

  @override
  Widget build(BuildContext context) {
    final readMessages = myMessages.where((msg) => msg.read == true).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text("Inbox History"),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: Color(0xfff59249),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => Inbox(), // ← Tu nueva pantalla
            ),);
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
      body: readMessages.isEmpty
          ? Center(child: Text("No tienes mensajes sin leer."))
          : ListView.builder(
        itemCount: readMessages.length,
        itemBuilder: (context, index) {
          final msg = readMessages[index];

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
    );
  }
}
