import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uoons/profile/personal_details.dart';
import 'package:uoons/profile/change_password.dart';
import 'package:uoons/profile/managestore.dart';
import 'package:uoons/profile/bank_details.dart';
import 'package:uoons/profile/legal_policies.dart';
import 'package:uoons/profile/roles_and_permission.dart';
import 'package:uoons/profile/withdrawal_amount.dart';
import 'package:uoons/profile/kyc_update.dart';
import 'package:uoons/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  ProfilePage({required this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  String avatarUrl = 'assets/Boy.png';
  bool _isEditing = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    fetchSellerData();
  }

  Future<void> fetchSellerData() async {
    final response = await http.get(Uri.parse('https://uoons.com/seller/get-user?username=${widget.username}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        avatarUrl = data['data']['s_avatar'] != null ? 'https://uoons.com${data['data']['s_avatar']}' : 'assets/Boy.png';
        _firstNameController.text = data['data']['s_name'] ?? '';
        _lastNameController.text = data['data']['s_last_name'] ?? '';
        _phoneNumberController.text = data['data']['s_mobile_number'] ?? '';
        _emailController.text = data['data']['s_email'] ?? '';
      });
    } else {
      print('Failed to load seller data');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _isProfileComplete() {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        avatarUrl = _image!.path;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      String firstName = _firstNameController.text;
      String lastName = _lastNameController.text;
      String phoneNumber = _phoneNumberController.text;
      String emailAddress = _emailController.text;

      // Perform action with the saved profile data
      print('First Name: $firstName');
      print('Last Name: $lastName');
      print('Phone Number: $phoneNumber');
      print('Email Address: $emailAddress');

      // Show a snackbar with success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved successfully')),
      );

      // Check if the profile is complete
      bool isProfileComplete = _isProfileComplete();
      if (isProfileComplete) {
        print('Profile is complete');
      } else {
        print('Profile is not complete');
      }

      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            onPressed: _toggleEditing,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                    ),
                    child: Text(
                      'My Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  _buildDrawerItem(Icons.person, 'Personal Details', () {
                    _navigateTo(context, PersonalDetailsPage(username: widget.username));
                  }),
                  _buildDrawerItem(Icons.password_sharp, 'Change Password', () {
                    _navigateTo(context, ChangePasswordPage(username: widget.username));
                  }),
                  _buildDrawerItem(Icons.store, 'Manage Store', () {
                    _navigateTo(context, ManageStorePage(username: widget.username));
                  }),
                  _buildDrawerItem(Icons.other_houses_sharp, 'Bank Details', () {
                    _navigateTo(context, BankDetailsPage(username: widget.username));
                  }),
                  _buildDrawerItem(Icons.policy, 'Legal & Policies', () {
                    _navigateTo(context, LegalPoliciesPage(username: widget.username));
                  }),
                  _buildDrawerItem(Icons.check_box, 'Roles & Permissions', () {
                    _navigateTo(context, RolesPermissionsPage(username: widget.username));
                  }),
                  _buildDrawerItem(Icons.currency_rupee, 'Withdrawal Amount', () {
                    _navigateTo(context, WithdrawalAmountPage(username: widget.username));
                  }),
                  _buildDrawerItem(Icons.touch_app_rounded, 'KYC', () {
                    _navigateTo(context, KYCUpdatePage(username: widget.username));
                  }),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.brightness_medium),
              title: Text('Theme'),
              onTap: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30), // Increase the space for better alignment
            Center(
              child: Stack(
                children: [
                  AvatarCircle(avatarUrl: avatarUrl, isEditing: _isEditing, pickImage: _pickImage),
                ],
              ),
            ),
            SizedBox(height: 10), // Increase the space for better alignment
            ProfileForm(
              formKey: _formKey,
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              phoneNumberController: _phoneNumberController,
              emailController: _emailController,
              isEditing: _isEditing,
              saveProfile: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.pop(context); // Close the drawer
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

class AvatarCircle extends StatelessWidget {
  final String avatarUrl;
  final bool isEditing;
  final VoidCallback pickImage;

  AvatarCircle({required this.avatarUrl, required this.isEditing, required this.pickImage});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 90, // Adjust the radius for better appearance
      backgroundImage: avatarUrl.startsWith('http') ? NetworkImage(avatarUrl) : AssetImage(avatarUrl) as ImageProvider,
      child: isEditing
          ? Align(
        alignment: Alignment.bottomRight,
        child: IconButton(
          icon: Icon(Icons.camera_alt, color: Colors.black),
          onPressed: pickImage,
        ),
      )
          : null,
    );
  }
}

class ProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneNumberController;
  final TextEditingController emailController;
  final bool isEditing;
  final VoidCallback saveProfile;

  ProfileForm({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneNumberController,
    required this.emailController,
    required this.isEditing,
    required this.saveProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  enabled: isEditing,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  enabled: isEditing,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  enabled: isEditing,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  enabled: isEditing,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(value)) {
                    return 'Please enter a valid Gmail address';
                  }
                  return null;
                },
              ),
              if (isEditing) SizedBox(height: 20),
              if (isEditing)
                ElevatedButton(
                  onPressed: saveProfile,
                  child: Text('Save'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
