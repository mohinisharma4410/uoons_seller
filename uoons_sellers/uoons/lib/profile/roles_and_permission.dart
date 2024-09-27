import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RolesPermissionsPage extends StatelessWidget {
  final String username;

  RolesPermissionsPage({required this.username});

  Future<String> _fetchSellerId() async {
    final response = await http.get(Uri.parse('https://uoons.com/seller/get-user?username=$username'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['s_id'].toString();
    } else {
      throw Exception('Failed to load seller ID');
    }
  }

  Future<List<dynamic>> _fetchStaffMembers(String sellerId) async {
    final response = await http.get(Uri.parse('https://uoons.com/seller/all-staff-members?seller_id=$sellerId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Check if 'staff_members' exists in the response
      if (data.containsKey('data')) {
        return data['data'];
      } else {
        throw Exception('No staff members found');
      }
    } else {
      throw Exception('Failed to load staff members');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchSellerId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Roles & Permissions'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Roles & Permissions'),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          final sellerId = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Roles & Permissions'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      'Users and Permissions',
                      style: GoogleFonts.nunito(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Divider(thickness: 1),
                    SizedBox(height: 20),
                    Text(
                      'Owner Info',
                      style: GoogleFonts.nunito(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Last Login: Monday, 2 May, 2022 10:49 am IST',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Store owners have some permissions that can\'t be assigned to staff. Learn more about store owner permissions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddStaffPage(sellerId: sellerId)),
                        );
                      },
                      child: Text('Add Staff'),
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<List<dynamic>>(
                      future: _fetchStaffMembers(sellerId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else {
                          final staffMembers = snapshot.data!;
                          return _buildStaffList(staffMembers, context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildStaffList(List<dynamic> staffMembers, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Staff Members',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        if (staffMembers.isEmpty)
          Text(
            'No staff members available',
            textAlign: TextAlign.center,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: staffMembers.length,
            itemBuilder: (context, index) {
              final staff = staffMembers[index];
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
                      _buildDetailRow('Name', '${staff['s_name']} ${staff['s_last_name']}', context),
                      _buildDetailRow('Email', staff['s_email'] ?? '', context),
                      _buildDetailRow('Permissions', staff['s_permissions'].keys.where((key) => staff['s_permissions'][key] == 'true').join(', '), context),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value, BuildContext context) {
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

class AddStaffPage extends StatefulWidget {
  final String sellerId;

  AddStaffPage({required this.sellerId});

  @override
  _AddStaffPageState createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  bool manageProducts = false;
  bool editProfile = false;
  bool manageOrders = false;
  bool reportsAndAnalytics = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool isFormFilled() {
    return _emailController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Staff Members'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Members',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                'Share access to your online store with your team to grow your business. You can invite multiple staff members to help with tasks like adding products, processing orders, or managing by third-party e-commerce services.',
                style: TextStyle(fontSize: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              ),
              SizedBox(height: 20),
              Text(
                'Permissions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              ),
              SizedBox(height: 10),
              _buildSwitchListTile('Manage Products', manageProducts, (value) {
                setState(() {
                  manageProducts = value;
                });
              }, context),
              _buildSwitchListTile('Edit Profile', editProfile, (value) {
                setState(() {
                  editProfile = value;
                });
              }, context),
              _buildSwitchListTile('Manage Orders', manageOrders, (value) {
                setState(() {
                  manageOrders = value;
                });
              }, context),
              _buildSwitchListTile('Reports and Analytics', reportsAndAnalytics, (value) {
                setState(() {
                  reportsAndAnalytics = value;
                });
              }, context),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: isFormFilled()
                      ? () {
                    // Add logic to handle form submission
                    // You can call an API or perform any action you need
                  }
                      : null,
                  child: Text('Send Invite'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchListTile(String title, bool value, Function(bool) onChanged, BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
