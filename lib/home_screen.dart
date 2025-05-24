import 'package:flutter/material.dart';
import 'package:lis_project/data.dart';
import 'package:lis_project/the_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {
  double iconSize = 70;
  bool _listenersStarted = false;

  @override
  void initState() {
    super.initState();
    setGlobalUser(context);
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
    const appBarColor = Color(0xfff59249);
    return Scaffold(
      drawer: const TheDrawer(),
        appBar: AppBar(
          backgroundColor: appBarColor,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Home',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                    context,
                    '/profile',
                );
              },
            ),
          ],
        ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _buildContainer(
              icon: Icons.pets,
              label: 'Pets',
              color: const Color(0xFFE9EFFF),
              iconColor: const Color(0xFF627ECB),
              onTap: () {Navigator.pushNamed(
                  context,
                  '/pets',
              );
                },
            ),
            _buildContainer(
              icon: Icons.calendar_month,
              label: 'Agenda',
              color: const Color(0xFFE9EFFF),
              iconColor: const Color(0xFF627ECB),
              onTap: () {Navigator.pushNamed(
                context,
                '/appointmentList',
              );
              },
            ),
            _buildContainer(
              icon: Icons.notifications_outlined,
              label: 'Reminders',
              color: const Color(0xFFE9EFFF),
              iconColor: const Color(0xFF627ECB),
              onTap: () {Navigator.pushNamed(context, '/reminders');
                },
            ),
            _buildContainer(
              icon: Icons.map,
              label: 'Map',
              color: const Color(0xFFE9EFFF),
              iconColor: const Color(0xFF627ECB),
              onTap: () {
                Navigator.pushNamed(context, '/map');
              },
            ),
            _buildContainer(
              icon: Icons.info_outline,
              label: 'News',
              color: const Color(0xFFE9EFFF),
              iconColor: const Color(0xFF627ECB),
              onTap: () {Navigator.pushNamed(context, '/news');
                },
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
      padding: const EdgeInsets.all(10),
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
              const SizedBox(height: 8),
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
