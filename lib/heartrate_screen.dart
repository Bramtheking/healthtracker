import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:image/image.dart' as img;

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
  List<int> _colorIntensities = [];
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
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        _captureFrame();
      });
      isMeasuring = true;
    }
  }

  // Stop measuring the heart rate
  void _stopHeartRateMeasurement() {
    _timer?.cancel();
    _cameraController.setFlashMode(FlashMode.off); // Turn off flash
    isMeasuring = false;
    if (_colorIntensities.length > 1) {
      _calculateHeartRate();
      _colorIntensities.clear();
    }
  }

  // Capture a frame from the camera and process it
  Future<void> _captureFrame() async {
    final image = await _cameraController.takePicture();
    final img.Image capturedImage = img.decodeImage(await image.readAsBytes())!;
    final int brightness = _getAverageBrightness(capturedImage);
    _colorIntensities.add(brightness);
  }

  // Calculate the average brightness of an image
  int _getAverageBrightness(img.Image image) {
    int totalBrightness = 0;
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        final red = img.getRed(pixel);
        final green = img.getGreen(pixel);
        final blue = img.getBlue(pixel);
        final brightness = (red + green + blue) ~/ 3;
        totalBrightness += brightness;
      }
    }
    return totalBrightness ~/ (image.width * image.height);
  }

  // Calculate the heart rate from the color intensities
  void _calculateHeartRate() {
    if (_colorIntensities.isNotEmpty) {
      final peaks = _detectPeaks(_colorIntensities);
      final timeBetweenPeaks = peaks.length > 1 ? 60000 ~/ (peaks.length) : 0; // BPM
      setState(() {
        currentHeartRate = timeBetweenPeaks.toDouble();
      });
      _addHeartRate(currentHeartRate);
    }
  }

  // Detect peaks in the color intensity data
  List<int> _detectPeaks(List<int> data) {
    List<int> peaks = [];
    for (int i = 1; i < data.length - 1; i++) {
      if (data[i] > data[i - 1] && data[i] > data[i + 1]) {
        peaks.add(i);
      }
    }
    return peaks;
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
            '${currentHeartRate.toStringAsFixed(1)} bpm',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          SizedBox(height: 20),
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
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}
