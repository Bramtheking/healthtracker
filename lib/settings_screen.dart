import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      backgroundColor: themeNotifier.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        backgroundColor: themeNotifier.isDarkMode ? Colors.grey[900] : Colors.blue,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Dark Mode Toggle
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(fontSize: 18, color: themeNotifier.isDarkMode ? Colors.white : Colors.black),
              ),
              trailing: Switch(
                value: themeNotifier.isDarkMode,
                onChanged: (value) {
                  themeNotifier.toggleTheme(value);
                },
                activeColor: Colors.blueAccent,
              ),
            ),
          ),
          
          // Language Selection
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                'Language',
                style: TextStyle(fontSize: 18, color: themeNotifier.isDarkMode ? Colors.white : Colors.black),
              ),
              trailing: DropdownButton<String>(
                value: 'English', // default language
                items: <String>['English', 'Spanish', 'French', 'German'].map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (String? newLanguage) {
                  // Implement language change logic
                },
              ),
            ),
          ),

          // Notification Settings
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                'Notifications',
                style: TextStyle(fontSize: 18, color: themeNotifier.isDarkMode ? Colors.white : Colors.black),
              ),
              trailing: Switch(
                value: true, // default notification setting
                onChanged: (bool value) {
                  // Implement notification toggle logic
                },
                activeColor: Colors.blueAccent,
              ),
            ),
          ),

          // Logout Button
          Card(
            elevation: 5,
            margin: EdgeInsets.symmetric(vertical: 10),
            color: themeNotifier.isDarkMode ? Colors.grey[800] : Colors.red[400],
            child: ListTile(
              title: Center(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () async {
                // Clear user data from Hive
                final loggedInBox = await Hive.openBox('loggedInUser');
                loggedInBox.delete('username');

                // Navigate to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
