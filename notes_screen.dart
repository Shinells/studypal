import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
//import 'dart:math';

class NotesScreen extends StatefulWidget {
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final NotesService _notesService = NotesService();
  String _searchQuery = '';
  String? _selectedCategory;
  final List<String> _categories = [
    'All',
    'Personal',
    'School',
    'Work',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(child: Text('Not logged in'));
    }
    return Scaffold(
      appBar: AppBar(title: Text('My Notes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedCategory ?? 'All',
              isExpanded: true,
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: _notesService.getNotes(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No notes yet. Tap + to add one!'));
                }
                var notes = snapshot.data!;
                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  notes = notes
                      .where(
                        (note) =>
                            note.title.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            note.content.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ),
                      )
                      .toList();
                }
                // Filter by category
                if (_selectedCategory != null && _selectedCategory != 'All') {
                  notes = notes
                      .where((note) => note.category == _selectedCategory)
                      .toList();
                }
                if (notes.isEmpty) {
                  return Center(
                    child: Text('No notes match your search/filter.'),
                  );
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      color: note.color,
                      child: ListTile(
                        title: Text(note.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.content.length > 50
                                  ? note.content.substring(0, 50) + '...'
                                  : note.content,
                            ),
                            if (note.category != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Chip(label: Text(note.category!)),
                              ),
                            Text(
                              'Created: ${note.timestamp.toLocal().toString().split('.').first}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showAddEditDialog(
                                  context,
                                  user.uid,
                                  note: note,
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Note'),
                                    content: Text(
                                      'Are you sure you want to delete this note?',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                      ),
                                      ElevatedButton(
                                        child: Text('Delete'),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _notesService.deleteNote(note.id);
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          _showNoteDetailDialog(context, note);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, user.uid),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    String userId, {
    Note? note,
  }) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    String? selectedCategory = note?.category;
    Color selectedColor = note?.color ?? Colors.amber.shade100;
    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: 3,
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  hint: Text('Category'),
                  items: _categories
                      .where((c) => c != 'All')
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedCategory = val),
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: Colors.primaries.take(8).map((color) {
                    return GestureDetector(
                      onTap: () =>
                          setState(() => selectedColor = color.shade100),
                      child: CircleAvatar(
                        backgroundColor: color.shade100,
                        child: selectedColor == color.shade100
                            ? Icon(Icons.check, color: Colors.black)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () =>
                  Navigator.of(dialogContext, rootNavigator: true).pop(),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    contentController.text.isNotEmpty) {
                  Future<void> saveNote() async {
                    try {
                      final newNote = Note(
                        id:
                            note?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        content: contentController.text,
                        timestamp: note?.timestamp ?? DateTime.now(),
                        color: selectedColor,
                        category: selectedCategory,
                        userId: userId,
                      );
                      if (note == null) {
                        await _notesService.addNote(newNote);
                      } else {
                        await _notesService.updateNote(newNote);
                      }
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving note: $e')),
                      );
                    }
                  }

                  saveNote();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDetailDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(note.content),
              SizedBox(height: 12),
              if (note.category != null) Chip(label: Text(note.category!)),
              SizedBox(height: 8),
              Text(
                'Created: ${note.timestamp.toLocal().toString().split('.').first}',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
        ],
      ),
    );
  }
}
