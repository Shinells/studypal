import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
//import 'dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '', username = '';
  String confirmPassword = '';
  final AuthService _auth = AuthService();
  bool _saving = false;

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _saving = true);
      var error = await _auth.registerWithEmail(email, password);
      if (error == null) {
        // Save username to Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'username': username, 'email': email});
        }
        // Redirect to login after registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration failed: $error')));
      }
      setState(() => _saving = false);
    }
  }

  String? _validateEmail(String? val) {
    if (val == null || val.isEmpty) return 'Enter a valid email';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? val) {
    if (val == null || val.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateUsername(String? val) {
    if (val == null || val.trim().isEmpty) return 'Enter a username';
    if (val.length < 3) return 'Username too short';
    return null;
  }

  String? _validateConfirmPassword(String? val) {
    if (val == null || val != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.primary.withOpacity(0.4),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Register',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        SizedBox(height: 24),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person),
                          ),
                          onChanged: (val) => username = val,
                          validator: _validateUsername,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          onChanged: (val) => email = val,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          onChanged: (val) => password = val,
                          validator: _validatePassword,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          onChanged: (val) => confirmPassword = val,
                          validator: _validateConfirmPassword,
                        ),
                        SizedBox(height: 24),
                        _saving
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: register,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    "Register",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                        SizedBox(height: 16),
                        TextButton(
                          child: Text("Already have an account? Login"),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
