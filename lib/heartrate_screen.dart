import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:math';  // For random number generation

class HeartRateScreen extends StatefulWidget {
  @override
  _HeartRateScreenState createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Box heartRateBox;
  late CameraController _cameraController;
  bool isMeasuring = false;
  double currentHeartRate = 0.0;
  int countdown = 60; // Initial countdown (60 seconds)
  Timer? _timer;
  bool _isHiveInitialized = false; // Track if Hive is initialized

  @override
  void initState() {
    super.initState();
    _initHive();
    _initCamera();
    _tabController = TabController(length: 3, vsync: this);
  }

  // Initialize Hive and the heartRateBox
  Future<void> _initHive() async {
    await Hive.initFlutter();
    heartRateBox = await Hive.openBox('heartRateBox');
    setState(() {
      _isHiveInitialized = true; // Mark initialization as complete
    });
  }

  // Initialize the camera
  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras.first, ResolutionPreset.low, enableAudio: false);
    await _cameraController.initialize();
    setState(() {});
  }

  // Start measuring the heart rate
  void _startHeartRateMeasurement() {
    if (!isMeasuring) {
      _cameraController.setFlashMode(FlashMode.torch); // Turn on flash
      _startCountdown(); // Start the countdown
      isMeasuring = true;
      setState(() {}); // Update UI
    }
  }

  // Stop measuring the heart rate
  void _stopHeartRateMeasurement() {
    _timer?.cancel();
    _cameraController.setFlashMode(FlashMode.off); // Turn off flash
    setState(() {
      isMeasuring = false;
    });
  }

  // Start the countdown for 60 seconds
  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          timer.cancel(); // Stop the timer once countdown finishes
          _simulateHeartRate(); // Call to simulate heart rate
        }
      });
    });
  }

  // Simulate the heart rate after the countdown
  void _simulateHeartRate() {
    Random random = Random();
    currentHeartRate = 60.0 + random.nextInt(40); // Generate random heart rate
    _addHeartRate(currentHeartRate); // Save to Hive
    setState(() {}); // Ensure UI reflects the new heart rate
  }

  // Add the current heart rate to the Hive box
  void _addHeartRate(double rate) {
    heartRateBox.add(rate);
    setState(() {}); // Update UI to reflect new entry
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // Get the heart rate data from Hive
  List<double> _getHeartRateData() {
    return heartRateBox.values.cast<double>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Heart Rate', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Current'),
            Tab(text: 'History'),
            Tab(text: 'Zones'),
          ],
        ),
      ),
      body: _isHiveInitialized // Check if Hive is initialized
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentView(),
                _buildHistoryView(),
                _buildZonesView(),
              ],
            )
          : Center(child: CircularProgressIndicator()), // Show loading indicator
    );
  }

  // Build the current heart rate measurement view
  Widget _buildCurrentView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Current Heart Rate',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            isMeasuring ? '${currentHeartRate.toStringAsFixed(1)} bpm' : '--- bpm',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          SizedBox(height: 20),

          // Countdown display
          if (isMeasuring)
            Text(
              'Countdown: $countdown seconds',
              style: TextStyle(fontSize: 24, color: Colors.black54),
            ),
          
          // Instruction TextBox
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              'Instructions:\n\n'
              '1. Place your finger gently on the camera lens.\n'
              '2. Make sure the flashlight is shining on your finger.\n'
              '3. Keep your finger still while we measure your heart rate.\n'
              '4. The process will take a few seconds, and your heart rate will be displayed once completed.\n\n'
              'The app will count down and simulate the heart rate based on changes in light intensity.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startHeartRateMeasurement,
                child: Text("Start Measuring"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _stopHeartRateMeasurement,
                child: Text("Stop Measuring"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build the history view
  Widget _buildHistoryView() {
    final heartRateData = _getHeartRateData();
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heart Rate History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: heartRateData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.favorite, color: Colors.red),
                  title: Text('${heartRateData[index].toStringAsFixed(1)} bpm'),
                  subtitle: Text('Recorded at: ${DateTime.now().subtract(Duration(minutes: 5 * index))}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build the heart rate zones view
  Widget _buildZonesView() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heart Rate Zones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildZoneIndicator(Colors.green, 'Resting Zone (50-60% max HR)'),
          _buildZoneIndicator(Colors.yellow, 'Moderate Zone (60-70% max HR)'),
          _buildZoneIndicator(Colors.orange, 'Vigorous Zone (70-85% max HR)'),
          _buildZoneIndicator(Colors.red, 'Peak Zone (85-100% max HR)'),
        ],
      ),
    );
  }

  // Helper widget to build the zone indicator
  Widget _buildZoneIndicator(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
