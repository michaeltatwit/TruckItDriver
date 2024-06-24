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
    // Fetch existing sections and items from Firestore
    var sectionsSnapshot = await _menuServer.getSections(widget.companyId, widget.truckId);
    for (var sectionDoc in sectionsSnapshot.docs) {
      var section = SectionWidget(
        companyId: widget.companyId,
        truckId: widget.truckId,
        menuServer: _menuServer,
        sectionId: sectionDoc.id,
        initialName: sectionDoc['name'],
        onDelete: () => _removeSection(int.parse(sectionDoc.id)),

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

  void _addSection() {
    setState(() {
      _sections.add(SectionWidget(
        companyId: widget.companyId,
        truckId: widget.truckId,
        menuServer: _menuServer,
        onDelete: () => _removeSection(_sections.length - 1),
      ));
    });
  }

  void _removeSection(int index) {
    setState(() {
      _sections.removeAt(index);
    });
  }

  void _saveMenu() async {
    for (var section in _sections) {
      await section.saveSection();
    }
    // Show a confirmation dialog or navigate to another screen
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
        title: Text('Create Menu'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveMenu,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ..._sections,
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addSection,
              child: Text('Add Section'),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionWidget extends StatefulWidget {
  final String companyId;
  final String truckId;
  final MenuServer menuServer;
  final String? sectionId;
  final String? initialName;
  final VoidCallback onDelete;

  SectionWidget({
    required this.companyId,
    required this.truckId,
    required this.menuServer,
    required this.onDelete,
    this.sectionId,
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
  String sectionId = '';

  @override
  void initState() {
    super.initState();
    _sectionNameController.text = widget.initialName ?? '';
    if (widget.sectionId != null) {
      sectionId = widget.sectionId!;
    } else {
      _initializeSection();
    }
  }

  void _initializeSection() async {
    sectionId = await widget.menuServer.createSection(widget.companyId, widget.truckId, 'New Section');
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
    // Save the section name
    await widget.menuServer.updateSectionName(widget.companyId, widget.truckId, sectionId, _sectionNameController.text);
    // Save all menu items in this section
    for (var item in _menuItems) {
      await item.saveMenuItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                    decoration: InputDecoration(labelText: 'Section Name'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
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
    _priceController.text = widget.initialPrice?.toString() ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
  }

  Future<void> saveMenuItem() async {
    if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
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
                    decoration: InputDecoration(labelText: 'Item Name'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
      ),
    );
  }
}
