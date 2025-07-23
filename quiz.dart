class Quiz {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      questions: (map['questions'] as List)
          .map((q) => Question.fromMap(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String type; // 'mcq' or 'tf'

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctIndex': correctIndex,
      'type': type,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as String,
      text: map['text'] as String,
      options: List<String>.from(map['options'] as List),
      correctIndex: map['correctIndex'] as int,
      type: map['type'] as String,
    );
  }
}
