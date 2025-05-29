import 'package:flutter/material.dart';

class TheDrawer extends StatelessWidget {
  const TheDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    const appBarColor = Color(0xfff59249); // Naranja

    return Drawer(
      child: Container(
        color: appBarColor,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: appBarColor,
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inbox, color: Colors.white),
              title: const Text('Inbox', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Close drawer
                Navigator.pop(context);
                Navigator.pushNamed(context, '/inbox');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.white),
              title: const Text('FAQs', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Close drawer
                Navigator.pop(context);
                Navigator.pushNamed(context, '/help');
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.white),
              title: const Text('Language', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Close drawer
                Navigator.pop(context);
                Navigator.pushNamed(context, '/language');
              },
            ),
          ],
        ),
      ),
    );
  }
}
