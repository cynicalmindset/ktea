import 'package:flutter/material.dart';
import 'package:ktea/addpost.dart';
import 'package:ktea/home.dart';
import 'package:ktea/register_page.dart';
//import 'package:ktea/onboard.dart';
import 'package:ktea/splash.dart';
import 'package:ktea/terms.dart';
import 'package:ktea/terms2.dart';
import 'package:ktea/terms3.dart';
//import 'package:ktea/upload_post_page.dart';


void main(){
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes:{
      '/':(context)=>Splash(),
      '/terms':(context)=>Terms(),
      '/terms2': (context) => const Terms2(),
      '/terms3': (context) => const Terms3(),
      '/onboard':(context)=>const LoginPage(),
      '/home':(context)=> Home(),
      '/Addpost':(context)=>AddPostPage(),
      //'/uploadpostpage':(context)=> UploadPostPage()
       
    }
  ));
}