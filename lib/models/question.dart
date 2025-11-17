// lib/models/question.dart
import 'package:html_unescape/html_unescape.dart';

class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();
    final qText = unescape.convert(json['question'] as String);
    final correct = unescape.convert(json['correct_answer'] as String);
    final incorrect = (json['incorrect_answers'] as List<dynamic>)
        .map((e) => unescape.convert(e as String))
        .toList();

    final options = List<String>.from(incorrect)..add(correct);
    // options.shuffle(); // random order each run
    final bool shuffleOptions = false;
    if (shuffleOptions) options.shuffle();

    return Question(
      question: qText,
      options: options,
      correctAnswer: correct,
    );
  }
}
