import 'package:flutter/material.dart';

// Assuming CenterWidget is imported correctly
import 'package:uoons/Center Widget/CenterWidget3.dart'; // Adjust the import according to your file structure

class WithdrawalAmountPage extends StatefulWidget {
  final String username;

  WithdrawalAmountPage({required this.username});

  @override
  _WithdrawalAmountPageState createState() => _WithdrawalAmountPageState();
}

class _WithdrawalAmountPageState extends State<WithdrawalAmountPage> {
  double withdrawalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Custom background widget
          CenterWidget3(size: MediaQuery.of(context).size),

          // Card on top of background
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Withdrawal is currently under development and will start soon. Thank you for using Uoons.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Withdrawal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Amount Available for Withdrawal:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '\u20B9 ${withdrawalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Select Type of Amount Withdrawal:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter Amount to Withdraw',
                            prefixText: '\u20B9',
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                          onChanged: (value) {
                            setState(() {
                              withdrawalAmount = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Payment will be transferred to your default verified bank.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            print('Withdrawal request sent. Amount: \u20B9${withdrawalAmount.toStringAsFixed(2)}');
                          },
                          child: Text(
                            'Send Withdrawal Request',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
