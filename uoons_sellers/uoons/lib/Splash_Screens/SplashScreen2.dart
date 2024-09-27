import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:uoons/Profilepage.dart';
import 'package:lottie/lottie.dart';



bool _on_loading = false;
class SecondScreen extends StatefulWidget {
  final String username;

  SecondScreen({required this.username});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SecondScreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(username: widget.username)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child:Lottie.asset(
                'assets/Animations/Profile.json',
                width: 200,
                height: 200,
              ),
            ),
            Center(
              child: Lottie.asset(
                'assets/Animations/Animation - 1715839753989.json',
                width: 300,
                height: 200,
              ),
            )
          ],
        ),
      ),
    );
  }
}
