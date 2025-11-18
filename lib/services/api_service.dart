import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static const _baseUrl = 'https://opentdb.com/api.php';

  static Future<List<Question>> fetchQuestions({
    int amount = 10,
    required int category,
    required String difficulty,
    String type = "multiple",
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      "amount": amount.toString(),
      "category": category.toString(),
      "difficulty": difficulty,
      "type": type,
    });

    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final results = data['results'] as List;
      return results.map((e) => Question.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load questions");
    }
  }
}
