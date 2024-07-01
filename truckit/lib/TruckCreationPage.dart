import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Truck')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _truckNameController,
              decoration: InputDecoration(labelText: 'Truck Name'),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _createTruck,
                child: Text('Create Truck'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
