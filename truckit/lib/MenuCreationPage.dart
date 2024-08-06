import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_server.dart';

class MenuCreationPage extends StatefulWidget {
  final String companyId;
  final String truckId;

  MenuCreationPage({required this.companyId, required this.truckId});

  @override
  _MenuCreationPageState createState() => _MenuCreationPageState();
}

class _MenuCreationPageState extends State<MenuCreationPage> {
  final MenuServer _menuServer = MenuServer();
  final List<SectionWidget> _sections = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var sectionsSnapshot = await _menuServer.getSections(widget.companyId, widget.truckId);
    for (var sectionDoc in sectionsSnapshot.docs) {
      var section = SectionWidget(
        companyId: widget.companyId,
        truckId: widget.truckId,
        menuServer: _menuServer,
        sectionId: sectionDoc.id,
        initialName: sectionDoc['name'],
        onDelete: () => _removeSection(sectionDoc.id),
      );
      setState(() {
        _sections.add(section);
      });
      var itemsSnapshot = await _menuServer.getMenuItems(widget.companyId, widget.truckId, sectionDoc.id);
      for (var itemDoc in itemsSnapshot.docs) {
        section.addItem(
          initialName: itemDoc['name'],
          initialPrice: itemDoc['price'],
          initialDescription: itemDoc['description'],
          itemId: itemDoc.id,
        );
      }
    }
  }

  void _addSection() async {
    String newSectionId = await _menuServer.createSection(widget.companyId, widget.truckId, 'New Section');
    setState(() {
      _sections.add(SectionWidget(
        companyId: widget.companyId,
        truckId: widget.truckId,
        menuServer: _menuServer,
        sectionId: newSectionId,
        // initialName: 'New Section',
        onDelete: () => _removeSection(newSectionId),
      ));
    });
  }

  void _removeSection(String sectionId) {
    setState(() {
      _sections.removeWhere((section) => section.sectionId == sectionId);
    });
    if (sectionId.isNotEmpty) {
      _menuServer.deleteSection(widget.companyId, widget.truckId, sectionId);
    }
  }

  void _saveMenu() async {
    for (var section in _sections) {
      await section.saveSection();
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Menu Saved'),
        content: Text('Your menu has been saved successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Menu', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1C1C1E),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF1C1C1E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ..._sections,
            SizedBox(height: 16.0),
            if (_sections.isEmpty)
              Center(
                child: ElevatedButton(
                  onPressed: _addSection,
                  child: Text('Add Section'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: _addSection,
                child: Text('Add Section'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(55.0),
        child: ElevatedButton(
          onPressed: _saveMenu,
          child: Text('Save Menu', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C1C1E), // Button color same as background
            side: BorderSide(color: Colors.white, width: 1.0), // Thin white border
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), // More rounded corners
            ),
          ),
        ),
      ),
    );
  }
}

class SectionWidget extends StatefulWidget {
  final String companyId;
  final String truckId;
  final MenuServer menuServer;
  final String sectionId;
  final String? initialName;
  final VoidCallback onDelete;

  SectionWidget({
    required this.companyId,
    required this.truckId,
    required this.menuServer,
    required this.sectionId,
    required this.onDelete,
    this.initialName,
  });

  final _SectionWidgetState _sectionState = _SectionWidgetState();

  Future<void> saveSection() => _sectionState.saveSection();

  void addItem({
    String? initialName,
    double? initialPrice,
    String? initialDescription,
    String? itemId,
  }) {
    _sectionState.addItem(
      initialName: initialName,
      initialPrice: initialPrice,
      initialDescription: initialDescription,
      itemId: itemId,
    );
  }

  @override
  _SectionWidgetState createState() => _sectionState;
}

class _SectionWidgetState extends State<SectionWidget> {
  final TextEditingController _sectionNameController = TextEditingController();
  final List<MenuItemWidget> _menuItems = [];
  late String sectionId;

  @override
  void initState() {
    super.initState();
    _sectionNameController.text = widget.initialName ?? '';
    sectionId = widget.sectionId;
  }

  void addItem({
    String? initialName,
    double? initialPrice,
    String? initialDescription,
    String? itemId,
  }) {
    setState(() {
      _menuItems.add(MenuItemWidget(
        companyId: widget.companyId,
        truckId: widget.truckId,
        sectionId: sectionId,
        menuServer: widget.menuServer,
        onDelete: () => _removeMenuItem(_menuItems.length - 1),
        initialName: initialName,
        initialPrice: initialPrice,
        initialDescription: initialDescription,
        itemId: itemId,
      ));
    });
  }

  void _removeMenuItem(int index) {
    setState(() {
      _menuItems.removeAt(index);
    });
  }

  Future<void> saveSection() async {
    await widget.menuServer.updateSectionName(widget.companyId, widget.truckId, sectionId, _sectionNameController.text);
    for (var item in _menuItems) {
      await item.saveMenuItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Color(0xFF2C2C2E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sectionNameController,
                    decoration: const InputDecoration(
                      labelText: 'Section Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            ..._menuItems,
            SizedBox(height: 8.0),
            Center(
              child: ElevatedButton(
                onPressed: addItem,
                child: Text('Add Menu Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItemWidget extends StatefulWidget {
  final String companyId;
  final String truckId;
  final String sectionId;
  final MenuServer menuServer;
  final VoidCallback onDelete;
  final String? initialName;
  final double? initialPrice;
  final String? initialDescription;
  final String? itemId;

  MenuItemWidget({
    required this.companyId,
    required this.truckId,
    required this.sectionId,
    required this.menuServer,
    required this.onDelete,
    this.initialName,
    this.initialPrice,
    this.initialDescription,
    this.itemId,
  });

  final _MenuItemWidgetState _itemState = _MenuItemWidgetState();

  Future<void> saveMenuItem() => _itemState.saveMenuItem();

  @override
  _MenuItemWidgetState createState() => _itemState;
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _priceController.text = widget.initialPrice?.toStringAsFixed(2) ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
  }

  Future<void> saveMenuItem() async {
    if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      if (!_priceController.text.contains('.')) {
        _priceController.text = '${_priceController.text}.00';
      } else if (_priceController.text.split('.')[1].length == 1) {
        _priceController.text = '${_priceController.text}0';
      }
      if (widget.itemId == null) {
        await widget.menuServer.addMenuItem(
          widget.companyId,
          widget.truckId,
          widget.sectionId,
          _nameController.text,
          double.parse(_priceController.text),
          _descriptionController.text,
          _imageUrl,
        );
      } else {
        await widget.menuServer.updateMenuItem(
          widget.companyId,
          widget.truckId,
          widget.sectionId,
          widget.itemId!,
          _nameController.text,
          double.parse(_priceController.text),
          _descriptionController.text,
          _imageUrl,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Color(0xFF2C2C2E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.text,
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
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
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
          ],
        ),
      ),
    );
  }
}
