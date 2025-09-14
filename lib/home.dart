import 'package:flutter/material.dart';
import 'custom_toggle_appbar.dart';
import 'home_page.dart';
import 'profilepage.dart';
import 'chat_page.dart';
import 'settings_page.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentTab = 0;

  final List<Widget> pages = [
    HomePage(),
    ProfilePage(),
    ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: CustomToggleAppBar(
        initialIndex: currentTab,
        onTabChanged: (index) {
          setState(() {
            currentTab = index;
          });
        },
        onSettingsPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        },
      ),
      body: pages[currentTab],
    );
  }
}