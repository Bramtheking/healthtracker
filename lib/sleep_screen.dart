import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class SleepScreen extends StatefulWidget {
  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  bool isSleeping = false;
  bool isPaused = false;
  int sleepDuration = 0; // Tracks sleep duration in minutes
  int qualityPercentage = 0;
  late Box sleepBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    sleepBox = await Hive.openBox('sleepBox');
    setState(() {}); // Update UI after initializing Hive
  }

  void _startSleep() {
    setState(() {
      isSleeping = true;
      isPaused = false;
      sleepDuration = 0; // Reset duration for a new sleep session
    });
  }

  void _pauseSleep() {
    setState(() {
      isPaused = true;
    });
  }

  void _stopSleep() {
    setState(() {
      isSleeping = false;
      isPaused = false;
      qualityPercentage = (sleepDuration / 600 * 100).toInt(); // Calculate quality as percentage
    });
    _saveSleepData(sleepDuration, qualityPercentage);
  }

  void _saveSleepData(int duration, int quality) {
    sleepBox.add({
      'duration': duration,
      'quality': quality,
      'timestamp': DateTime.now().toString(),
    });
    setState(() {}); // Refresh UI to reflect saved data
  }

  String _getRecommendation() {
    if (sleepDuration < 120) return "You need much more sleep for health.";
    if (sleepDuration < 240) return "Aim for more sleep to improve quality.";
    if (sleepDuration < 360) return "Almost there, try to get a bit more rest.";
    if (sleepDuration < 480) return "Good work, but more rest could be beneficial.";
    return "Excellent! You've achieved optimal rest.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Sleep Tracker'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.dark_mode),
            onPressed: () {
              // Night mode toggle logic here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildClock(),
            SizedBox(height: 20),
            _buildSleepQualitySection(),
            SizedBox(height: 20),
            _buildGoalTracker(),
            SizedBox(height: 20),
            _buildControlButtons(),
            SizedBox(height: 20),
            _buildRecommendationText(),
            SizedBox(height: 20),
            _buildSleepHistory(),
            SizedBox(height: 20),
            _buildAmbientSoundOptions(),
            SizedBox(height: 20),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildClock() {
    return Center(
      child: Column(
        children: [
          Text(
            DateFormat('hh:mm a').format(DateTime.now()),
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
          Text(
            'Current Time',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepQualitySection() {
    return Column(
      children: [
        Text(
          'Sleep Quality',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        CircularProgressIndicator(
          value: qualityPercentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
        SizedBox(height: 10),
        Text(
          '$qualityPercentage% Sleep Quality',
          style: TextStyle(fontSize: 18, color: Colors.blueAccent),
        ),
      ],
    );
  }

  Widget _buildGoalTracker() {
    return Column(
      children: [
        Text(
          'Sleep Goal: 8 hours',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        LinearProgressIndicator(
          value: sleepDuration / 480,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow),
          color: Colors.green,
          onPressed: _startSleep,
          iconSize: 40,
        ),
        IconButton(
          icon: Icon(Icons.pause),
          color: Colors.orange,
          onPressed: isSleeping ? _pauseSleep : null,
          iconSize: 40,
        ),
        IconButton(
          icon: Icon(Icons.stop),
          color: Colors.red,
          onPressed: isSleeping ? _stopSleep : null,
          iconSize: 40,
        ),
      ],
    );
  }

  Widget _buildRecommendationText() {
    return Text(
      _getRecommendation(),
      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSleepHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sleep History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ValueListenableBuilder(
          valueListenable: sleepBox.listenable(),
          builder: (context, box, widget) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: sleepBox.length,
              itemBuilder: (context, index) {
                final data = sleepBox.getAt(index) as Map;
                final date = DateFormat('yyyy-MM-dd').format(DateTime.parse(data['timestamp']));
                return ListTile(
                  title: Text('Duration: ${data['duration']} min'),
                  subtitle: Text('Quality: ${data['quality']}% - $date'),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmbientSoundOptions() {
    return Column(
      children: [
        Text(
          'Ambient Sound',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          children: ['Rain', 'Waves', 'Forest', 'White Noise']
              .map((sound) => ChoiceChip(
                    label: Text(sound),
                    selected: false,
                    onSelected: (selected) {
                      // Handle sound selection logic here
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return Column(
      children: [
        Text(
          'Achievements',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          children: [
            Icon(Icons.bedtime, color: Colors.blue, size: 30),
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            Icon(Icons.star, color: Colors.amber, size: 30),
          ],
        ),
      ],
    );
  }
}
