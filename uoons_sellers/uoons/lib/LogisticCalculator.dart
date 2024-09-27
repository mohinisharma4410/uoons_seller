import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class LogisticCalculatorPage extends StatefulWidget {
  final String username;

  LogisticCalculatorPage({required this.username});


  @override
  _LogisticCalculatorPageState createState() => _LogisticCalculatorPageState();
}

class _LogisticCalculatorPageState extends State<LogisticCalculatorPage> {
  final TextEditingController _destinationPincodeController = TextEditingController();
  final TextEditingController _originPincodeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedPackageType = '';
  String _selectedDeliverySpeed = 'Surface';
  String _selectedPaymentMode = '';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logistic Calculator'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Fill the form to calculate Package Rate',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                _buildTextField('Destination Pincode', _destinationPincodeController, TextInputType.number),
                _buildTextField('Origin Pincode', _originPincodeController, TextInputType.number),
                _buildDropdownField('Package Type', ['Forward(Delivered)', 'Reverse(DTO)', 'Reverse(RTO)'], _selectedPackageType, (value) {
                  setState(() {
                    _selectedPackageType = value!;
                  });
                }),
                _buildDropdownField('Delivery Speed', ['Surface'], _selectedDeliverySpeed, (value) {
                  setState(() {
                    _selectedDeliverySpeed = value!;
                  });
                }),
                _buildTextField('Weight in gm', _weightController, TextInputType.number),
                _buildDropdownField('Payment Mode', ['Pre-paid', 'Cash On Delivery'], _selectedPaymentMode, (value) {
                  setState(() {
                    _selectedPaymentMode = value!;
                  });
                }),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _calculateLogisticsCost,
                  child: Text('Calculate', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                _buildImportantNotes(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${label.toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
        value: selectedValue.isEmpty ? null : selectedValue,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select ${label.toLowerCase()}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImportantNotes() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Important Notes',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '''
- The above prices are approximate.
- Pre-paid & COD Shipping charges are different (e.g., 500g weight pre-paid shipment INR 51/- & COD shipment are INR 100/- approximate)
- The rate will be charged basis the weight calculated as per Uoons Automated Machines and the higher of Real Volumetric / Machine Weight / Volumetric / Dead weight will be taken.
- RTO (Return to Origin) shipment will be charged differently from the forward rate.
- For any queries, please raise an email to care@uoons.com
- The maximum liability if any is limited to the terms & conditions agreed as per contract.
- Default dimensions for volumetric weight are 1cm X 1cm X 1cm
- Uoons Reserves the right to issue Promotional Credits to the seller for any reason it may deem fit This would fall under the header of Promotional credit in the Seller's Uoons Wallet Account.
- Any disputes arising herein shall be referred to arbitration before a sole arbitrator to be appointed by Uoons and in accordance with the provisions of the Arbitration and Conciliation Act, 1996. The Place of Arbitration shall be Indore (Madhya Pradesh)
            ''',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _calculateLogisticsCost() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await http.post(
        Uri.parse('https://uoons.com/seller/logistic-calc'),
        body: {
          'd_pincode': _destinationPincodeController.text,
          'o_pincode': _originPincodeController.text,
          'package_type': _selectedPackageType,
          'delivery_speed': _selectedDeliverySpeed,
          'weight': _weightController.text,
          'payment_mode': _selectedPaymentMode, // Add this parameter if needed
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle the response data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logistics cost calculated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to calculate logistics cost. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required details to calculate logistics cost.')),
      );
    }
  }
}
