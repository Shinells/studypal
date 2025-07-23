import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final Color color;
  final String? category;
  final String userId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.color,
    this.category,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'color': color.value,
      'category': category,
      'userId': userId,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      color: Color(map['color'] as int),
      category: map['category'] as String?,
      userId: map['userId'] as String,
    );
  }
}
