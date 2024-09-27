import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class KYCUpdatePage extends StatefulWidget {
  final String username;

  KYCUpdatePage({required this.username});

  @override
  _KYCUpdatePageState createState() => _KYCUpdatePageState();
}

class _KYCUpdatePageState extends State<KYCUpdatePage> {
  Map<String, String> kycDocuments = {
    'Govt. Id (Front Side)': '',
    'Govt. Id (Back Side)': '',
    'Gumasta': '',
    'GSTIN Certificate': '',
    'DIPP Certificate (If Startup)': '',
  };

  String selectedDocType = 'PDF';
  String selectedIdType = 'Voter ID';
  String gstinNumber = '';
  String dippNumber = '';
  String sellerId = '';

  @override
  void initState() {
    super.initState();
    _fetchSellerId();
  }

  Future<void> _fetchSellerId() async {
    final response = await http.get(Uri.parse('https://uoons.com/seller/get-user?username=${widget.username}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        sellerId = data['s_id'];
      });
    } else {
      // Handle the error
      print('Failed to fetch seller ID');
    }
  }

  bool _isKYCComplete() {
    return kycDocuments.values.every((doc) => doc.isNotEmpty) && gstinNumber.isNotEmpty && dippNumber.isNotEmpty;
  }

  void _updateDocumentFields(String idType) {
    setState(() {
      selectedIdType = idType;
      kycDocuments.clear();
      switch (idType) {
        case 'Voter ID':
          kycDocuments['Voter ID (Front Side)'] = '';
          kycDocuments['Voter ID (Back Side)'] = '';
          break;
        case 'Passport':
          kycDocuments['Passport (Front Side)'] = '';
          kycDocuments['Passport (Back Side)'] = '';
          break;
        case 'Pan Card':
          kycDocuments['Pan Card'] = '';
          break;
        case 'Driving License':
          kycDocuments['Driving License (Front Side)'] = '';
          kycDocuments['Driving License (Back Side)'] = '';
          break;
      }
      kycDocuments['Gumasta'] = '';
      kycDocuments['GSTIN Certificate'] = '';
      kycDocuments['DIPP Certificate (If Startup)'] = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('KYC Update'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'KYC - Know Your Customer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Upload your documents to complete the KYC process.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedDocType,
              items: ['PDF', 'PNG', 'JPG', 'JPEG'].map((String docType) {
                return DropdownMenuItem<String>(
                  value: docType,
                  child: Text(
                    docType,
                    style: TextStyle(color: textColor),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedDocType = newValue;
                  });
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Document Type',
                labelStyle: TextStyle(color: textColor),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedIdType,
              items: ['Voter ID', 'Passport', 'Pan Card', 'Driving License'].map((String idType) {
                return DropdownMenuItem<String>(
                  value: idType,
                  child: Text(
                    idType,
                    style: TextStyle(color: textColor),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  _updateDocumentFields(newValue);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Government ID Type',
                labelStyle: TextStyle(color: textColor),
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: kycDocuments.keys.map((document) {
                return _buildKYCField(document, kycDocuments[document]!, textColor);
              }).toList(),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey),
            SizedBox(height: 20),
            _buildFormField('GSTIN Number', gstinNumber, (value) {
              setState(() {
                gstinNumber = value;
              });
            }, textColor),
            SizedBox(height: 20),
            _buildFormField('DIPP Number (If Startup)', dippNumber, (value) {
              setState(() {
                dippNumber = value;
              });
            }, textColor),
            SizedBox(height: 20),
            Text(
              'Acceptable image formats are JPG, PNG, JPEG, PDF. Please upload the pictures in the mentioned formats.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isKYCComplete() ? () => _submitKYC() : null,
              child: Text('Submit KYC'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKYCField(String label, String filePath, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _pickDocument().then((filePath) {
                      if (filePath != null) {
                        setState(() {
                          kycDocuments[label] = filePath;
                        });
                      }
                    });
                  },
                  child: Text('Upload Document'),
                ),
                SizedBox(height: 20),
                if (filePath.isNotEmpty)
                  Text(
                    'File Path: $filePath',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(String label, String value, ValueChanged<String> onChanged, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        SizedBox(height: 10),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter $label',
            hintStyle: TextStyle(color: textColor),
          ),
          style: TextStyle(
            color: textColor,
          ),
        ),
      ],
    );
  }

  Future<String?> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result != null) {
      return result.files.single.path;
    }
    return null;
  }

  Future<void> _submitKYC() async {
    for (var entry in kycDocuments.entries) {
      final filePath = entry.value;
      final kycType = _mapLabelToKycType(entry.key);
      final request = http.MultipartRequest('POST', Uri.parse('https://uoons.com/seller/upload-kyc'))
        ..fields['kyc_type'] = kycType
        ..fields['seller_id'] = sellerId
        ..files.add(await http.MultipartFile.fromPath('kyc_doc', filePath));
      final response = await request.send();
      if (response.statusCode != 200) {
        print('Failed to upload ${entry.key}');
        // Handle the error appropriately
      }
    }

    // Upload GSTIN number and DIPP number
    final additionalData = {
      'GSTIN Number': gstinNumber,
      'DIPP Number': dippNumber,
    };
    for (var entry in additionalData.entries) {
      final request = http.MultipartRequest('POST', Uri.parse('https://uoons.com/seller/upload-kyc'))
        ..fields['kyc_type'] = _mapLabelToKycType(entry.key)
        ..fields['seller_id'] = sellerId
        ..fields['kyc_doc'] = entry.value;
      final response = await request.send();
      if (response.statusCode != 200) {
        print('Failed to upload ${entry.key}');
        // Handle the error appropriately
      }
    }

    print('KYC documents submitted: $kycDocuments');
    print('GSTIN Number: $gstinNumber');
    print('DIPP Number: $dippNumber');
    // Add further logic for handling the response or navigation
  }

  String _mapLabelToKycType(String label) {
    switch (label) {
      case 'Voter ID (Front Side)':
      case 'Voter ID (Back Side)':
        return 'sk_voter_id';
      case 'Passport (Front Side)':
      case 'Passport (Back Side)':
        return 'sk_passport';
      case 'Pan Card':
        return 'sk_pan_card';
      case 'Driving License (Front Side)':
      case 'Driving License (Back Side)':
        return 'sk_driving_license';
      case 'Gumasta':
        return 'sk_gumasta';
      case 'GSTIN Certificate':
        return 'sk_gst_certificate';
      case 'DIPP Certificate (If Startup)':
        return 'sk_dipp_certificate';
      case 'GSTIN Number':
        return 'sk_gst_number';
      case 'DIPP Number':
        return 'sk_dipp_number';
      default:
        return '';
    }
  }
}
