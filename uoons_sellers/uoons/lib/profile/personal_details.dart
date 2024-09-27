import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonalDetailsPage extends StatefulWidget {
  final String username;

  PersonalDetailsPage({required this.username});

  @override
  _PersonalDetailsPageState createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final response = await http.get(
      Uri.parse('https://uoons.com/seller/get-user?username=${widget.username}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _countryController.text = data['data']['s_country'];
        _addressController.text = data['data']['s_add'];
        _apartmentController.text = data['data']['s_add_two'] ?? '';
        _cityController.text = data['data']['s_city'];
        _stateController.text = data['data']['s_state'];
        _pincodeController.text = data['data']['s_pin_code'];
        _phoneNumberController.text = data['data']['s_mobile_number'];
        _emailController.text = data['data']['s_email'];
        _isLoading = false;
      });
    } else {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user details')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveDetails() {
    if (_formKey.currentState?.validate() ?? false) {
      // If all fields are valid, save the data.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Details saved successfully!')));
      setState(() {
        _isEditing = false;
      });
    } else {
      // Show a message that some fields are not filled
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields')));
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, String hintText, {TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
            validator: validator,
            enabled: _isEditing,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveDetails : _toggleEditing,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                'Country/Region',
                _countryController,
                'India',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country/region';
                  }
                  return null;
                },
              ),
              _buildTextField(
                'Address',
                _addressController,
                'Sample Address',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              _buildTextField(
                'Apartment, suites, etc. (optional)',
                _apartmentController,
                '',
              ),
              _buildTextField(
                'City',
                _cityController,
                'Indore',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              _buildTextField(
                'State',
                _stateController,
                'Madhya Pradesh',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your state';
                  }
                  return null;
                },
              ),
              _buildTextField(
                'Pincode',
                _pincodeController,
                '101111',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pincode';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Contact Information',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(
                'Phone Number',
                _phoneNumberController,
                '+91',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                'Email',
                _emailController,
                'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (_isEditing)
                Center(
                  child: ElevatedButton(
                    onPressed: _saveDetails,
                    child: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
