import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:uoons/dashboardpage.dart';
import 'package:lottie/lottie.dart';



bool _on_loading = false;
class ThirdScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<ThirdScreen> {

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
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
                'assets/Animations/Dashboard.json',
                width: 300,
                height: 300,
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
