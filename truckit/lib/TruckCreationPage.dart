import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Homepage.dart'; // Import the Homepage

class TruckCreationPage extends StatefulWidget {
  final String companyId;

  TruckCreationPage({required this.companyId});

  @override
  _TruckCreationPageState createState() => _TruckCreationPageState();
}

class _TruckCreationPageState extends State<TruckCreationPage> {
  final TextEditingController _truckNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createTruck() async {
    await _firestore.collection('companies').doc(widget.companyId).collection('trucks').add({
      'name': _truckNameController.text,
    });

    Navigator.pop(context);
  }

  void _navigateToHomePage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Homepage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Truck', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => _navigateToHomePage(context),
        ),
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _truckNameController,
              decoration: InputDecoration(
                labelText: 'Truck Name',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _createTruck,
                child: Text('Create Truck'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button color
                  foregroundColor: Colors.blue, // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
