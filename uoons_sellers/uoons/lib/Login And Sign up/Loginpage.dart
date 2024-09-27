import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uoons/theme_provider.dart';
import 'Signuppage.dart';
import 'custom_snackbar.dart';
import 'package:uoons/Center Widget/CenterWidget.dart';
import 'package:uoons/Homepage.dart';
import 'otp_field.dart';
import 'phone_number_field.dart';
import 'top_bottom_widget.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _showOTPField = false;
  bool _isSubmitDisabled = true;
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: Stack(
        children: [
          CenterWidget(size: MediaQuery.of(context).size),
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
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenWidth * 0.5),
                    _build3DCard(context),
                    SizedBox(height: 20),
                    _buildSwitchLoginMethodButton(),
                    SizedBox(height: screenWidth * 0.2),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: keyboardHeight == 0 ? _buildSignUpRow() : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchLoginMethodButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: OutlinedButton.icon(
        onPressed: () {
          Provider.of<LoginFormState>(context, listen: false).toggleLoginForm();
        },
        icon: Icon(Icons.switch_left_rounded, color: Colors.black), // Set icon color to black
        label: Text(
          'Switch Login Method',
          style: TextStyle(color: Colors.black), // Set text color to black
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.black26, width: 2), // Set the black border here
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.grey.withOpacity(0.2), // Set the background color here
        ),
      ),
    );
  }

  Widget _build3DCard(BuildContext context) {
    final loginFormState = Provider.of<LoginFormState>(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/Uoons seller logo.png",
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            if (loginFormState.isPhoneLogin) _buildPhoneLoginForm() else _buildUsernamePasswordLoginForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneLoginForm() {
    return Column(
      children: [
        _buildGoogleSignInButton(),
        SizedBox(height: 25),
        PhoneNumberField(
          controller: _phoneNumberController,
          onVerify: _verifyPhoneNumber,
        ),
        SizedBox(height: 20),
        if (_showOTPField)
          OTPField(
            controller: _otpController,
          ),
        ElevatedButton(
          onPressed: _isSubmitDisabled ? null : _handleMobileSignIn,
          child: Text('Submit'),
        ),
        SizedBox(height: 20),
        if (_showOTPField)
          ElevatedButton(
            onPressed: _verifyPhoneNumber,
            child: Text('Resend OTP'),
          ),
      ],
    );
  }

  Widget _buildUsernamePasswordLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            suffixIcon: IconButton(
              icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
          obscureText: !_passwordVisible,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _handleUsernamePasswordSignIn,
          child: Text('Login'),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return OutlinedButton.icon(
      onPressed: _handleGoogleSignIn,
      icon: Icon(Icons.g_mobiledata_rounded),
      label: Text('Sign in with Google'),
    );
  }

  Widget _buildSignUpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?"),
        ElevatedButton(
          onPressed: _handleSignUp,
          child: Text('Sign up'),
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        showSnackBar(context, 'Sign-in with Google failed. Please try again.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        _navigateToHomePage(user.displayName ?? 'User');
      } else {
        showSnackBar(context, 'Sign-in with Google failed. Please try again.');
      }
    } catch (error) {
      showSnackBar(context, 'Error during sign-in with Google: $error');
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

  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(),
      ),
    );
  }

  Future<void> _verifyPhoneNumber() async {
    String phoneNumber = _phoneNumberController.text;
    var url = Uri.parse('https://uoons.com/seller/sent-otp-to-registered-user');

    try {
      Map<String, String> requestPayload = {'data': phoneNumber};
      var body = jsonEncode(requestPayload);
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        if (responseBody['status'] == true) {
          setState(() {
            _showOTPField = true;
            _isSubmitDisabled = false;
          });
          showSnackBar(context, 'OTP sent successfully.');
        } else {
          showSnackBar(context, 'Failed to send OTP. Please try again.');
        }
      } else {
        showSnackBar(context, 'Error: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, 'An error occurred: $e');
    }
  }

  Future<void> _handleMobileSignIn() async {
    String phoneNumber = _phoneNumberController.text;
    String otp = _otpController.text;

    var url = Uri.parse('https://uoons.com/seller/verify-otp-for-seller-login');

    try {
      Map<String, String> requestPayload = {'data': otp, 'contact': phoneNumber};
      var body = jsonEncode(requestPayload);
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        if (responseBody['status'] == true) {
          String username = responseBody['username'];
          _navigateToHomePage(username);
        } else {
          showSnackBar(context, 'OTP verification failed. Please try again.');
        }
      } else {
        showSnackBar(context, 'Error: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, 'An error occurred: $e');
    }
  }

  Future<void> _handleUsernamePasswordSignIn() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    var url = Uri.parse('https://uoons.com/seller/login');

    try {
      Map<String, String> requestPayload = {'username': username, 'password': password};
      var body = jsonEncode(requestPayload);
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        if (responseBody['status'] == true) {
          _navigateToHomePage(username);
        } else {
          showSnackBar(context, 'Login failed. Please check your username and password.');
        }
      } else {
        showSnackBar(context, 'Error: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar(context, 'An error occurred: $e');
    }
  }
}
