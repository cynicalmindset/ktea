import 'package:flutter/material.dart';

class Terms extends StatefulWidget {
  const Terms({super.key});

  @override
  State<Terms> createState() => _termsState();
}

class _termsState extends State<Terms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Terms and Conditions"),),
      body: content(),
    );
  }


  Widget content(){
    return Container();
  }


}