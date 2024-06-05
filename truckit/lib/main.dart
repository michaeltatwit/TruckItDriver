import 'package:flutter/material.dart';
import 'Homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF1C1C1E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C1C1E),
        ),
        body: const LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            LoginForm(),
          ],
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    // Handle login logic here
    print('Username: ${_usernameController.text}, Password: ${_passwordController.text}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Homepage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFieldWidget(
          controller: _usernameController,
          hintText: 'Username',
        ),
        const SizedBox(height: 16.0),
        TextFieldWidget(
          controller: _passwordController,
          hintText: 'Password',
          obscureText: true,
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 50.0),
        const DividerWithText(),
        const SizedBox(height: 50.0),
        ElevatedButton(
          onPressed: () {
            // Register button pressed
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            minimumSize: Size(300, 50),
          ),
          child: const Text(
            'Register Your Truck',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 19.0,
            ),
          ),
        ),
      ],
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
    );
  }
}

class DividerWithText extends StatelessWidget {
  const DividerWithText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: Divider(
            color: Colors.white,
            thickness: 1,
            indent: 50,
            endIndent: 10,
          ),
        ),
        Text(
          'or',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        Expanded(
          child: Divider(
            color: Colors.white,
            thickness: 1,
            indent: 10,
            endIndent: 50,
          ),
        ),
      ],
    );
  }
}