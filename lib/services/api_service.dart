// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static const _baseUrl = 'https://opentdb.com/api.php';

  // amount, category id (9 = General Knowledge), difficulty, type can be passed
  static Future<List<Question>> fetchQuestions({
    int amount = 10,
    int? category,
    String? difficulty,
    String type = 'multiple',
  }) async {
    final params = <String, String>{
      'amount': amount.toString(),
      'type': type,
    };
    if (category != null) params['category'] = category.toString();
    if (difficulty != null) params['difficulty'] = difficulty;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      return results
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load questions: ${response.statusCode}');
    }
  }
}
