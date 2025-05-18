import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz_model.dart';

class QuizDataLoader {
  static Future<List<Quiz>> loadQuizzes() async {
    final jsonString = await rootBundle.loadString('assets/quiz_data.json');
    final jsonData = json.decode(jsonString);
    return (jsonData['quizzes'] as List)
        .map((quiz) => Quiz.fromJson(quiz))
        .toList();
  }
}
