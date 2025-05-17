import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/quiz_page.dart'; // для перехода — напишет участник 2

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/quiz': (context) => const Placeholder(), // временно — заменит участник 2
      },
    );
  }
}
