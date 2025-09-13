import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Terms2 extends StatefulWidget {
  const Terms2({super.key});

  @override
  State<Terms2> createState() => _Terms2State();
}

class _Terms2State extends State<Terms2> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    var duration = const Duration(seconds: 6);
    Timer(duration, route);
  }

  void route() {
    Navigator.pushReplacementNamed(context, '/terms3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: content(),
    );
  }

  Widget content() {
    return Stack(
      children: [
        const Center(
          child: Text(
            'Developer access is restricted.\n Continued searching will trigger consequences',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Lottie.asset(
            'assets/scratch.json', 
            width: 400,
            height: 300,
          ),
        )
      ],
    );
  }
}
