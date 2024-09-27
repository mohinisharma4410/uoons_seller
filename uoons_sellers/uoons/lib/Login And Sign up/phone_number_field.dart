import 'package:flutter/material.dart';

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onVerify;

  PhoneNumberField({required this.controller, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: onVerify,
          child: Text('Verify'),
        ),
      ],
    );
  }
}
