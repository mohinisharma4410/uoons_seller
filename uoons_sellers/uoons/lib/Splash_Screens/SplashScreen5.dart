import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

import '../LogisticCalculator.dart';



bool _on_loading = false;

class FifthScreen extends StatefulWidget {
  final String username;

  FifthScreen({required this.username});

  @override
  _FifthScreenState createState() => _FifthScreenState();
}

class _FifthScreenState extends State<FifthScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogisticCalculatorPage(username: widget.username)),
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
                'C:\\Users\\91930\\Desktop\\Ishant Activity\\Flutter Projects\\uoons\\assets\\Animations\\Calculator.json',
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