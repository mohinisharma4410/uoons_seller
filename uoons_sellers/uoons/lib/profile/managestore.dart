import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class ManageStorePage extends StatelessWidget {
  final String username;

  ManageStorePage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Store'),
      ),
      body: StoreForm(username: username),
    );
  }
}

class StoreForm extends StatefulWidget {
  final String username;

  StoreForm({required this.username});

  @override
  _StoreFormState createState() => _StoreFormState();
}

class _StoreFormState extends State<StoreForm> {
  bool _showStoreForm = false;
  List<dynamic> _stores = [];
  String? _sellerId;

  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeEmailController = TextEditingController();
  final TextEditingController _storeAddressController = TextEditingController();
  final TextEditingController _gstNumberController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _deliveryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchSellerIdAndStores();
  }

  Future<void> _fetchSellerIdAndStores() async {
    await _fetchSellerId();
    if (_sellerId != null) {
      await _fetchStores();
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

  Future<void> _fetchStores() async {
    if (_sellerId != null) {
      final response = await http.get(
        Uri.parse('https://uoons.com/seller/fetch-stores-list?seller_id=$_sellerId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Stores fetched: $data');  // Debug print
        setState(() {
          _stores = data['data'];
          _stores.sort((a, b) => b['ss_default'].compareTo(a['ss_default']));
        });
      } else {
        print('Failed to fetch stores: ${response.statusCode}');
      }
    }
  }

  bool _isStoreDetailsComplete() {
    return _storeNameController.text.isNotEmpty &&
        _storeEmailController.text.isNotEmpty &&
        _storeAddressController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _stateController.text.isNotEmpty &&
        _pinCodeController.text.isNotEmpty &&
        _deliveryController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_showStoreForm)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showStoreForm = true;
                    });
                  },
                  child: Text('Add Store'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              if (_showStoreForm) ...[
                Text(
                  'Add Store',
                  style: GoogleFonts.nunito(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                _buildTextField('Store Name', _storeNameController),
                _buildTextField('Store Email', _storeEmailController, keyboardType: TextInputType.emailAddress),
                _buildTextField('Store Address', _storeAddressController),
                _buildTextField('GST Number (Optional)', _gstNumberController),
                _buildTextField('Phone Number', _phoneNumberController, keyboardType: TextInputType.phone),
                _buildTextField('City', _cityController),
                _buildTextField('State', _stateController),
                _buildTextField('Pin Code', _pinCodeController, keyboardType: TextInputType.number),
                _buildTextField('Delivery', _deliveryController),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveStore,
                  child: Text('Save Store', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20),
              _buildStoreList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreList() {
    if (_stores.isEmpty) {
      return Text('No stores found');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _stores.length,
      itemBuilder: (context, index) {
        final store = _stores[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (store['ss_default'] == "1")
                  Text(
                    'Default',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  store['ss_name'],
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(store['ss_address']),
                SizedBox(height: 5),
                Text('${store['ss_city']}, ${store['ss_state']}'),
                SizedBox(height: 5),
                Text(store['ss_pincode']),
                SizedBox(height: 5),
                Text(store['ss_email']),
                SizedBox(height: 5),
                Text(store['ss_phone']),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      store['ss_delhivery'] == "1"
                          ? "Pickup Service Available"
                          : "Pickup Service Unavailable",
                      style: TextStyle(
                        color: store['ss_delhivery'] == "1"
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle make default store action
                  },
                  child: Text('Make Default'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  void _saveStore() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final sellerId = await _getSellerId(widget.username);
        if (sellerId != null) {
          final response = await http.post(
            Uri.parse('https://uoons.com/seller/create-store'),
            body: {
              'ss_seller_id': sellerId,
              'ss_name': _storeNameController.text,
              'ss_email': _storeEmailController.text,
              'ss_address': _storeAddressController.text,
              'ss_gst_number': _gstNumberController.text,
              'ss_phone': _phoneNumberController.text,
              'ss_city': _cityController.text,
              'ss_state': _stateController.text,
              'ss_pincode': _pinCodeController.text,
              'ss_delhivery': _deliveryController.text,
            },
          );
          if (response.statusCode == 200) {
            // Clear the form fields
            _storeNameController.clear();
            _storeEmailController.clear();
            _storeAddressController.clear();
            _gstNumberController.clear();
            _phoneNumberController.clear();
            _cityController.clear();
            _stateController.clear();
            _pinCodeController.clear();
            _deliveryController.clear();

            setState(() {
              _showStoreForm = false;
              _stores.add(jsonDecode(response.body)['data']);
              _stores.sort((a, b) => b['ss_default'].compareTo(a['ss_default']));
            });
          } else {
            print('Failed to save store: ${response.statusCode}');
          }
        }
      } catch (error) {
        print('Error saving store: $error');
      }
    }
  }

  Future<String?> _getSellerId(String username) async {
    final response = await http.get(
      Uri.parse('https://uoons.com/seller/get-user?username=$username'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['seller_id'] as String?;
    } else {
      print('Failed to fetch seller ID: ${response.statusCode}');
      return null;
    }
  }
}
