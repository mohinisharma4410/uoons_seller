import 'package:flutter/material.dart';
import 'package:uoons/Splash_Screens/SplashScreen2.dart';
import 'package:uoons/Splash_Screens/SplashScreen3.dart';
import 'package:uoons/Splash_Screens/SplashScreen4.dart';
import 'package:uoons/Splash_Screens/SplashScreen5.dart';
import 'package:uoons/swipablecards.dart';
import 'package:uoons/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uoons/Splash_Screens/splashscreen.dart';
import 'package:uoons/Profileprogressbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HomePage extends StatefulWidget {
  final String username;

  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool personalDetailsCompleted = true;
  bool manageStoresCompleted = true;
  bool kycUpdateCompleted = true;
  bool bankDetailsCompleted = true;

  final List<String> labels = ['Products', 'Sellers', 'Users', 'Orders'];
  List<double> values = [0, 0, 0, 0];

  String avatarUrl = '';
  String sellerId = '';

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
        sellerId = data['data']['s_id'];
      });
      fetchOrderStatistics();
    } else {
      // Handle error
      print('Failed to load seller data');
    }
  }

  Future<void> fetchOrderStatistics() async {
    final response = await http.get(Uri.parse('https://uoons.com/seller/total-charts?seller_id=$sellerId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        values = [
          data['data']['products'],
          data['data']['sellers'],
          data['data']['users'],
          data['data']['orders']
        ].map((value) => (value as num).toDouble()).toList(); // Casting values to double
      });
    } else {
      // Handle error
      print('Failed to load order statistics');
    }
  }

  Future<void> _handleRefresh() async {
    await fetchSellerData();
  }

  void _onPointTapped(ChartPointDetails details) {
    final int pointIndex = details.pointIndex!;
    final double value = values[pointIndex];
    final String label = labels[pointIndex];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label: $value'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Image.asset(
          "assets/Uoons seller logo.png",
          width: 80,
          height: 80,
        ),
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50), // Add some space
                Text(
                  'Profile Completed Percentage',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 40), // Add some space
                ProfileProgress(
                  personalDetailsCompleted: personalDetailsCompleted,
                  manageStoresCompleted: manageStoresCompleted,
                  kycUpdateCompleted: kycUpdateCompleted,
                  bankDetailsCompleted: bankDetailsCompleted,
                ),
                SizedBox(height: 25),
                Container(
                  height: 200,
                  width: 400,
                  child: ProfileCarousel(
                      personalDetailsCompleted: personalDetailsCompleted,
                      manageStoresCompleted: manageStoresCompleted,
                      kycUpdateCompleted: kycUpdateCompleted,
                      bankDetailsCompleted: bankDetailsCompleted,
                      username: widget.username
                  ),
                ),
                SizedBox(height: 30), // Add space between swipeable cards and chart
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Order Statistics',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 30),
                      SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(
                          interval: 500,
                          title: AxisTitle(
                            text: 'Number of Orders',
                            textStyle: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        series: <ChartSeries>[
                          BarSeries<ChartData, String>(
                            dataSource: [
                              ChartData(labels[0], values[0]),
                              ChartData(labels[1], values[1]),
                              ChartData(labels[2], values[2]),
                              ChartData(labels[3], values[3]),
                            ],
                            xValueMapper: (ChartData data, _) => data.label,
                            yValueMapper: (ChartData data, _) => data.value,
                            name: 'Orders',
                            color: Color.fromARGB(255, 248, 140, 131), // Set bar color to orange
                            animationDuration: 2000, // Animation duration in milliseconds
                            onPointTap: _onPointTapped,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text('Hello ${widget.username}', style: GoogleFonts.nunito()), // Apply Playfair Display font
                    accountEmail: null, // You can provide the user's email here
                    currentAccountPicture: Container(
                      alignment: Alignment.center,
                      child: Image.network(
                        avatarUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/Boy.png'); // Default avatar if network image fails
                        },
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.auto_graph_rounded),
                    title: Text('Analytics', style: GoogleFonts.nunito()), // Apply Playfair Display font
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ThirdScreen()),
                      ); // Navigate to Analytics screen
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text('Orders', style: GoogleFonts.nunito()), // Apply Playfair Display font
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FirstScreen(username: widget.username)),
                      ); // Navigate to Orders screen
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('My Profile', style: GoogleFonts.nunito()), // Apply Playfair Display font
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SecondScreen(username: widget.username)),
                      ); // Navigate to My Profile screen
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text('Products', style: GoogleFonts.nunito()), // Apply Playfair Display font
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FourthScreen(username: widget.username)),
                      ); // Navigate to My Profile screen
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.calculate_outlined),
                    title: Text('Calculate', style: GoogleFonts.nunito()), // Apply Playfair Display font
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FifthScreen(username: widget.username)),
                      ); // Navigate to My Profile screen
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.brightness_medium),
              title: Text('Theme', style: GoogleFonts.nunito()), // Apply Playfair Display font
              onTap: () {
                final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                themeProvider.toggleTheme(); // Call the method to toggle the theme
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}
