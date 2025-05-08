import 'package:flutter/material.dart';
import 'package:lis_project/inbox_message.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

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
        title: const Text("Inbox"),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: const Color(0xfff59249),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
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
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE9EFFF),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        myMessages[index].message,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.notifications_none),
              ],
            ),
          );
        },
      ),
    );
  }
}
