import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final box = await Hive.openBox('users');
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final user = box.get(username); // Retrieve the user record as a map

    if (user != null && user['password'] == password) {
      final loggedInBox = await Hive.openBox('loggedInUser');
      await loggedInBox.put('username', username);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _isLoading = false);
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Login Failed'),
        content: Text('Invalid username or password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(Icons.lock_outline,
                      size: 80, color: Colors.blueAccent),
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
                SizedBox(height: 10),
                Text(
                  'Please log in to continue',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Username cannot be empty'
                      : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Password cannot be empty'
                      : null,
                ),
                SizedBox(height: 30),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Login', style: TextStyle(fontSize: 18)),
                      ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterScreen())),
                  child: Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
