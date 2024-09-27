import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BankDetailsPage extends StatelessWidget {
  final String username;

  BankDetailsPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BankDetailsForm(username: username),
        ),
      ),
    );
  }
}

class BankDetailsForm extends StatefulWidget {
  final String username;

  BankDetailsForm({required this.username});

  @override
  _BankDetailsFormState createState() => _BankDetailsFormState();
}

class _BankDetailsFormState extends State<BankDetailsForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _beneficiaryNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _bankNameController;
  late TextEditingController _ifscCodeController;

  bool _showBankForm = false;
  String? _sellerId;
  List<dynamic> _bankList = [];

  @override
  void initState() {
    super.initState();
    _beneficiaryNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _bankNameController = TextEditingController();
    _ifscCodeController = TextEditingController();

    _fetchSellerIdAndBanks();
  }

  @override
  void dispose() {
    _beneficiaryNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _ifscCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchSellerIdAndBanks() async {
    await _fetchSellerId();
    if (_sellerId != null) {
      await _fetchAllBanks();
    }
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

  Future<void> _fetchAllBanks() async {
    if (_sellerId != null) {
      final response = await http.get(
        Uri.parse('https://uoons.com/seller/fetch-all-banks?seller_id=$_sellerId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _bankList = data['data'];
        });
      } else {
        print('Failed to fetch banks: ${response.statusCode}');
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_sellerId != null) {
        final response = await http.post(
          Uri.parse('https://uoons.com/seller/create-bank'),
          body: {
            'seller_id': _sellerId!,
            'bank_name': _bankNameController.text,
            'account_number': _accountNumberController.text,
            'account_holder': _beneficiaryNameController.text,
            'ifsc_code': _ifscCodeController.text,
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bank details added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchAllBanks(); // Refresh the bank list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add bank details'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_showBankForm)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showBankForm = true;
                });
              },
              child: Text('Add Bank'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          if (_showBankForm) ...[
            Text(
              'Add Bank',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildTextField('Beneficiary Name', _beneficiaryNameController),
            _buildTextField('Account Number', _accountNumberController, keyboardType: TextInputType.number),
            _buildTextField('Bank Name', _bankNameController),
            _buildTextField('IFSC Code', _ifscCodeController, keyboardType: TextInputType.text),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
          SizedBox(height: 20),
          _buildBankList(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
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
        style: TextStyle(color: Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBankList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Bank List',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        if (_bankList.isEmpty)
          Text(
            'No banks available',
            textAlign: TextAlign.center,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _bankList.length,
            itemBuilder: (context, index) {
              final bank = _bankList[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Beneficiary Name', bank['sb_account_holder'] ?? ''),
                      _buildDetailRow('Bank Name', bank['sb_bank_name'] ?? ''),
                      _buildDetailRow('Account Number', bank['sb_account_number'] ?? ''),
                      _buildDetailRow('IFSC Code', bank['sb_ifsc_code'] ?? ''),
                      _buildDetailRow('Account Verification', bank['account_verification'] ?? ''),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.nunito(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
