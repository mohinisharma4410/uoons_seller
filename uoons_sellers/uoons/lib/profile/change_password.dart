import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordPage extends StatelessWidget {
  final String username;

  ChangePasswordPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ChangePasswordForm(username: username),
      ),
    );
  }
}

class ChangePasswordForm extends StatefulWidget {
  final String username;

  ChangePasswordForm({required this.username});

  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _sellerId;

  bool hasMinLength = false;
  bool hasUpperLowerCase = false;
  bool hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _fetchSellerId();
    _newPasswordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_validatePassword);
    super.dispose();
  }

  Future<void> _fetchSellerId() async {
    final response = await http.get(
      Uri.parse('https://uoons.com/seller/get-user?username=${widget.username}'),
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        _sellerId = jsonResponse['data']['s_id'].toString();
      });
    } else {
      print('Failed to fetch seller ID: ${response.statusCode}');
    }
  }

  void _validatePassword() {
    final password = _newPasswordController.text;

    setState(() {
      hasMinLength = password.length >= 8;
      hasUpperLowerCase = password.contains(RegExp(r'(?=.*[a-z])(?=.*[A-Z])'));
      hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPasswordField('Current Password', _oldPasswordController),
            SizedBox(height: 20),
            _buildPasswordField('New Password', _newPasswordController),
            SizedBox(height: 20),
            _buildPasswordField('Re-type New Password', _confirmPasswordController, (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            }),
            SizedBox(height: 20),
            _buildPasswordRules(),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Change Password', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, [String? Function(String?)? validator]) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your ${label.toLowerCase()}';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordRules() {
    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRule(hasMinLength, 'At least 8 characters.'),
          _buildRule(hasUpperLowerCase, 'A mixture of both uppercase and lowercase letters.'),
          _buildRule(hasSpecialChar, 'Inclusion of at least one special character.'),
        ],
      ),
    );
  }

  Widget _buildRule(bool condition, String text) {
    return Row(
      children: [
        Icon(
          condition ? Icons.check_circle : Icons.cancel,
          color: condition ? Colors.green : Colors.red,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: condition ? Colors.green : Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  void _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_sellerId != null) {
        try {
          final response = await http.post(
            Uri.parse('https://uoons.com/seller/change-password'),
            body: {
              'seller_id': _sellerId!,
              'old_password': _oldPasswordController.text,
              'new_password': _newPasswordController.text,
            },
          );

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password changed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to change password. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not found.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
