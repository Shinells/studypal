import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';
import 'local_storage_service.dart';

class NotesService {
  final CollectionReference notesCollection = FirebaseFirestore.instance
      .collection('notes');
  final LocalStorageService _localStorage = LocalStorageService();

  Future<void> addNote(Note note) async {
    await notesCollection.doc(note.id).set(note.toMap());
    await _localStorage.addNote(note);
  }

  Future<void> updateNote(Note note) async {
    await notesCollection.doc(note.id).update(note.toMap());
    await _localStorage.updateNote(note);
  }

  Future<void> deleteNote(String id) async {
    await notesCollection.doc(id).delete();
    await _localStorage.deleteNote(id);
  }

  Stream<List<Note>> getNotes(String userId) async* {
    try {
      await for (var snapshot
          in notesCollection
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .snapshots()) {
        final notes = snapshot.docs
            .map((doc) => Note.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
        // Update local storage with latest notes
        for (var note in notes) {
          await _localStorage.addNote(note);
        }
        yield notes;
      }
    } catch (e) {
      // If Firestore fails (offline), use local storage
      final localNotes = await _localStorage.getNotes(userId);
      yield localNotes;
    }
  }
}
