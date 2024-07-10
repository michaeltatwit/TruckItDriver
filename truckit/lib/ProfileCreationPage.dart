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
  final MenuServer _menuServer = MenuServer();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    DocumentSnapshot profile = await _menuServer.getProfile(widget.companyId, widget.truckId);
    if (profile.exists) {
      setState(() {
        _isProfileExists = true;
        _descriptionController.text = profile['description'];
        _imageUrl = profile['imageUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String> _uploadImage(File image) async {
    String fileName = '${widget.companyId}_${widget.truckId}.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child('truck_profiles').child(fileName);
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    String imageUrl = _imageUrl;

    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
    }

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isProfileExists ? 'Edit Profile' : 'Create Profile')),
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
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
