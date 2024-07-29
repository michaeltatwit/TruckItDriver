import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_server.dart';

class ProfileCreationPage extends StatefulWidget {
  final String companyId;
  final String truckId;

  ProfileCreationPage({required this.companyId, required this.truckId});

  @override
  _ProfileCreationPageState createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  String _imageUrl = '';
  bool _isProfileExists = false;
  bool _isLoading = false;
  final MenuServer _menuServer = MenuServer();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      DocumentSnapshot profile = await _menuServer.getProfile(widget.companyId, widget.truckId);
      if (profile.exists) {
        setState(() {
          _isProfileExists = true;
          _descriptionController.text = profile['description'];
          _imageUrl = profile['imageUrl'];
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      String fileName = '${widget.companyId}_${widget.truckId}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child('truck_profiles').child(fileName);
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return; // Prevent multiple submissions
    setState(() {
      _isLoading = true;
    });

    String imageUrl = _imageUrl;

    if (_image != null) {
      try {
        imageUrl = await _uploadImage(_image!);
      } catch (e) {
        print("Error uploading image: $e");
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      await _menuServer.createOrUpdateProfile(
        widget.companyId,
        widget.truckId,
        _descriptionController.text,
        imageUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile Saved')),
      );

      setState(() {
        _imageUrl = imageUrl;
        _isLoading = false;
      });

      Navigator.pop(context, _imageUrl); // Return the new imageUrl to the Homepage
    } catch (e) {
      print("Error saving profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isProfileExists ? 'Edit Profile' : 'Create Profile',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : _imageUrl.isNotEmpty
                        ? NetworkImage(_imageUrl)
                        : null,
                child: _image == null && _imageUrl.isEmpty ? Icon(Icons.add_a_photo) : null,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white), // Set user input text color to white
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading ? CircularProgressIndicator() : Text('Save Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // Button color
                foregroundColor: Colors.blue, // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
