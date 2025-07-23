import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  String _email = '';
  String _username = '';
  final String _profilePicAsset = 'assets/images/avatar.jpeg';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _email = _user?.email ?? '';
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    if (_user == null) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.username.isNotEmpty) {
      setState(() {
        _username = userProvider.username;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();
    final username = doc.data()?['username'] ?? '';
    setState(() {
      _username = username;
      _loading = false;
    });
    userProvider.setUsername(username);
  }

  Future<void> _editUsernameDialog() async {
    final controller = TextEditingController(text: _username);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Username'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter new username'),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Save'),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != _username) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'username': result});
      setState(() => _username = result);
      // Update provider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUsername(result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Username updated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile & Settings')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(_profilePicAsset),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) => Text(
                            userProvider.username.isNotEmpty
                                ? userProvider.username
                                : '',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, size: 20),
                          onPressed: _editUsernameDialog,
                          tooltip: 'Edit Username',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(_email, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 32),
                  Row(
                    children: [
                      Icon(Icons.brightness_6),
                      SizedBox(width: 8),
                      Text(
                        'Dark Mode',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) => Switch(
                          value: themeProvider.isDark,
                          onChanged: (val) => themeProvider.setDark(val),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
