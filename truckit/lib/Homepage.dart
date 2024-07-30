import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'TruckCreationPage.dart';
import 'ProfileCreationPage.dart';
import 'MapScreen.dart';
import 'MenuCreationPage.dart';
import 'RegistrationPage.dart'; // Import the registration page to navigate back to it after logout
import 'main.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? companyId;

  @override
  void initState() {
    super.initState();
    _getCompanyId();
  }

  Future<void> _getCompanyId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        companyId = userDoc['companyId'];
      });
    }
  }

  Future<void> _logout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _navigateToProfileCreationPage(String truckId) async {
    final imageUrl = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileCreationPage(
          companyId: companyId!,
          truckId: truckId,
        ),
      ),
    );

    if (imageUrl != null) {
      setState(() {
        // Update the state to refresh the profile image
      });
    }
  }

  void _showBottomSheet(BuildContext context, String truckId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToProfileCreationPage(truckId);
                },
              ),
              ListTile(
                leading: Icon(Icons.restaurant_menu, color: Colors.white),
                title: Text('Edit Menu', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuCreationPage(
                        companyId: companyId!,
                        truckId: truckId,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.white),
                title: Text('Delete Truck', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteTruck(truckId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Driver Homepage',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1C1C1E),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        body: companyId == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('companies')
                          .doc(companyId)
                          .collection('trucks')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        var trucks = snapshot.data!.docs;
                        return ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: trucks.length,
                          itemBuilder: (context, index) {
                            var truck = trucks[index];
                            return FutureBuilder<DocumentSnapshot>(
                              future: truck.reference.collection('profile').doc('profile').get(),
                              builder: (context, profileSnapshot) {
                                if (!profileSnapshot.hasData) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                var profileData = profileSnapshot.data?.data() as Map<String, dynamic>?;
                                var imageUrl = profileData?['imageUrl'] ?? '';
                                var description = profileData?['description'] ?? 'No description';

                                // truck widgets
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  color: Color(0xFF2C2C2E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Adjust padding
                                    leading: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _showBottomSheet(context, truck.id),
                                          child: CircleAvatar(
                                            backgroundImage: imageUrl.isNotEmpty
                                                ? NetworkImage(imageUrl)
                                                : null,
                                            radius: 20.0,
                                            child: imageUrl.isEmpty
                                                ? const Icon(Icons.account_circle, size: 40.0, color: Colors.white)
                                                : null,
                                          ),
                                        ),
                                        SizedBox(height: 2), // Add spacing between image and edit text
                                        GestureDetector(
                                          onTap: () => _showBottomSheet(context, truck.id),
                                          child: const Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 10.0, // Make the text smaller
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      truck['name'],
                                      style: const TextStyle(color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MapScreen(
                                            companyId: companyId!,
                                            truckId: truck.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TruckCreationPage(companyId: companyId!),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Button color
                        foregroundColor: Colors.blue, // Text color
                        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('Create Truck'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _confirmDeleteTruck(String truckId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Truck'),
          content: Text('Are you sure you want to delete this truck?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTruck(truckId);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTruck(String truckId) async {
    // Delete all sections and items
    QuerySnapshot sectionsSnapshot = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('trucks')
        .doc(truckId)
        .collection('sections')
        .get();

    for (DocumentSnapshot section in sectionsSnapshot.docs) {
      QuerySnapshot itemsSnapshot = await section.reference.collection('items').get();
      for (DocumentSnapshot item in itemsSnapshot.docs) {
        await item.reference.delete();
      }
      await section.reference.delete();
    }

    // Delete the profile
    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('trucks')
        .doc(truckId)
        .collection('profile')
        .doc('profile')
        .delete();

    // Delete the truck document
    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('trucks')
        .doc(truckId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Truck Deleted')),
    );
  }
}
