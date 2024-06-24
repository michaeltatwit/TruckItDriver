import 'package:flutter/material.dart';
import 'MenuCreationPage.dart';
import 'ProfileCreationPage.dart';
import 'MapScreen.dart'; // Import the new DriverMapScreen

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Homepage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileCreationPage()),
                );
              },
              child: Text('Create Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuCreationPage()),
                );
              },
              child: Text('Create Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
