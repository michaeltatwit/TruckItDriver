import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Home Screen'),
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'Welcome to the Home Screen!',
            style: TextStyle(color: Colors.white), // Ensure text is visible on the black background
          ),
        ),
      ),
    );
  }
}