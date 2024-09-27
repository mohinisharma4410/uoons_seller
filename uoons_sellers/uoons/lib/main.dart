import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uoons/orderschangenotifier.dart';
import 'package:uoons/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Login And Sign up/firebase_options.dart';
import 'orderspage.dart';
import 'Login And Sign up/Loginpage.dart';
import 'dashboardpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LoginFormState()),
        ChangeNotifierProvider(create: (context) => OrdersProvider()),
      ],
      child: LoginApp(),
    ),
  );
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Uoons',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.nunitoTextTheme(
              Theme.of(context).textTheme,
            ),
            colorScheme: themeProvider.themeData.colorScheme.copyWith(
              onSurface: themeProvider.themeData.brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            '/dashboard': (context) => DashboardPage(),
            '/orders': (context) => OrdersPage(username: 'example_user'), // Add route for OrdersPage
          },
        );
      },
    );
  }
}
