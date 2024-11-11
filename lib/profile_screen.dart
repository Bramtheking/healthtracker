import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String name = '';
  String email = '';
  int age = 0;
  String place = '';
  bool isEditing = false;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController ageController;
  late TextEditingController placeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    ageController = TextEditingController();
    placeController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    placeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
  final box = await Hive.openBox('users');
  final loggedInUsername = await Hive.box('loggedInUser').get('username');
  final userData = box.get(loggedInUsername);

  setState(() {
    username = loggedInUsername ?? '';  // Default to empty string if null
    name = userData?['name'] ?? '';  // Default to empty string if null
    email = userData?['email'] ?? '';  // Default to empty string if null
    age = userData?['age'] ?? 0;  // Default to 0 if null
    place = userData?['place'] ?? '';  // Default to empty string if null

    nameController.text = name;
    emailController.text = email;
    ageController.text = age.toString();
    placeController.text = place;
  });
}

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      final box = await Hive.openBox('users');
      await box.put(username, {
        'name': nameController.text,
        'email': emailController.text,
        'age': int.parse(ageController.text),
        'place': placeController.text,
      });

      setState(() {
        name = nameController.text;
        email = emailController.text;
        age = int.parse(ageController.text);
        place = placeController.text;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Profile', style: TextStyle(color: Colors.black87)),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.black87),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
                if (!isEditing) {
                  nameController.text = name;
                  emailController.text = email;
                  ageController.text = age.toString();
                  placeController.text = place;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 40, color: Colors.blue[900]),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(
                      icon: Icons.person,
                      title: 'Full Name',
                      value: name,
                      controller: nameController,
                      isEditing: isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.email,
                      title: 'Email',
                      value: email,
                      controller: emailController,
                      isEditing: isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.cake,
                      title: 'Age',
                      value: age.toString(),
                      controller: ageController,
                      isEditing: isEditing,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Place of Residence',
                      value: place,
                      controller: placeController,
                      isEditing: isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your place of residence';
                        }
                        return null;
                      },
                    ),
                    if (isEditing) ...[
                      SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveUserData,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('Save Changes'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (isEditing)
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: keyboardType,
              validator: validator,
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
