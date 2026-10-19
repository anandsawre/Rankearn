import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  group('Result Pattern', () {
    test('Success holds data and folds correctly', () {
      const Result<int> result = Success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      final folded = result.fold(
        onSuccess: (d) => 'Value: $d',
        onFailure: (m, _) => 'Failed: $m',
      );
      expect(folded, 'Value: 42');
    });

    test('Failure holds error message and folds correctly', () {
      const Result<int> result = Failure('Server Error', 500);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, 'Server Error');
      final folded = result.fold(
        onSuccess: (d) => 'Value: $d',
        onFailure: (m, e) => 'Failed: $m ($e)',
      );
      expect(folded, 'Failed: Server Error (500)');
    });
  });

  group('Validators', () {
    test('Email validator accepts valid and rejects invalid', () {
      expect(AppValidators.validateEmail('user@test.com'), isNull);
      expect(AppValidators.validateEmail('invalid-email'), isNotNull);
      expect(AppValidators.validateEmail(''), isNotNull);
    });

    test('UTR validator validates 10-20 characters', () {
      expect(AppValidators.validateUtr('123456789012'), isNull);
      expect(AppValidators.validateUtr('short'), isNotNull);
      expect(AppValidators.validateUtr(''), isNotNull);
    });

    test('UPI ID validator checks for @', () {
      expect(AppValidators.validateUpiId('user@bank'), isNull);
      expect(AppValidators.validateUpiId('nobank'), isNotNull);
    });
  });

  group('Formatters', () {
    test('Format coins and rupees', () {
      expect(AppFormatters.formatCoins(1450), '1,450');
      expect(AppFormatters.formatCoins(100000), '1,00,000');
      expect(AppFormatters.formatRupees(250), '₹250.00');
      expect(AppFormatters.formatTimeTaken(75), '01:15');
    });
  });

  group('Scoring Engine', () {
    test('Computes score and accuracy with negative marking', () {
      final userAnswers = {
        'q1': 0, // correct
        'q2': 1, // correct
        'q3': 2, // wrong (expected 1)
        'q4': null, // skipped
      };

      final correctAnswers = {
        'q1': 0,
        'q2': 1,
        'q3': 1,
        'q4': 3,
      };

      final metrics = ScoringEngine.compute(
        userAnswers: userAnswers,
        correctAnswers: correctAnswers,
        negativeMarking: 0.25,
      );

      expect(metrics.totalQuestions, 4);
      expect(metrics.correct, 2);
      expect(metrics.wrong, 1);
      expect(metrics.skipped, 1);
      // 2 correct (2.0) - 1 wrong (0.25) = 1.75
      expect(metrics.score, 1.75);
      // 2 / 3 attempted * 100 = 66.67%
      expect(metrics.accuracy, 66.67);
    });
  });
}
