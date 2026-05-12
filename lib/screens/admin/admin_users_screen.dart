import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_user_edit_screen.dart';
import '../../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _searchQuery = '';

  Future<void> _revokeSubscription(String uid, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Revoke Subscription?', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
        content: Text('Are you sure you want to revoke the active plan for $name?', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Revoke', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('users').doc(uid).set({
        'subscription': {
          'plan': 'free',
        }
      }, SetOptions(merge: true));
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subscription revoked for $name'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _grantSubscription(String uid, String name) async {
    String selectedPlan = 'pro';
    int durationDays = 30;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Grant Subscription', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Grant a plan to $name?', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedPlan,
                isExpanded: true,
                dropdownColor: Theme.of(context).cardColor,
                items: const [
                  DropdownMenuItem(value: 'pro', child: Text('Pro Plan')),
                  DropdownMenuItem(value: 'advance', child: Text('Advance Plan')),
                ],
                onChanged: (v) => setState(() => selectedPlan = v!),
              ),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: durationDays,
                isExpanded: true,
                dropdownColor: Theme.of(context).cardColor,
                items: const [
                  DropdownMenuItem(value: 30, child: Text('1 Month')),
                  DropdownMenuItem(value: 90, child: Text('3 Months')),
                  DropdownMenuItem(value: 365, child: Text('1 Year')),
                  DropdownMenuItem(value: 3650, child: Text('10 Years (Lifetime)')),
                ],
                onChanged: (v) => setState(() => durationDays = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Grant Plan', style: TextStyle(color: Color(0xFFE5FF00)))),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    try {
      final now = DateTime.now();
      final expires = now.add(Duration(days: durationDays));
      await _firestore.collection('users').doc(uid).set({
        'subscription': {
          'plan': selectedPlan,
          'startedAt': now.toIso8601String(),
          'expiresAt': expires.toIso8601String(),
        }
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Granted $selectedPlan to $name'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteUserData(String uid, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Delete User Data?', style: TextStyle(color: Colors.redAccent)),
        content: Text('This will delete all database records for $name. They will have to set up their profile again. This cannot be undone. Are you sure?', 
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete Data', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('users').doc(uid).delete();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data deleted for $name'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).iconTheme.color,
        title: const Text('User Management', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Name or Email (Exact prefix match)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE5FF00)));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }

                final docs = snapshot.data?.docs ?? [];
                
                final filteredDocs = docs.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final data = doc.data() as Map<String, dynamic>?;
                  final name = (data?['name'] ?? '').toString().toLowerCase();
                  final email = (data?['email'] ?? '').toString().toLowerCase();
                  final q = _searchQuery.toLowerCase();
                  return name.contains(q) || email.contains(q);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(child: Text('No users found', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    final name = data['name'] ?? 'Unnamed User';
                    final email = data['email'] ?? 'No email';
                    final uid = doc.id;
                    
                    final subData = data['subscription'] as Map<String, dynamic>?;
                    final plan = subData?['plan'] ?? 'free';
                    final isActive = plan == 'pro' || plan == 'advance';
                    
                    String expireText = '';
                    if (isActive && subData?['expiresAt'] != null) {
                      final expString = subData!['expiresAt'].toString();
                      final exp = DateTime.tryParse(expString);
                      if (exp != null) {
                        expireText = ' (Ends ${DateFormat('MMM d, yyyy').format(exp)})';
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.06)),
                      ),
                      child: ExpansionTile(
                        shape: const RoundedRectangleBorder(),
                        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        subtitle: Text(email, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFFE5FF00).withOpacity(0.15) : Theme.of(context).dividerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            plan.toUpperCase(),
                            style: TextStyle(
                              color: isActive ? const Color(0xFFE5FF00) : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Text('UID: ', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 12)),
                                    Expanded(child: Text(uid, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 12))),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text('Plan: ', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 12)),
                                    Expanded(child: Text('$plan$expireText', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 12))),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        final userObj = UserModel.fromJson({'id': uid, ...data});
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (_) => AdminUserEditScreen(uid: uid, user: userObj),
                                        ));
                                      },
                                      icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
                                      tooltip: 'Edit Profile',
                                    ),
                                    if (isActive)
                                      IconButton(
                                        onPressed: () => _revokeSubscription(uid, name),
                                        icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                                        tooltip: 'Revoke Plan',
                                      )
                                    else
                                      IconButton(
                                        onPressed: () => _grantSubscription(uid, name),
                                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFFE5FF00)),
                                        tooltip: 'Grant Plan',
                                      ),
                                    IconButton(
                                      onPressed: () => _deleteUserData(uid, name),
                                      icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                                      tooltip: 'Delete Data',
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
