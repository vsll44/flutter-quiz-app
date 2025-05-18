class Quiz {
  final String title;
  final String description;
  final List<Question> questions;

  Quiz({required this.title, required this.description, required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}

class Question {
  final String question;
  final String? imageUrl;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.question,
    this.imageUrl,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      imageUrl: json['imageUrl'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
    );
  }

  get correctAnswer => null;
}