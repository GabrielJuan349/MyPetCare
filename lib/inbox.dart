import 'package:flutter/material.dart';
import 'package:lis_project/inbox_message.dart';

class Inbox extends StatefulWidget {
   @override
   State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  List<InboxMessage> myMessages = [
    InboxMessage("Welcome to MyPetCare", "Thanks for choosing us"),
    InboxMessage("Medication added", "A new Medication has been added to your pet"),
  ];

  @override
  void initState() {
    super.initState();
  }

  _InboxState();

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
            Navigator.pop(context);
          },
        ),
          actions: [
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
      ),
      body: ListView.builder(
        itemCount: myMessages.length,
        itemBuilder: (context, index) {
          return Container(
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
                        myMessages[index].title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        myMessages[index].message,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.notifications_none),
              ],
            ),
          );
        },
      ),
    );
  }
}
