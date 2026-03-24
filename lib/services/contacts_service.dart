import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

/// Persists emergency contacts locally via SharedPreferences.
/// Contacts are stored per-user using their userId as the key.
class ContactsService {
  static const _prefix = 'emergency_contacts_';

  String _key(String userId) => '$_prefix$userId';

  Future<List<EmergencyContact>> getContacts(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveContacts(
      String userId, List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(userId),
      jsonEncode(contacts.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> addContact(String userId, EmergencyContact contact) async {
    final contacts = await getContacts(userId);
    contacts.add(contact);
    await saveContacts(userId, contacts);
  }

  Future<void> updateContact(String userId, EmergencyContact updated) async {
    final contacts = await getContacts(userId);
    final idx = contacts.indexWhere((c) => c.id == updated.id);
    if (idx != -1) contacts[idx] = updated;
    await saveContacts(userId, contacts);
  }

  Future<void> deleteContact(String userId, String contactId) async {
    final contacts = await getContacts(userId);
    contacts.removeWhere((c) => c.id == contactId);
    await saveContacts(userId, contacts);
  }
}
