import 'package:flutter/material.dart';
import 'package:lis_project/the_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  double iconSize = 70;
  bool _listenersStarted = false;

  @override
  void initState() {
    super.initState();
    _initListenersIfNeeded();
  }

  void _initListenersIfNeeded() async {
    if (_listenersStarted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      startFirestoreListeners(user.uid);
      _listenersStarted = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    final appBarColor = Color(0xfff59249);
    return Scaffold(
      drawer:TheDrawer(),
        appBar: AppBar(
          backgroundColor: appBarColor,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Home',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          padding: EdgeInsets.all(20),
          children: <Widget>[
            _buildContainer(
              icon: Icons.pets,
              label: 'Pets',
              color: Color(0xFFE9EFFF),
              iconColor: Color(0xFF627ECB),
              onTap: () {Navigator.pushNamed(context, '/pets');
                },
            ),
            _buildContainer(
              icon: Icons.calendar_month,
              label: 'Agenda',
              color: Color(0xFFE9EFFF),
              iconColor: Color(0xFF627ECB),
              onTap: () {},
            ),
            _buildContainer(
              icon: Icons.notifications_outlined,
              label: 'Reminders',
              color: Color(0xFFE9EFFF),
              iconColor: Color(0xFF627ECB),
              onTap: () {Navigator.pushNamed(context, '/reminders');
                },
            ),
            _buildContainer(
              icon: Icons.map,
              label: 'Map',
              color: Color(0xFFE9EFFF),
              iconColor: Color(0xFF627ECB),
              onTap: () {},
            ),
            _buildContainer(
              icon: Icons.info_outline,
              label: 'Tips',
              color: Color(0xFFE9EFFF),
              iconColor: Color(0xFF627ECB),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
