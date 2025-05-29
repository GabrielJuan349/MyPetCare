import 'package:flutter/material.dart';
import 'package:lis_project/requests.dart';
class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  String response = "";
  late String userId;
  late Map<String, dynamic> body;

  @override
  void initState() {
    // TODO: Change it later to make it dynamic
    super.initState();
    userId = "bj1NKBFjux4joPrtq5qq";
    body = {
      'firstName':'Manel',
      'lastName': 'García'
    };
  }

  void testRequest() async{
    try{
      String result = await updateUserInfo(userId, body);
      setState(() {
        response = result;
      });
    }catch(e){
      setState(() {
        response = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff59249),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'HTTP Request',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: testRequest,
              icon: const Icon(Icons.add_circle),
              iconSize: 40,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            Text(response),
          ],
        ),
      ),
    );
  }
}
