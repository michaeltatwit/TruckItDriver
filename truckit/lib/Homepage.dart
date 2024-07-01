import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'TruckCreationPage.dart';
import 'ProfileCreationPage.dart';
import 'MapScreen.dart'; // Import the new DriverMapScreen
import 'MenuCreationPage.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final String companyId = 'your_company_id'; // Replace with actual company ID
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Homepage'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('companies').doc(companyId).collection('trucks').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var trucks = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: trucks.length,
                  itemBuilder: (context, index) {
                    var truck = trucks[index];
                    return Card(
                      child: ListTile(
                        title: Text(truck['name']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TruckDetailPage(companyId: companyId, truckId: truck.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TruckCreationPage(companyId: companyId)),
                );
              },
              child: Text('Create Truck'),
            ),
          ),
        ],
      ),
    );
  }
}

class TruckDetailPage extends StatelessWidget {
  final String companyId;
  final String truckId;

  TruckDetailPage({required this.companyId, required this.truckId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Truck Details'),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileCreationPage(companyId: companyId, truckId: truckId),
                  ),
                );
              },
              child: Text('Edit Profile'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuCreationPage(companyId: companyId, truckId: truckId),
                  ),
                );
              },
              child: Text('Edit Menu'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(companyId: companyId, truckId: truckId),
                  ),
                );
              },
              child: Text('View Map / Go Live'),
            ),
          ),
        ],
      ),
    );
  }
}
