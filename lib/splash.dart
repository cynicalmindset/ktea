import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ktea/home.dart';
//import 'package:ktea/onboard.dart';
import 'package:lottie/lottie.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _splashState();
}

class _splashState extends State<Splash> {



  void initState(){
    super.initState();
    startTimer();
    
  }



  

  startTimer(){
    var duration = Duration(seconds: 6);
    return Timer(duration , route);
  }



  route(){
    Navigator.pushReplacementNamed(context,'/terms');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: content(),
    );
  }

  Widget content(){
    return Stack(
      children: [
        Center(
          child: Image.asset('assets/logo.png',
          width: 200,
          height: 200,
          ),
        ),
       Positioned(
        bottom: 0,
        left: 0,
        right: 0,
      child: Lottie.asset(
        'assets/cat.json',
        width: 400,
        height: 300,
      ),
    )

      ],
      
    );
  }
}

