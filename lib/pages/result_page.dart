import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/quiz_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'home_page.dart';

class ResultPage extends StatefulWidget {
  final Quiz quiz;
  final List<int?> userAnswers;
  final dynamic total;
  final dynamic score;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.quiz,
    required this.userAnswers,
    required String quizTitle,
    required int correct,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (widget.score / widget.total * 100).round();
    String message;
    String emoji;

    if (percent >= 80) {
      message = "Excellent!";
      emoji = "🎉";
    } else if (percent >= 50) {
      message = "Good Job!";
      emoji = "👍";
    } else {
      message = "Try Again!";
      emoji = "😢";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Results'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0E0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 20),

                    
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      shadowColor: Colors.deepPurple.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              '${widget.score} / ${widget.total} Correct',
                              style: GoogleFonts.rubik(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$percent%',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                color: Colors.deepPurple,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    
                    CircularProgressIndicator(
                      value: percent / 100,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.deepPurple,
                      strokeWidth: 8,
                    ),

                    const SizedBox(height: 30),

                    
                    Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.home, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Back to Home',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    Text(
                      'by BS-YTMLR',
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            
            ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange
              ],
            ),
          ],
        ),
      ),
    );
  }
}
