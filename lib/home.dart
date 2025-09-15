import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(title: const Text("Home")),

      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
          Navigator.pushNamed(context, "/Addpost");
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28, color: Colors.black),
      ),
    );
  }
}
