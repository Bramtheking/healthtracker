import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDoctorScreen extends StatefulWidget {
  const ContactDoctorScreen({super.key});

  @override
  _ContactDoctorScreenState createState() => _ContactDoctorScreenState();
}

class _ContactDoctorScreenState extends State<ContactDoctorScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  late Box doctorBox;
  List<Map<String, String>> doctorList = [];
  bool showForm = false;
  int? selectedDoctorIndex;

  @override
  void initState() {
    super.initState();
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    doctorBox = await Hive.openBox('doctorBox');
    _loadDoctors();
  }

  void _loadDoctors() {
    final savedDoctors = doctorBox.get('doctors', defaultValue: []);
    setState(() {
      doctorList = List<Map<String, String>>.from(savedDoctors);
    });
  }

  void _saveDoctor() {
    final newDoctor = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
    };

    if (selectedDoctorIndex != null) {
      // Edit existing doctor
      doctorList[selectedDoctorIndex!] = newDoctor;
      selectedDoctorIndex = null;
    } else {
      // Add new doctor
      doctorList.add(newDoctor);
    }

    doctorBox.put('doctors', doctorList);
    _clearForm();
    setState(() {
      showForm = false;
    });
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
  }

  void _selectDoctor(int index) {
    setState(() {
      selectedDoctorIndex = index;
      _nameController.text = doctorList[index]['name']!;
      _phoneController.text = doctorList[index]['phone']!;
      _emailController.text = doctorList[index]['email']!;
      showForm = true;
    });
  }

  void _callDoctor() async {
    if (selectedDoctorIndex == null) return;
    final phone = doctorList[selectedDoctorIndex!]['phone'];
    if (phone != null && await canLaunch('tel:$phone')) {
      await launch('tel:$phone');
    } else {
      _showSnackbar('Could not launch phone call');
    }
  }

  void _emailDoctor() async {
    if (selectedDoctorIndex == null) return;
    final email = doctorList[selectedDoctorIndex!]['email'];
    if (email != null && await canLaunch('mailto:$email')) {
      await launch('mailto:$email');
    } else {
      _showSnackbar('Could not launch email client');
    }
  }

  void _callEmergency() async {
    if (await canLaunch('tel:911')) {
      await launch('tel:911');
    } else {
      _showSnackbar('Could not launch emergency call');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Contact Information'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _callDoctor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: Text('Call Doctor'),
                ),
                ElevatedButton(
                  onPressed: _emailDoctor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: Text('Email Doctor'),
                ),
                ElevatedButton(
                  onPressed: _callEmergency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: Text('Emergency Call 911'),
                ),
              ],
            ),
            SizedBox(height: 20),
            DropdownButton<int>(
              hint: Text("Select Doctor"),
              value: selectedDoctorIndex,
              items: doctorList.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> doctor = entry.value;
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text(doctor['name']!),
                );
              }).toList(),
              onChanged: (int? newIndex) {
                if (newIndex != null) {
                  _selectDoctor(newIndex);
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showForm = true;
                  _clearForm();
                  selectedDoctorIndex = null;
                });
              },
              child: Text('Add Doctor'),
            ),
            if (showForm) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Doctor Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Doctor Phone'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Doctor Email'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDoctor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text(selectedDoctorIndex == null ? 'Save' : 'Update'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
