// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _questions = [];
    });

    try {
      final questions = await ApiService.fetchQuestions(
        amount: 10,
        category: 9,
        difficulty: 'easy',
        type: 'multiple',
      );

      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);

      // Show retry UI
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Failed to load questions"),
          content: Text("Please check your internet or try again."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadQuestions(); // try again
              },
              child: Text("Retry"),
            )
          ],
        ),
      );
    }
  }


  void _submit(String option) {
    if (_answered) return;
    setState(() {
      _selected = option;
      _answered = true;
      if (option == _questions[_currentIndex].correctAnswer) {
        _score++;
      }
    });
  }

  void _next() {
    if (_currentIndex + 1 >= _questions.length) {
      // finished
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScoreScreen(score: _score, total: _questions.length),
        ),
      );
      return;
    }
    setState(() {
      _currentIndex++;
      _answered = false;
      _selected = null;
    });
  }

  Widget _optionButton(String option) {
    final isCorrect = option == _questions[_currentIndex].correctAnswer;
    Color? bg;
    if (_answered) {
      if (_selected == option) {
        bg = isCorrect ? Colors.green[300] : Colors.red[300];
      } else if (isCorrect) {
        // show correct answer even if not selected
        bg = Colors.green[200];
      } else {
        bg = null;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          padding: EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: _answered ? null : () => _submit(option),
        child: Text(option, textAlign: TextAlign.center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: Center(child: Text('No questions available.')),
      );
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Question ${_currentIndex + 1}/${_questions.length}',
                style: TextStyle(fontSize: 20)),
            SizedBox(height: 12),
            Text(q.question, style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),
            ...q.options.map(_optionButton).toList(),
            Spacer(),
            if (_answered)
              Column(children: [
                Text(
                  _selected == q.correctAnswer
                      ? 'Correct! ✅'
                      : 'Incorrect — correct: ${q.correctAnswer}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                ElevatedButton(onPressed: _next, child: Text('Next')),
              ]),
            if (!_answered)
              Text('Select an answer to see feedback'),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class ScoreScreen extends StatelessWidget {
  final int score;
  final int total;
  const ScoreScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Score')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quiz Finished!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('Your Score: $score / $total', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // pop to start
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              child: Text('Back to Start'),
            ),
          ],
        ),
      ),
    );
  }
}
