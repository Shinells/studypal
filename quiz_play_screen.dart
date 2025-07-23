import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizPlayScreen extends StatefulWidget {
  final Quiz quiz;
  const QuizPlayScreen({required this.quiz});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentIndex = 0;
  late List<int?> _userAnswers; // null = unanswered
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _userAnswers = List<int?>.filled(widget.quiz.questions.length, null);
  }

  void _next() {
    if (_currentIndex < widget.quiz.questions.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _submit() {
    setState(() => _submitted = true);
  }

  void _retake() {
    setState(() {
      _userAnswers = List<int?>.filled(widget.quiz.questions.length, null);
      _currentIndex = 0;
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      int score = 0;
      for (int i = 0; i < widget.quiz.questions.length; i++) {
        if (_userAnswers[i] == widget.quiz.questions[i].correctIndex) {
          score++;
        }
      }
      double percent = (score / widget.quiz.questions.length) * 100;
      String message = percent == 100
          ? 'Excellent!'
          : percent >= 70
          ? 'Great job!'
          : percent >= 50
          ? 'Keep practicing!'
          : 'Try again!';
      return Scaffold(
        appBar: AppBar(title: Text('Quiz Results')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$score / ${widget.quiz.questions.length}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 8),
                    Chip(
                      label: Text(
                        message,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.quiz.questions.length,
                  itemBuilder: (context, i) {
                    final q = widget.quiz.questions[i];
                    final userAns = _userAnswers[i];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q${i + 1}: ${q.text}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6),
                            ...List.generate(q.options.length, (optIdx) {
                              final isCorrect = optIdx == q.correctIndex;
                              final isUser = userAns == optIdx;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCorrect
                                          ? Icons.check_circle
                                          : isUser
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: isCorrect
                                          ? Colors.green
                                          : isUser
                                          ? Colors.blue
                                          : Colors.grey,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(q.options[optIdx]),
                                    if (isUser && !isCorrect)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 4.0,
                                        ),
                                        child: Chip(
                                          label: Text('Your answer'),
                                          backgroundColor: Colors.blue[100],
                                        ),
                                      ),
                                    if (isCorrect)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 4.0,
                                        ),
                                        child: Chip(
                                          label: Text('Correct'),
                                          backgroundColor: Colors.green[100],
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _retake,
                    child: Text('Retake Quiz'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Back to List'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final q = widget.quiz.questions[_currentIndex];
    final userAns = _userAnswers[_currentIndex];
    double progress = (_currentIndex + 1) / widget.quiz.questions.length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.quiz.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Theme.of(context).colorScheme.primary,
              minHeight: 8,
            ),
            SizedBox(height: 16),
            Text(
              'Question ${_currentIndex + 1} of ${widget.quiz.questions.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.text,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 18),
                    ...List.generate(q.options.length, (optIdx) {
                      final isSelected = userAns == optIdx;
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.15)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RadioListTile<int>(
                          value: optIdx,
                          groupValue: userAns,
                          onChanged: (val) {
                            setState(() => _userAnswers[_currentIndex] = val);
                          },
                          title: Text(q.options[optIdx]),
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  OutlinedButton(onPressed: _prev, child: Text('Previous')),
                if (_currentIndex < widget.quiz.questions.length - 1)
                  ElevatedButton(
                    onPressed: userAns != null ? _next : null,
                    child: Text('Next'),
                  ),
                if (_currentIndex == widget.quiz.questions.length - 1)
                  ElevatedButton(
                    onPressed: userAns != null ? _submit : null,
                    child: Text('Submit'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
