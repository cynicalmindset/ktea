import 'package:flutter/material.dart';
import 'package:ktea/chatpage.dart';
import 'package:ktea/home.dart';
import 'package:ktea/userpage.dart';
import 'package:ktea/setting.dart'; // Add this import
import 'package:ktea/widgets/custom_toggle_appbar.dart';

class MAINPAGE extends StatefulWidget {
  const MAINPAGE({super.key});

  @override
  State<MAINPAGE> createState() => _MAINPAGEState();
}

class _MAINPAGEState extends State<MAINPAGE> {
  int _selectedIndex = 0; // Start with Home

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const UserProfilePage();
      case 2:
        return const Chatpage();
      default:
        return const HomePage();
    }
  }

  void _onSettingsPressed() {
    // Navigate to Settings page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Setting()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomToggleAppBar(
        initialIndex: _selectedIndex,
        onTabChanged: _onTabChanged, // updates the body
        onSettingsPressed: _onSettingsPressed,
      ),
      body: _getBody(), // show the selected page here
    );
  }
}