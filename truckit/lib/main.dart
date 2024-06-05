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
        body: const LoginWidget(),
      ),
    );
  }
}

class LoginWidget extends StatelessWidget {
  const LoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 0.0),
            const Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Username',
                hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Login button pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                );
              },
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
            // spacing between arrow icon and divider
            const SizedBox(height: 50.0),
            const Row(
              children: <Widget>[
                Expanded(
                  // left divider
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
                  // right divider
                  child: Divider(
                    color: Colors.white,
                    thickness: 1,
                    indent: 10,
                    endIndent: 50,
                  ),
                ),
              ],
            ),
            // space between divider and Register button
            const SizedBox(height: 50.0),
            // Register button
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
        ),
      ),
    );
  }
}
