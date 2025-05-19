import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/quiz_model.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  final Quiz quiz;
  final List<Color> gradientColors;

  const QuizPage({
    super.key,
    required this.quiz,
    required this.gradientColors,
    required Color themeColor,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<Question> questions;
  int currentIndex = 0;
  int score = 0;
  int? selectedIndex;
  int timeLeft = 10;
  Timer? timer;
  bool showCorrect = false;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    questions = List.from(widget.quiz.questions)..shuffle();
    startTimer();
    playTicking(0.6);
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  void playTicking(double rate) async {
    await player.stop();
    await player.setPlaybackRate(rate);
    await player.play(AssetSource('sounds/tick.mp3'), volume: 0.5);
  }

  void startTimer() {
    timeLeft = 10;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        timeLeft--;

        double rate;
        if (timeLeft >= 7) {
          rate = 0.6;
        } else if (timeLeft >= 4) {
          rate = 1.0;
        } else if (timeLeft >= 2) {
          rate = 1.3;
        } else {
          rate = 1.6;
        }

        playTicking(rate);

        if (timeLeft <= 0) {
          showCorrect = true;
          Future.delayed(const Duration(seconds: 2), nextQuestion);
          timer?.cancel();
        }
      });
    });
  }

  void nextQuestion() {
    timer?.cancel();
    if (selectedIndex != null &&
        selectedIndex == questions[currentIndex].correctIndex) {
      score++;
    }
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = null;
        showCorrect = false;
        startTimer();
        playTicking(0.6);
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResultPage(
                score: score,
                total: questions.length,
                quizTitle: widget.quiz.title,
                quiz: widget.quiz,
                userAnswers: [],
                correct: 1,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              widget.quiz.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                ' ${widget.quiz.title}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(221, 139, 12, 12),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    timeLeft <= 3 ? Colors.red.shade100 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Time left: $timeLeft s',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: timeLeft <= 3 ? Colors.red : Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (question.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(question.imageUrl!, height: 180),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final isCorrect = i == question.correctIndex;
                  final isSelected = i == selectedIndex;
                  Color color = Colors.white;

                  if (showCorrect) {
                    if (isCorrect) {
                      color = Colors.green.shade200;
                    } else if (isSelected && !isCorrect) {
                      color = Colors.red.shade200;
                    }
                  } else if (isSelected) {
                    color = Colors.blue.shade100;
                  }

                  return InkWell(
                    onTap:
                        showCorrect
                            ? null
                            : () {
                              setState(() {
                                selectedIndex = i;
                                showCorrect = true;
                                timer?.cancel();
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Future.microtask(() {
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    nextQuestion,
                                  );
                                });
                              });
                            },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        question.options[i],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
