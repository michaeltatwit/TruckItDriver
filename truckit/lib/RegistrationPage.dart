import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Homepage.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPage createState() => _RegistrationPage();
}

class _RegistrationPage extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _companyIdController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _errorMessage = '';

  Future<void> _register() async {
  try {
    // Check if company ID already exists
    QuerySnapshot companySnapshot = await _firestore
        .collection('companies')
        .where('name', isEqualTo: _companyIdController.text)
        .get();
    if (companySnapshot.docs.isNotEmpty) {
      setState(() {
        _errorMessage = 'Company ID already exists. Please choose a different one.';
      });
      return;
    }

    // Create user
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    User? user = userCredential.user;

    if (user != null) {
      // Create a new document in the companies collection with an auto-generated ID
      DocumentReference newCompanyRef = await _firestore.collection('companies').add({
        'name': _companyIdController.text, // You can replace this with a more meaningful name
      });
      String newCompanyId = newCompanyRef.id; // This is the auto-generated ID for the new document

      // Create a new document in the users collection with the company ID
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'companyId': newCompanyId, // Use the auto-generated ID
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    }
  } catch (e) {
    print('Error registering: $e');
    setState(() {
      _errorMessage = 'Registration failed. Please try again.';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Your Truck', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1E),
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFieldWidget(
                controller: _emailController,
                hintText: 'Email',
              ),
              const SizedBox(height: 16.0),
              TextFieldWidget(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              TextFieldWidget(
                controller: _companyIdController,
                hintText: 'Company ID',
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  minimumSize: Size(300, 50),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19.0,
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
        filled: true,
        fillColor: Colors.white24,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardAppearance: Brightness.dark, // Ensures keyboard matches phone's dark mode setting
    );
  }
}
