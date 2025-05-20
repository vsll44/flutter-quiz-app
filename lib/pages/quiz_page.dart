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
  int totalTime = 60;
  Timer? timer;
  bool showCorrect = false;
  List<int?> userAnswers = [];
  final player = AudioPlayer();
  bool showRed = false;

  @override
  void initState() {
    super.initState();
    questions = List.from(widget.quiz.questions)..shuffle();
    userAnswers = List.filled(questions.length, null);
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        totalTime--;
        showRed = totalTime <= 10 ? !showRed : false;
        if (totalTime <= 0) {
          goToResult();
        }
      });
    });
  }

  void selectAnswer(int index) {
    if (showCorrect) return;
    setState(() {
      selectedIndex = index;
      userAnswers[currentIndex] = index;
      showCorrect = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (userAnswers.every((e) => e != null)) {
        goToResult();
      } else if (currentIndex < questions.length - 1) {
        nextQuestion();
      }
    });
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = userAnswers[currentIndex];
        showCorrect = selectedIndex != null;
      });
    }
  }

  void previousQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        selectedIndex = userAnswers[currentIndex];
        showCorrect = selectedIndex != null;
      });
    }
  }

  void goToResult() {
    timer?.cancel();
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctIndex) {
        correct++;
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(
          score: correct,
          total: questions.length,
          quizTitle: widget.quiz.title,
          quiz: widget.quiz,
          userAnswers: userAnswers,
          correct: correct,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the quiz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _confirmFinish() async {
    final shouldFinish = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Finish Quiz'),
            content: const Text('Are you sure you want to finish the quiz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldFinish) {
      goToResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          leading: BackButton(color: Colors.white),
          title: Text(widget.quiz.title),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.flag),
              tooltip: 'Finish Quiz',
              onPressed: _confirmFinish,
              color: const Color.fromARGB(255, 248, 247, 248),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer,
                        color: showRed ? Colors.red : Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(
                      'Time left: $totalTime s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: showRed ? Colors.red : Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (question.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              Image.network(question.imageUrl!, height: 180),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
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
                      onTap: () => selectAnswer(i),
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
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: currentIndex > 0 ? previousQuestion : null,
                    child: const Text('Previous'),
                  ),
                  ElevatedButton(
                    onPressed: currentIndex < questions.length - 1
                        ? nextQuestion
                        : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: List.generate(
                  questions.length,
                  (index) {
                    Color buttonColor;
                    if (userAnswers[index] == null) {
                      buttonColor = Colors.grey.shade200;
                    } else if (userAnswers[index] ==
                        questions[index].correctIndex) {
                      buttonColor = Colors.green.shade200;
                    } else {
                      buttonColor = Colors.red.shade200;
                    }

                    if (index == currentIndex) {
                      buttonColor = Colors.deepPurple;
                    }

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          currentIndex = index;
                          selectedIndex = userAnswers[currentIndex];
                          showCorrect = selectedIndex != null;
                        });
                      },
                      child: Text('${index + 1}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
