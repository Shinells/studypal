import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference uploadsCollection = FirebaseFirestore.instance
      .collection('uploads');

  Future<String> uploadFile(File file, String fileType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    final ext = fileType == 'image' ? 'jpg' : 'pdf';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = _storage.ref().child('uploads/${user.uid}/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();
    // Save metadata to Firestore
    await uploadsCollection.add({
      'userId': user.uid,
      'url': url,
      'type': fileType,
      'fileName': fileName,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return url;
  }

  Stream<List<Map<String, dynamic>>> getUserUploads() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return uploadsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getUserUploadsWithRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return uploadsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['ref'] = doc.reference;
            return data;
          }).toList(),
        );
  }
}
