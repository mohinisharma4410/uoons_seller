import 'package:flutter/material.dart';
import 'package:uoons/profile/bank_details.dart';
import 'package:uoons/profile/kyc_update.dart';
import 'package:uoons/profile/managestore.dart';
import 'package:uoons/profile/personal_details.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileCarousel extends StatelessWidget {
  final bool personalDetailsCompleted;
  final bool manageStoresCompleted;
  final bool kycUpdateCompleted;
  final bool bankDetailsCompleted;
  final String username;

  final List<List<Color>> gradientColors = [
    [
      const Color.fromARGB(255, 255, 129, 3),
      const Color.fromARGB(255, 253, 203, 111),
    ],
    [
      const Color.fromARGB(255, 255, 129, 3),
      const Color.fromARGB(255, 253, 203, 111),
    ],
    [
      const Color.fromARGB(255, 255, 129, 3),
      const Color.fromARGB(255, 253, 203, 111),
    ],
    [
      const Color.fromARGB(255, 255, 129, 3),
      const Color.fromARGB(255, 253, 203, 111),
    ],
  ];

  ProfileCarousel({
    required this.personalDetailsCompleted,
    required this.manageStoresCompleted,
    required this.kycUpdateCompleted,
    required this.bankDetailsCompleted,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.8),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Transform.scale(
              scale: 1,
              child: ProfileCard(
                title: _getTitle(index),
                completed: _getCompletedStatus(index),
                gradientColors: gradientColors[index],
                username: username,
              ),
            );
          },
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Personal Details';
      case 1:
        return 'Manage Store';
      case 2:
        return 'Bank Details';
      case 3:
        return 'KYC Update';
      default:
        return '';
    }
  }

  bool _getCompletedStatus(int index) {
    switch (index) {
      case 0:
        return personalDetailsCompleted;
      case 1:
        return manageStoresCompleted;
      case 2:
        return bankDetailsCompleted;
      case 3:
        return kycUpdateCompleted;
      default:
        return false;
    }
  }
}

class ProfileCard extends StatelessWidget {
  final String title;
  final bool completed;
  final List<Color> gradientColors;
  final String username;

  ProfileCard({
    required this.title,
    required this.completed,
    required this.gradientColors,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ), // Use Playfair Display font
              ),
              SizedBox(height: 12.0), // Add some space between title and icon
              GestureDetector(
                onTap: () {
                  Widget destinationPage;
                  switch (title) {
                    case 'Personal Details':
                      destinationPage = PersonalDetailsPage(username: username);
                      break;
                    case 'Manage Store':
                      destinationPage = ManageStorePage(username: username);
                      break;
                    case 'Bank Details':
                      destinationPage = BankDetailsPage(username: username);
                      break;
                    case 'KYC Update':
                      destinationPage = KYCUpdatePage(username: username);
                      break;
                    default:
                      return;
                  }

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => destinationPage)).then((value) {
                    if (value != null && value) {
                      // Optionally update completion status
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // Background color of the circle
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    completed ? Icons.check : Icons.warning_amber,
                    color: completed ? Colors.green : Colors.red,
                    size: 40,
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
