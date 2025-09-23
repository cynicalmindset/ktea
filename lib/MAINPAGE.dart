import 'package:flutter/material.dart';
import 'package:ktea/chatpage.dart';
import 'package:ktea/home.dart';
import 'package:ktea/userpage.dart';
import 'package:ktea/setting.dart';
import 'package:ktea/widgets/custom_toggle_appbar.dart';

class MAINPAGE extends StatefulWidget {
  const MAINPAGE({super.key});

  @override
  State<MAINPAGE> createState() => _MAINPAGEState();
}

class _MAINPAGEState extends State<MAINPAGE> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  
  // Cache the pages to avoid recreating them
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const UserProfilePage(),
      const Chatpage(),
    ];
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onSettingsPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Setting()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomToggleAppBar(
        currentIndex: _selectedIndex,
        onTabChanged: _onTabChanged,
        onSettingsPressed: _onSettingsPressed,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: 3,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = (_pageController.page ?? _selectedIndex.toDouble()) - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
              }
              // Add rotation effect
              double rotation = value * 0.05 * (index - _selectedIndex);

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(value, value)
                  ..rotateY(rotation),
                child: Opacity(
                  opacity: value,
                  child: _pages[index], // Use cached pages
                ),
              );
            },
          );
        },
      ),
    );
  }
}