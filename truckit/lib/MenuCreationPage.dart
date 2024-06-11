import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MenuCreationPage extends StatefulWidget {
  @override
  _MenuCreationPageState createState() => _MenuCreationPageState();
}

class _MenuCreationPageState extends State<MenuCreationPage> {
  final List<MenuSection> _sections = [];

  void _addSection() {
    setState(() {
      _sections.add(MenuSection());
    });
  }

  void _saveMenu() {
    // Save menu logic
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Menu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _addSection,
              child: Text('Add Section'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _sections.length,
                itemBuilder: (context, index) {
                  return _sections[index];
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveMenu,
              child: Text('Save Menu'),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuSection extends StatefulWidget {
  @override
  _MenuSectionState createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  final TextEditingController _sectionNameController = TextEditingController();
  final List<MenuItem> _items = [];

  void _addItem() {
    setState(() {
      _items.add(MenuItem());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _sectionNameController,
              decoration: InputDecoration(labelText: 'Section Name'),
            ),
            ElevatedButton(
              onPressed: _addItem,
              child: Text('Add Item'),
            ),
            Column(
              children: _items,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatefulWidget {
  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  final TextEditingController _itemNameController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _itemNameController,
          decoration: InputDecoration(labelText: 'Item Name'),
        ),
        GestureDetector(
          onTap: _pickImage,
          child: _image != null
              ? Image.file(_image!, height: 100)
              : Container(
                  height: 100,
                  color: Colors.grey[300],
                  child: Icon(Icons.add_a_photo),
                ),
        ),
      ],
    );
  }
}
