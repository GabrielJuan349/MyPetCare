import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lis_project/home_screen.dart';
import 'package:lis_project/inbox_history.dart';
import 'package:lis_project/inbox_message_detail.dart';
import 'package:lis_project/inbox_message.dart';

class Inbox extends StatefulWidget {
  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final inboxRef = FirebaseFirestore.instance.collection('inbox');

  Future<void> markAsRead(String docId) async {
    await inboxRef.doc(docId).update({'read': true});
  }

  Future<void> markAllAsRead() async {
    final snapshot = await inboxRef.where('userId', isEqualTo: userId).where('read', isEqualTo: false).get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'read': true});
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder<QuerySnapshot>(
        stream: inboxRef
            .where('userId', isEqualTo: userId)
            .where('read', isEqualTo: false)
            .orderBy('id', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text("Error al cargar mensajes."));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Verificar que snapshot.data no sea null y tenga docs
          final unreadMessages = snapshot.data?.docs ?? [];

          if (unreadMessages.isEmpty) {
            // Fallback a lista local si no hay mensajes en Firestore
            final localUnreadMessages = (myMessages ?? [])
                .where((msg) => msg.read == false)
                .toList();

            if (localUnreadMessages.isEmpty) {
              return Center(child: Text("No tienes mensajes sin leer."));
            }

            return ListView.builder(
              itemCount: localUnreadMessages.length,
              itemBuilder: (context, index) {
                final msg = localUnreadMessages[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      msg.read = true;
                      print(localUnreadMessages);
                    });
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
                                msg.title ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                msg.message ?? '',
                                style: TextStyle(color: Colors.black54),
                              ),
                              SizedBox(height: 4),
                              Text(
                                msg.petName ?? '',
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
            );
          }

          // Si hay mensajes en Firestore, mostrar
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: unreadMessages.length,
                  itemBuilder: (context, index) {
                    final doc = unreadMessages[index];
                    final data = doc.data() as Map<String, dynamic>? ?? {};

                    return InkWell(
                      onTap: () async {
                        await markAsRead(doc.id);
                        print(doc.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InboxMessageDetail(
                              message: InboxMessage(
                                data['title'] ?? '',
                                data['msg'] ?? '',
                                data['type'] ?? '',
                                data['id'] ?? '',
                                true,
                                petName: data['pet_name'] ?? '',
                              ),
                            ),
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
                                    data['title'] ?? '',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    data['msg'] ?? '',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    data['pet_name'] ?? '',
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
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await markAllAsRead();
                    setState(() {}); // refrescar UI
                  },
                  icon: Icon(Icons.done_all),
                  label: Text("Marcar todo como leído"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF627ECB),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ],
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
