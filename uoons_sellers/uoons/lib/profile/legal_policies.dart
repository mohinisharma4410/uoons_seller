import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class LegalPoliciesPage extends StatelessWidget {
  final String username;

  LegalPoliciesPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Legal & Policies'),
      ),
      body: Center(
      ),
    );
  }
}
