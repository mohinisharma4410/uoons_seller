import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OTPField extends StatefulWidget {
  final TextEditingController controller;

  OTPField({required this.controller});

  @override
  _OTPFieldState createState() => _OTPFieldState();
}

class _OTPFieldState extends State<OTPField> with CodeAutoFill {
  @override
  void initState() {
    super.initState();
    listenForCode();
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  void codeUpdated() {
    setState(() {
      widget.controller.text = code ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PinFieldAutoFill(
      controller: widget.controller,
      decoration: UnderlineDecoration(
        textStyle: TextStyle(fontSize: 20, color: Colors.black),
        colorBuilder: FixedColorBuilder(Colors.black),
      ),
      currentCode: widget.controller.text,
      codeLength: 4,
      onCodeSubmitted: (code) {
        setState(() {
          widget.controller.text = code;
        });
      },
    );
  }
}
