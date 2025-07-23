import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notes_service.dart';
import '../services/quiz_service.dart';
import '../services/upload_service.dart';
import 'notes_screen.dart';
import 'quiz_screen.dart';
import 'upload_screen.dart';
import 'profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  // Tab order: Dashboard, Notes, Quiz, Upload, Profile
  final List<Widget> tabs = [
    // Dashboard summary (will be built in build method)
    Container(), // Placeholder for dashboard, replaced in build
    NotesScreen(),
    QuizScreen(),
    UploadScreen(),
    ProfileScreen(),
  ];

  // Dashboard summary data
  int _notesCount = 0;
  int _quizzesCount = 0;
  String _quote = '';
  String _quoteAuthor = '';
  List<Map<String, dynamic>> _recentUploads = [];
  bool _loading = true;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Fetch notes count
    final notes = await NotesService().getNotes(user.uid).first;
    // Fetch quizzes count
    final quizzes = await QuizService().getQuizzes();
    // Fetch recent uploads
    final uploads = await UploadService().getUserUploads().first;
    // Fetch motivational quote
    String quote = '';
    String author = '';
    String username = '';
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      username = userDoc.data()?['username'] ?? '';
    } catch (_) {}
    try {
      final response = await http.get(
        Uri.parse('https://zenquotes.io/api/today'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        quote = data[0]['q'] ?? '';
        author = data[0]['a'] ?? '';
      }
    } catch (_) {}
    setState(() {
      _notesCount = notes.length;
      _quizzesCount = quizzes.length;
      _recentUploads = uploads.take(4).toList();
      _quote = quote;
      _quoteAuthor = author;
      _username = username;
      _loading = false;
    });
  }

  Widget _buildDashboardSummary(BuildContext context) {
    return _loading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchDashboardData,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                if (_username.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, _) => Text(
                        userProvider.username.isNotEmpty
                            ? 'Welcome, ${userProvider.username}!'
                            : '',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                // Notes summary card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(
                      Icons.note,
                      color: Theme.of(context).colorScheme.primary,
                      size: 36,
                    ),
                    title: Text(
                      'My Notes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Total notes: $_notesCount'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ),
                SizedBox(height: 16),
                // Quiz summary card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(
                      Icons.quiz,
                      color: Colors.deepPurple,
                      size: 36,
                    ),
                    title: Text(
                      'Quizzes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Available quizzes: $_quizzesCount'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                ),
                SizedBox(height: 16),
                // Motivational quote card (only on dashboard)
                Card(
                  color: Colors.amber[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.format_quote,
                              color: Colors.amber[800],
                              size: 32,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Today’s Motivation',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          _quote,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '- $_quoteAuthor',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Recent uploads card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              color: Colors.blue,
                              size: 32,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Recent Uploads',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _recentUploads.isEmpty
                            ? Text('No uploads yet.')
                            : Row(
                                children: _recentUploads.map((upload) {
                                  if (upload['type'] == 'image') {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          upload['url'],
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  } else if (upload['type'] == 'pdf') {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                        size: 48,
                                      ),
                                    );
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Quick actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.note_add),
                      label: Text('Add Note'),
                      onPressed: () => setState(() => _currentIndex = 1),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.quiz),
                      label: Text('Take Quiz'),
                      onPressed: () => setState(() => _currentIndex = 2),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.upload_file),
                      label: Text('Upload'),
                      onPressed: () => setState(() => _currentIndex = 3),
                    ),
                  ],
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0 ? AppBar(title: Text('Dashboard')) : null,
      body: _currentIndex == 0
          ? _buildDashboardSummary(context)
          : tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (val) => setState(() => _currentIndex = val),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: "Notes"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quiz"),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Upload"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
