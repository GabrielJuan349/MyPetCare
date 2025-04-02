import 'package:flutter/material.dart';

class MyPetsScreen extends StatefulWidget {
  @override
  _MyPetsScreenState createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  final List<String> pets = ["Pet 1", "Pet 2", "Pet 3"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My Pets"),
          centerTitle: true,
          backgroundColor: Color(0xfff59249),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.account_circle))
          ],
        ),
        body: ListView.builder(
          itemCount: pets.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(Icons.image, size: 40),
              title: Text(pets[index]),
              onTap: () {},
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        )
    );
  }
}
