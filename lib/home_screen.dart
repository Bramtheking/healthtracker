import 'package:flutter/material.dart';
import 'package:myapp/settings_screen.dart';
import 'package:myapp/medical_chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(context),
      body: _buildBody(context),
         floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MedicalChatScreen()), // Navigate to AI chat screen
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.chat),
      )
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile'); // Navigate to profile screen
          },
          child: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, color: Colors.blue),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Tracker',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            'Stay healthy, stay fit',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        
        IconButton(
          icon: Icon(Icons.settings_outlined, color: Colors.black87),
          onPressed: () {
           Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()), // Navigate to SettingsScreen
              );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          _buildHealthMetricsGrid(context),
          _buildGoalsSection(context),
          _buildRemindersSection(context),
          _buildcontactSection(context),
      
        ],
      ),
    );
  }

 Widget _buildWelcomeSection() {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
    ),
    child: Center(  // Center the column inside the container
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,  // Vertically center content
        crossAxisAlignment: CrossAxisAlignment.center,  // Horizontally center content
        children: [
          Text(
            'Welcome',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Track your health metrics and achieve your goals',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,  // Center the second text
          ),
        ],
      ),
    ),
  );
}


  Widget _buildHealthMetricsGrid(BuildContext context) {
    // Fetch data from Hive and display in the cards
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Metrics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildMetricCard(
                context,
                title: 'Heart Rate',
                value: '72', // Placeholder; replace with Hive data
                unit: 'bpm',
                icon: Icons.favorite,
                color: Colors.red,
                route: '/heartRate',
              ),
              _buildMetricCard(
                context,
                title: 'Steps',
                value: '5,234', // Placeholder; replace with Hive data
                unit: 'steps',
                icon: Icons.directions_walk,
                color: Colors.green,
                route: '/steps',
              ),
              _buildMetricCard(
                context,
                title: 'Sleep',
                value: '7.45', // Placeholder; replace with Hive data
                unit: 'hours',
                icon: Icons.nightlight_round,
                color: Colors.indigo,
                route: '/sleep',
              ),
              _buildMetricCard(
                context,
                title: 'Diet',
                value: '1,800', // Placeholder; replace with Hive data
                unit: 'kcal',
                icon: Icons.restaurant,
                color: Colors.orange,
                route: '/diet',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context) {
  return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/goal');
            },
            child: Text('Access your goal here'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required double progress,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSection(BuildContext context) {
     return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminder',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/reminder');
            },
            child: Text('Medication reminder over here'),
          ),
        ],
      ),
    );
  }

  Widget _buildcontactSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Doctor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/contactDoctor');
            },
            child: Text('In case of emergency cotact doctor here'),
          ),
        ],
      ),
    );
  }

 
}