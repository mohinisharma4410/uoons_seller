import 'package:flutter/material.dart';
import 'package:uoons/Center Widget/CenterWidget2.dart';
import 'dart:math' as math;
import 'package:uoons/Homepage.dart';
import 'package:uoons/Login And Sign up/phone_number_field.dart';
import 'package:uoons/Login And Sign up/top_bottom_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pinput/pinput.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  bool _showOTPField = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          CenterWidget2(size: MediaQuery.of(context).size),
          Positioned(
            top: -screenWidth * 0.3,
            left: -screenWidth * 0.3,
            child: TopWidget(screenWidth: screenWidth),
          ),
          Positioned(
            bottom: -screenWidth * 0.5,
            right: -screenWidth * 0.5,
            child: BottomWidget(screenWidth: screenWidth),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _build3DCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/Uoons seller logo.png",
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              PhoneNumberField(
                controller: _phoneNumberController,
                onVerify: () {
                  setState(() {
                    _showOTPField = true;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username (Eg: Brand, Store, Company Name)',
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              if (_showOTPField)
                Pinput(
                  controller: _otpController,
                  length: 4,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              if (!_showOTPField)
                ElevatedButton(
                  onPressed: _handleRegister,
                  child: Text('Get OTP'),
                ),
              SizedBox(height: 20),
              if (_showOTPField)
                ElevatedButton(
                  onPressed: _handleSignUp,
                  child: Text('Sign Up'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    String phoneNumber = _phoneNumberController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;
    var url = Uri.parse('https://uoons.com/seller/register');

    try {
      Map<String, String> registrationData = {
        "mobile_number": phoneNumber,
        "username": username,
        "password": password,
      };

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: registrationData,
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          setState(() {
            _showOTPField = true;
          });
        } else {
          showSnackBar(context, 'Registration failed. Please try again.');
        }
      } else {
        showSnackBar(context, 'Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  void _handleSignUp() async {
    String phoneNumber = _phoneNumberController.text;
    String otp = _otpController.text;
    var url = Uri.parse('https://uoons.com/seller/otp-verify');

    try {
      Map<String, String> otpData = {
        "mobile_number": phoneNumber,
        "otp": otp,
        "confirm_otp": otp,
      };

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: otpData,
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          _navigateToHomePage(jsonResponse['username'] ?? 'User');
        } else {
          showSnackBar(context, 'OTP verification failed. Please try again.');
        }
      } else {
        showSnackBar(context, 'Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      showSnackBar(context, 'Error: $e');
    }
  }

  void _navigateToHomePage(String username) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(username: username),
      ),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
