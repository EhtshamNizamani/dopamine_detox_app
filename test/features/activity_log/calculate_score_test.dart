import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/calculate_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculateScore', () {
    LogEntryEntity logWithIntensity(int intensity) {
      return LogEntryEntity(
        activityName: 'Test Activity',
        intensity: intensity,
        timestamp: DateTime.now(),
      );
    }

    test('empty logs return perfect score 100', () {
      final score = CalculateScore.calculate([]);

      expect(score, AppConstants.maxDopamineScore);
      expect(score, 100);
    });

    test('low intensity subtracts low penalty', () {
      final score = CalculateScore.calculate([
        logWithIntensity(1),
      ]);

      expect(score, 100 - AppConstants.lowIntensityPenalty);
      expect(score, 97);
    });

    test('medium intensity subtracts medium penalty', () {
      final score = CalculateScore.calculate([
        logWithIntensity(2),
      ]);

      expect(score, 100 - AppConstants.mediumIntensityPenalty);
      expect(score, 93);
    });

    test('high intensity subtracts high penalty', () {
      final score = CalculateScore.calculate([
        logWithIntensity(3),
      ]);

      expect(score, 100 - AppConstants.highIntensityPenalty);
      expect(score, 85);
    });

    test('multiple logs subtract combined penalties', () {
      final score = CalculateScore.calculate([
        logWithIntensity(1), // -3
        logWithIntensity(2), // -7
        logWithIntensity(3), // -15
      ]);

      expect(score, 75);
    });

    test('score never goes below 0', () {
      final logs = List.generate(
        20,
        (_) => logWithIntensity(3),
      );

      final score = CalculateScore.calculate(logs);

      expect(score, 0);
    });

    test('score 80 or above is valid for streak', () {
      expect(CalculateScore.isStreakValid(100), true);
      expect(CalculateScore.isStreakValid(85), true);
      expect(CalculateScore.isStreakValid(80), true);
    });

    test('score below 80 is not valid for streak', () {
      expect(CalculateScore.isStreakValid(79), false);
      expect(CalculateScore.isStreakValid(50), false);
      expect(CalculateScore.isStreakValid(0), false);
    });

    test('only score 100 is perfect day', () {
      expect(CalculateScore.isPerfectDay(100), true);
      expect(CalculateScore.isPerfectDay(99), false);
      expect(CalculateScore.isPerfectDay(80), false);
    });
  });
}