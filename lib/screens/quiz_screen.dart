import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';
import 'score_screen.dart';

class QuizScreen extends StatefulWidget {
  final int category;
  final String difficulty;

  QuizScreen({required this.category, required this.difficulty});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _loading = true;

  bool _answered = false;
  String? _selectedAnswer;

  int _timeLeft = 15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final q = await ApiService.fetchQuestions(
        category: widget.category,
        difficulty: widget.difficulty,
      );

      setState(() {
        _questions = q;
        _loading = false;
      });

      _startTimer();
    } catch (e) {
      setState(() => _loading = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Failed to load questions"),
          content: Text("Check your internet and try again."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadQuestions();
              },
              child: Text("Retry"),
            )
          ],
        ),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 15;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
        setState(() => _answered = true);
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _submitAnswer(String option) {
    if (_answered) return;

    setState(() {
      _answered = true;
      _selectedAnswer = option;

      if (option == _questions[_currentIndex].correctAnswer) {
        _score++;
      }
    });

    _timer?.cancel(); // stop timer when answer chosen
  }

  void _nextQuestion() {
    if (_currentIndex + 1 == _questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScoreScreen(score: _score, total: _questions.length),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex++;
      _answered = false;
      _selectedAnswer = null;
    });

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _optionButton(String option) {
    final correct = _questions[_currentIndex].correctAnswer;

    Color? bgColor;

    if (_answered) {
      // highlight selection
      if (option == _selectedAnswer) {
        bgColor = option == correct ? Colors.green[300] : Colors.red[300];
      } else if (option == correct) {
        bgColor = Colors.green[200];
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: _answered ? null : () => _submitAnswer(option),
        child: Text(
          option,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Quiz App")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
            ),
            SizedBox(height: 10),

            Text("Time left: $_timeLeft seconds",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            Text(
              "Question ${_currentIndex + 1}/${_questions.length}",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 12),

            Text(q.question, style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),

            ...q.options.map(_optionButton),

            SizedBox(height: 20),

            if (_answered)
              Column(
                children: [
                  Text(
                    _selectedAnswer == q.correctAnswer
                        ? "Correct! 🎉"
                        : "Incorrect ❌\nCorrect Answer: ${q.correctAnswer}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: _nextQuestion, child: Text("Next")),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
