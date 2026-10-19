/// Question Option Item
class QuestionOption {
  final String textEnglish;
  final String? textHindi;
  final String? image;

  const QuestionOption({
    required this.textEnglish,
    this.textHindi,
    this.image,
  });

  String getDisplay(bool isHindi) {
    if (isHindi && textHindi != null && textHindi!.trim().isNotEmpty) {
      return textHindi!;
    }
    return textEnglish;
  }

  factory QuestionOption.fromMap(Map<String, dynamic> map) {
    return QuestionOption(
      textEnglish: map['textEnglish']?.toString() ?? map['text_english']?.toString() ?? '',
      textHindi: map['textHindi']?.toString() ?? map['text_hindi']?.toString(),
      image: map['image']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'textEnglish': textEnglish,
        'textHindi': textHindi,
        'image': image,
      };
}

/// Question Domain Model
class QuestionModel {
  final String id;
  final String testId;
  final int questionNumber;
  final String questionTextEnglish;
  final String? questionTextHindi;
  final List<QuestionOption> options;
  final int correctAnswer;
  final String? explanationEnglish;
  final String? explanationHindi;
  final String difficultyLevel;
  final String? subject;
  final String? topic;
  final String? imageUrl;

  const QuestionModel({
    required this.id,
    required this.testId,
    required this.questionNumber,
    required this.questionTextEnglish,
    this.questionTextHindi,
    required this.options,
    required this.correctAnswer,
    this.explanationEnglish,
    this.explanationHindi,
    this.difficultyLevel = 'medium',
    this.subject,
    this.topic,
    this.imageUrl,
  });

  String getDisplayText(bool isHindi) {
    if (isHindi && questionTextHindi != null && questionTextHindi!.trim().isNotEmpty) {
      return questionTextHindi!;
    }
    return questionTextEnglish;
  }

  String? getDisplayExplanation(bool isHindi) {
    if (isHindi && explanationHindi != null && explanationHindi!.trim().isNotEmpty) {
      return explanationHindi!;
    }
    return explanationEnglish;
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    final rawOptions = map['options'];
    final List<QuestionOption> parsedOptions = [];
    if (rawOptions is List) {
      for (final opt in rawOptions) {
        if (opt is Map<String, dynamic>) {
          parsedOptions.add(QuestionOption.fromMap(opt));
        } else if (opt is Map) {
          parsedOptions.add(QuestionOption.fromMap(Map<String, dynamic>.from(opt)));
        }
      }
    }

    return QuestionModel(
      id: map['id']?.toString() ?? '',
      testId: map['test_id']?.toString() ?? map['testId']?.toString() ?? '',
      questionNumber: (map['question_number'] as num?)?.toInt() ?? 1,
      questionTextEnglish: map['question_text_english']?.toString() ?? map['questionTextEnglish']?.toString() ?? '',
      questionTextHindi: map['question_text_hindi']?.toString() ?? map['questionTextHindi']?.toString(),
      options: parsedOptions,
      correctAnswer: (map['correct_answer'] as num?)?.toInt() ?? (map['correctAnswer'] as num?)?.toInt() ?? 0,
      explanationEnglish: map['explanation_english']?.toString() ?? map['explanation']?.toString(),
      explanationHindi: map['explanation_hindi']?.toString() ?? map['explanationHindi']?.toString(),
      difficultyLevel: map['difficulty_level']?.toString() ?? map['difficultyLevel']?.toString() ?? 'medium',
      subject: map['subject']?.toString(),
      topic: map['topic']?.toString(),
      imageUrl: map['image_url']?.toString() ?? map['imageURL']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'test_id': testId,
      'question_number': questionNumber,
      'question_text_english': questionTextEnglish,
      'question_text_hindi': questionTextHindi,
      'options': options.map((o) => o.toMap()).toList(),
      'correct_answer': correctAnswer,
      'explanation_english': explanationEnglish,
      'explanation_hindi': explanationHindi,
      'difficulty_level': difficultyLevel,
      'subject': subject,
      'topic': topic,
      'image_url': imageUrl,
    };
  }
}
