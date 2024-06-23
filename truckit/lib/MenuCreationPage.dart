import 'package:flutter/material.dart';
import 'menu_server.dart';

class MenuCreationPage extends StatefulWidget {
  @override
  _MenuCreationPageState createState() => _MenuCreationPageState();
}

class _MenuCreationPageState extends State<MenuCreationPage> {
  final MenuServer _menuServer = MenuServer();
  final List<SectionWidget> _sections = [];

  String companyId = '';
  String truckId = '';
  String menuId = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    companyId = await _menuServer.createCompany('Your Company');
    truckId = await _menuServer.createTruck(companyId, 'Your Truck');
    menuId = await _menuServer.createMenu(companyId, truckId, 'Your Menu');
    _addSection();  // Start with one section
  }

  void _addSection() {
    setState(() {
      _sections.add(SectionWidget(
        companyId: companyId,
        truckId: truckId,
        menuId: menuId,
        menuServer: _menuServer,
      ));
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
              Navigator.of(context).pop(); // Navigate back to the previous screen
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
  final String menuId;
  final MenuServer menuServer;

  SectionWidget({
    required this.companyId,
    required this.truckId,
    required this.menuId,
    required this.menuServer,
  });

  final _SectionWidgetState _sectionState = _SectionWidgetState();

  Future<void> saveSection() => _sectionState.saveSection();

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
    _initializeSection();
  }

  void _initializeSection() async {
    sectionId = await widget.menuServer.createSection(widget.companyId, widget.truckId, widget.menuId, 'New Section');
  }

  void _addMenuItem() {
    setState(() {
      _menuItems.add(MenuItemWidget(
        companyId: widget.companyId,
        truckId: widget.truckId,
        menuId: widget.menuId,
        sectionId: sectionId,
        menuServer: widget.menuServer,
      ));
    });
  }

  Future<void> saveSection() async {
    // Save the section name
    await widget.menuServer.updateSectionName(widget.companyId, widget.truckId, widget.menuId, sectionId, _sectionNameController.text);
    // Save all menu items in this section
    for (var item in _menuItems) {
      await item.saveMenuItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _sectionNameController,
          decoration: InputDecoration(labelText: 'Section Name'),
        ),
        SizedBox(height: 16.0),
        ..._menuItems,
        ElevatedButton(
          onPressed: _addMenuItem,
          child: Text('Add Menu Item'),
        ),
      ],
    );
  }
}

class MenuItemWidget extends StatefulWidget {
  final String companyId;
  final String truckId;
  final String menuId;
  final String sectionId;
  final MenuServer menuServer;

  MenuItemWidget({
    required this.companyId,
    required this.truckId,
    required this.menuId,
    required this.sectionId,
    required this.menuServer,
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

  Future<void> saveMenuItem() async {
    if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      await widget.menuServer.addMenuItem(
        widget.companyId,
        widget.truckId,
        widget.menuId,
        widget.sectionId,
        _nameController.text,
        double.parse(_priceController.text),
        _descriptionController.text,
        _imageUrl,
      );
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() {
        _imageUrl = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Item Name'),
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
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: saveMenuItem,
          child: Text('Save Menu Item'),
        ),
      ],
    );
  }
}
