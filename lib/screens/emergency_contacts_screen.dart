import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emergency_contact.dart';
import '../providers/auth_provider.dart';
import '../services/contacts_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final _contactsService = ContactsService();
  List<EmergencyContact> _contacts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = _userId();
    if (userId == null) return;
    final contacts = await _contactsService.getContacts(userId);
    if (mounted) setState(() { _contacts = contacts; _loading = false; });
  }

  String? _userId() =>
      Provider.of<AuthProvider>(context, listen: false).currentUser?.id;

  Future<void> _showAddEditDialog({EmergencyContact? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Contact' : 'Edit Contact'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '+91XXXXXXXXXX',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter a phone number';
                  if (v.trim().length < 7) return 'Enter a valid number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final userId = _userId();
    if (userId == null) return;

    if (existing == null) {
      final contact = EmergencyContact(
        id: 'contact_${DateTime.now().millisecondsSinceEpoch}',
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
      );
      await _contactsService.addContact(userId, contact);
    } else {
      await _contactsService.updateContact(
        userId,
        EmergencyContact(
          id: existing.id,
          name: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
        ),
      );
    }
    _load();
  }

  Future<void> _delete(EmergencyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove contact?'),
        content: Text('${contact.name} will no longer receive SOS alerts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final userId = _userId();
    if (userId == null) return;
    await _contactsService.deleteContact(userId, contact.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add contact',
            onPressed: _showAddEditDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info banner
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.red.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'These contacts will receive an SMS alert with your location when you trigger SOS.',
                          style: TextStyle(
                              fontSize: 13, color: Colors.red.shade800),
                        ),
                      ),
                    ],
                  ),
                ),

                // Police number (always included, read-only)
                _ContactTile(
                  name: 'Police (default)',
                  phone: '+919328103613',
                  isDefault: true,
                ),

                // User contacts
                if (_contacts.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.contacts,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No contacts added yet',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Contact'),
                            onPressed: _showAddEditDialog,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (ctx, i) {
                        final c = _contacts[i];
                        return _ContactTile(
                          name: c.name,
                          phone: c.phone,
                          onEdit: () => _showAddEditDialog(existing: c),
                          onDelete: () => _delete(c),
                        );
                      },
                    ),
                  ),
              ],
            ),
      floatingActionButton: _contacts.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddEditDialog,
              child: const Icon(Icons.person_add),
            )
          : null,
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String name;
  final String phone;
  final bool isDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ContactTile({
    required this.name,
    required this.phone,
    this.isDefault = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isDefault ? Colors.red.shade100 : Colors.blue.shade100,
        child: Icon(
          isDefault ? Icons.local_police : Icons.person,
          color: isDefault ? Colors.red.shade700 : Colors.blue.shade700,
        ),
      ),
      title: Text(name,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(phone),
      trailing: isDefault
          ? Chip(
              label: const Text('Always included'),
              labelStyle:
                  TextStyle(fontSize: 11, color: Colors.red.shade700),
              backgroundColor: Colors.red.shade50,
              side: BorderSide(color: Colors.red.shade200),
              padding: EdgeInsets.zero,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Remove',
                ),
              ],
            ),
    );
  }
}
