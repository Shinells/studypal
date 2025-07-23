import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz.dart';

class QuizService {
  final CollectionReference quizCollection = FirebaseFirestore.instance
      .collection('quizzes');

  Future<List<Quiz>> getQuizzes() async {
    final snapshot = await quizCollection.get();
    return snapshot.docs
        .map((doc) => Quiz.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addQuiz(Quiz quiz) async {
    await quizCollection.doc(quiz.id).set(quiz.toMap());
  }

  Future<Quiz?> getQuizById(String id) async {
    final doc = await quizCollection.doc(id).get();
    if (doc.exists) {
      return Quiz.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
