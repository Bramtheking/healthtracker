import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _placeController = TextEditingController();

  bool _errorMessageVisible = false;

  void _register() async {
    final box = await Hive.openBox('users');
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final age = int.tryParse(_ageController.text.trim());
    final place = _placeController.text.trim();

    if (box.containsKey(username)) {
      setState(() {
        _errorMessageVisible = true;
      });
    } else {
      await box.put(username, {
        'password': password,
        'name': name,
        'email': email,
        'age': age,
        'place': place,
      });

      setState(() {
        _errorMessageVisible = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registered successfully! Now enter your login details')),
      );

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 30),
                _buildTextField(_nameController, 'Full Name', Icons.person),
                _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
                _buildTextField(_usernameController, 'Username', Icons.account_circle),
                _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
                _buildTextField(_ageController, 'Age', Icons.calendar_today, keyboardType: TextInputType.number),
                _buildTextField(_placeController, 'Place of Residence', Icons.home),
                if (_errorMessageVisible)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Text(
                        'Username already exists.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _register();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 5,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      child: Text('Register', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueAccent),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          filled: true,
          fillColor: Colors.white70,
        ),
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label.toLowerCase()';
          }
          if (label == 'Email' && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}").hasMatch(value)) {
            return 'Enter a valid email address';
          }
          if (label == 'Password' && value.length < 6) {
            return 'Password should be at least 6 characters';
          }
          if (label == 'Age' && (int.tryParse(value) == null || int.parse(value) <= 0)) {
            return 'Please enter a valid age';
          }
          return null;
        },
      ),
    );
  }
}
