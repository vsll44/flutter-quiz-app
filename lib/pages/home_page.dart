import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../services/quiz_data_loader.dart';
import 'quiz_page.dart'; // Участник 2 сделает эту страницу

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz App')),
      body: FutureBuilder<List<Quiz>>(
        future: QuizDataLoader.loadQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final quizzes = snapshot.data!;
            return ListView.builder(
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(quiz.title),
                    subtitle: Text(quiz.description),
                    trailing: ElevatedButton(
                      child: const Text('Start'),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/quiz',
                          arguments: quiz,
                        );
                      },
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading quizzes'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
