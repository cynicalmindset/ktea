import 'dart:io';
import 'package:flutter/material.dart';

class Terms3 extends StatefulWidget {
  const Terms3({super.key});

  @override
  State<Terms3> createState() => _Terms3State();
}

class _Terms3State extends State<Terms3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Make the pledge")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "I have read everything and I am fine onboarding on my risk",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    exit(0); // exits the app
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("I am scared lil pussy",style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/onboard'); // navigate to login/onboarding
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("I'm down",style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white
                  ),),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
