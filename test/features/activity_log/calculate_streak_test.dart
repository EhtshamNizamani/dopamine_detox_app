import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/usecases/calculate_streak.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalculateStreak', () {
    DateTime dateOnly(DateTime date) {
      return DateTime(date.year, date.month, date.day);
    }

    LogEntryEntity logOnDate(DateTime date, int intensity) {
      return LogEntryEntity(
        activityName: 'Test Activity',
        intensity: intensity,
        timestamp: date,
      );
    }

    test('empty daily logs return streak 0', () {
      final streak = CalculateStreak.calculate({});

      expect(streak, 0);
    });

    test('valid today logs count as 1 streak day', () {
      final today = dateOnly(DateTime.now());

      final streak = CalculateStreak.calculate({
        today: [
          logOnDate(today, 3), // score 85, valid
        ],
      });

      expect(streak, 1);
    });

    test('invalid today logs break streak', () {
      final today = dateOnly(DateTime.now());

      final streak = CalculateStreak.calculate({
        today: [
          logOnDate(today, 3), // -15
          logOnDate(today, 3), // -15, total score 70
        ],
      });

      expect(streak, 0);
    });

    test('missing day breaks streak and does not become fake perfect day', () {
      final today = dateOnly(DateTime.now());
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final streak = CalculateStreak.calculate({
        today: [
          logOnDate(today, 3), // score 85, valid
        ],
        twoDaysAgo: [
          logOnDate(twoDaysAgo, 3), // score 85, valid
        ],
      });

      // Correct behavior:
      // Today counts.
      // Yesterday is missing, so streak stops.
      // Two days ago must NOT be counted through a fake empty day.
      expect(streak, 1);
    });

    test('consecutive valid days count correctly', () {
      final today = dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final streak = CalculateStreak.calculate({
        today: [
          logOnDate(today, 3), // score 85
        ],
        yesterday: [
          logOnDate(yesterday, 2), // score 93
        ],
        twoDaysAgo: [
          logOnDate(twoDaysAgo, 1), // score 97
        ],
      });

      expect(streak, 3);
    });

    test('wasPerfectDay returns false for missing date', () {
      final today = dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));

      final result = CalculateStreak.wasPerfectDay(
        yesterday,
        {
          today: [
            logOnDate(today, 1),
          ],
        },
      );

      expect(result, false);
    });

    test('wasPerfectDay returns true for date with empty logs only if date exists', () {
      final today = dateOnly(DateTime.now());

      final result = CalculateStreak.wasPerfectDay(
        today,
        {
          today: [],
        },
      );

      expect(result, true);
    });
  });
}