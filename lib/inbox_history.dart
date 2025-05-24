import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lis_project/inbox_message.dart';
import 'package:lis_project/inbox_message_detail.dart';
import 'package:firebase_core/firebase_core.dart';

class InboxHistory extends StatefulWidget {
  @override
  State<InboxHistory> createState() => _InboxHistoryState();
}

class _InboxHistoryState extends State<InboxHistory> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> deleteAllReadMessages() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('inbox')
          .where('userId', isEqualTo: user.uid)
          .where('read', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos los mensajes leídos han sido eliminados.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text("No has iniciado sesión")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Inbox History"),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: Color(0xfff59249),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/home'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('inbox')
            .where('userId', isEqualTo: currentUser.uid)
            .where('read', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("No tienes mensajes leídos."));

          final readMessages = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return InboxMessage.fromFirestore(data);
          }).toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: readMessages.length,
                  itemBuilder: (context, index) {
                    final msg = readMessages[index];
                    return InkWell(
                      onTap: () {
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
                                  Text(msg.title, style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text(msg.message, style: TextStyle(color: Colors.black54)),
                                  SizedBox(height: 4),
                                  Text(msg.id, style: TextStyle(color: Colors.black38, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.notifications),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: deleteAllReadMessages,
                  icon: Icon(Icons.delete_forever),
                  label: Text("Eliminar todos"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF627ECB),
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
