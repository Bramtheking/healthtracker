import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:myapp/contact_doctor_screen.dart';
import 'package:myapp/diet_screen.dart';
import 'package:myapp/goal_screen.dart';
import 'package:myapp/heartrate_screen.dart';
import 'package:myapp/profile_screen.dart';
import 'package:myapp/reminder_screen.dart';
import 'package:myapp/settings_screen.dart';
import 'package:myapp/sleep_screen.dart';
import 'package:myapp/steps_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('users');
  await Hive.openBox('loggedInUser');

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Health Tracker App',
          debugShowCheckedModeBanner: false,
          theme: themeNotifier.themeData,
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            '/login': (context) => LoginScreen(),
            '/home': (context) => HomeScreen(),
            '/profile': (context) => ProfileScreen(),
            '/steps': (context) => StepsScreen(),
            '/heartRate': (context) => HeartRateScreen(),
            '/sleep': (context) => SleepScreen(),
            '/reminder': (context) => RemindersScreen(),
            '/contactDoctor': (context) => ContactDoctorScreen(),
            '/diet': (context) => DietTrackerScreen(),
            '/goal': (context) => GoalsScreen(),
            '/settings': (context) => SettingsScreen(),
          },
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final loggedInBox = await Hive.openBox('loggedInUser');
    final username = loggedInBox.get('username');

    await Future.delayed(const Duration(seconds: 3));

    if (username != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety, size: 100, color: Colors.blueAccent),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Health Tracker',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your personal health companion',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
