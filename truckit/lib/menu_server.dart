import 'package:cloud_firestore/cloud_firestore.dart';

class MenuServer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createCompany(String companyName) async {
    DocumentReference companyRef = await _firestore.collection('companies').add({
      'name': companyName,
    });
    return companyRef.id;
  }

  Future<String> createTruck(String companyId, String truckName) async {
    DocumentReference truckRef = await _firestore.collection('companies').doc(companyId).collection('trucks').add({
      'name': truckName,
    });
    return truckRef.id;
  }

  Future<String> createMenu(String companyId, String truckId, String menuName) async {
    DocumentReference menuRef = await _firestore.collection('companies').doc(companyId).collection('trucks').doc(truckId).collection('menus').add({
      'name': menuName,
    });
    return menuRef.id;
  }

  Future<String> createSection(String companyId, String truckId, String menuId, String sectionName) async {
    DocumentReference sectionRef = await _firestore.collection('companies').doc(companyId).collection('trucks').doc(truckId).collection('menus').doc(menuId).collection('sections').add({
      'name': sectionName,
    });
    return sectionRef.id;
  }

  Future<void> updateSectionName(String companyId, String truckId, String menuId, String sectionId, String sectionName) async {
    await _firestore.collection('companies').doc(companyId).collection('trucks').doc(truckId).collection('menus').doc(menuId).collection('sections').doc(sectionId).update({
      'name': sectionName,
    });
  }

  Future<void> addMenuItem(String companyId, String truckId, String menuId, String sectionId, String itemName, double price, String description, String imageUrl) async {
    await _firestore.collection('companies').doc(companyId).collection('trucks').doc(truckId).collection('menus').doc(menuId).collection('sections').doc(sectionId).collection('items').add({
      'name': itemName,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
