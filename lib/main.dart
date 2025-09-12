import 'package:flutter/material.dart';
import 'package:ktea/splash.dart';
import 'package:ktea/terms.dart';


void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes:{
      '/':(context)=>Splash(),
      '/terms':(context)=>Terms(),
    }
  ));
}