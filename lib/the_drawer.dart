import 'package:flutter/material.dart';

class TheDrawer extends StatelessWidget {
  const TheDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBarColor = Color(0xfff59249); // Naranja

    return Drawer(
      child: Container(
        color: appBarColor,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: appBarColor,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.inbox, color: Colors.white),
              title: Text('Inbox', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/inbox');
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.white),
              title: Text('Help', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/help');
              },
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.language, color: Colors.white),
              title: Text('Language', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/language');
              },
            ),
          ],
        ),
      ),
    );
  }
}
