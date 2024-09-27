import 'dart:async';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:uoons/Products.dart';



bool _on_loading = false;

class FourthScreen extends StatefulWidget {
  final String username;

  FourthScreen({required this.username});

  @override
  _FourthScreenState createState() => _FourthScreenState();
}

class _FourthScreenState extends State<FourthScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProductPage(username: widget.username)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Lottie.asset(
                'C:\\Users\\91930\\Desktop\\Ishant Activity\\Flutter Projects\\uoons\\assets\\Animations\\PRO.json',
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
            ),
          ],
        ),
      ),
    );
  }
}