import 'package:dartz/dartz.dart';
import 'package:dopamine_detox_app/core/constants/app_constants.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/entities/log_entry_entity.dart';
import 'package:dopamine_detox_app/features/activity_log/domain/repositories/log_repository.dart';
import 'package:dopamine_detox_app/features/gamification/domain/entities/gamification.dart';
import 'package:dopamine_detox_app/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/check_and_update_streak.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckAndUpdateStreakUseCase', () {
    DateTime dateOnly(DateTime date) {
      return DateTime(date.year, date.month, date.day);
    }

    String dateKey(DateTime date) {
      final cleanDate = dateOnly(date);
      return cleanDate.toIso8601String();
    }

    LogEntryEntity logOnDate(DateTime date, int intensity) {
      return LogEntryEntity(
        activityName: 'Test Activity',
        intensity: intensity,
        timestamp: date,
      );
    }

    test('first run does not award fake streak or XP', () async {
      final today = dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));

      final gamificationRepository = FakeGamificationRepository(
        gamification: const GamificationEntity(
          totalXP: 0,
          level: 1,
          unlockedBadges: [],
          currentStreak: 0,
          lastStreakCheckDate: null,
          lastDailyOpenDate: null,
        ),
      );

      final logRepository = FakeLogRepository();

      final useCase = CheckAndUpdateStreakUseCase(
        gamificationRepository,
        logRepository,
      );

      final result = await useCase();

      expect(result.isRight(), true);

      result.fold(
        (_) => fail('Expected success'),
        (data) {
          expect(data.newStreak, 0);
          expect(data.xpAwarded, 0);
          expect(data.wasPerfectDay, false);
        },
      );

      expect(gamificationRepository.updatedStreak, 0);
      expect(
        dateOnly(gamificationRepository.updatedCheckDate!),
        yesterday,
      );
      expect(gamificationRepository.addedXP, 0);
    });

    test('clean yesterday awards perfect day XP and increases streak', () async {
      final today = dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final gamificationRepository = FakeGamificationRepository(
        gamification: GamificationEntity(
          totalXP: 0,
          level: 1,
          unlockedBadges: const [],
          currentStreak: 0,
          lastStreakCheckDate: twoDaysAgo,
          lastDailyOpenDate: null,
        ),
      );

      final logRepository = FakeLogRepository(
        logsByDate: {
          dateKey(yesterday): [],
        },
      );

      final useCase = CheckAndUpdateStreakUseCase(
        gamificationRepository,
        logRepository,
      );

      final result = await useCase();

      expect(result.isRight(), true);

      result.fold(
        (_) => fail('Expected success'),
        (data) {
          expect(data.newStreak, 1);
          expect(data.xpAwarded, AppConstants.xpPerfectDay);
          expect(data.wasPerfectDay, true);
          expect(data.todayScore, 100);
        },
      );

      expect(gamificationRepository.updatedStreak, 1);
      expect(gamificationRepository.addedXP, AppConstants.xpPerfectDay);
      expect(
        dateOnly(gamificationRepository.updatedCheckDate!),
        yesterday,
      );
    });

    test('good yesterday awards good day XP and increases streak', () async {
      final today = dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final gamificationRepository = FakeGamificationRepository(
        gamification: GamificationEntity(
          totalXP: 0,
          level: 1,
          unlockedBadges: const [],
          currentStreak: 0,
          lastStreakCheckDate: twoDaysAgo,
          lastDailyOpenDate: null,
        ),
      );

      final logRepository = FakeLogRepository(
        logsByDate: {
          dateKey(yesterday): [
            logOnDate(yesterday, 3), // score 85, valid but not perfect
          ],
        },
      );

      final useCase = CheckAndUpdateStreakUseCase(
        gamificationRepository,
        logRepository,
      );

      final result = await useCase();

      expect(result.isRight(), true);

      result.fold(
        (_) => fail('Expected success'),
        (data) {
          expect(data.newStreak, 1);
          expect(data.xpAwarded, AppConstants.xpGoodDay);
          expect(data.wasPerfectDay, false);
          expect(data.todayScore, 85);
        },
      );

      expect(gamificationRepository.updatedStreak, 1);
      expect(gamificationRepository.addedXP, AppConstants.xpGoodDay);
    });

    test('bad yesterday resets streak and awards no XP', () async {
      final today = dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final gamificationRepository = FakeGamificationRepository(
        gamification: GamificationEntity(
          totalXP: 200,
          level: 2,
          unlockedBadges: const [],
          currentStreak: 5,
          lastStreakCheckDate: twoDaysAgo,
          lastDailyOpenDate: null,
        ),
      );

      final logRepository = FakeLogRepository(
        logsByDate: {
          dateKey(yesterday): [
            logOnDate(yesterday, 3), // -15
            logOnDate(yesterday, 3), // -15, score 70
          ],
        },
      );

      final useCase = CheckAndUpdateStreakUseCase(
        gamificationRepository,
        logRepository,
      );

      final result = await useCase();

      expect(result.isRight(), true);

      result.fold(
        (_) => fail('Expected success'),
        (data) {
          expect(data.newStreak, 0);
          expect(data.xpAwarded, 0);
          expect(data.wasPerfectDay, false);
          expect(data.todayScore, 70);
        },
      );

      expect(gamificationRepository.updatedStreak, 0);
      expect(gamificationRepository.addedXP, 0);
    });

    test('already processed yesterday does not award XP twice', () async {
      final today = dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));

      final gamificationRepository = FakeGamificationRepository(
        gamification: GamificationEntity(
          totalXP: 50,
          level: 1,
          unlockedBadges: const [],
          currentStreak: 1,
          lastStreakCheckDate: yesterday,
          lastDailyOpenDate: null,
        ),
      );

      final logRepository = FakeLogRepository(
        logsByDate: {
          dateKey(yesterday): [],
        },
      );

      final useCase = CheckAndUpdateStreakUseCase(
        gamificationRepository,
        logRepository,
      );

      final result = await useCase();

      expect(result.isRight(), true);

      result.fold(
        (_) => fail('Expected success'),
        (data) {
          expect(data.newStreak, 1);
          expect(data.xpAwarded, 0);
        },
      );

      expect(gamificationRepository.updatedStreak, null);
      expect(gamificationRepository.addedXP, 0);
    });

    test('missed multiple days reset previous streak before checking yesterday', () async {
      final today = dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));
      final fourDaysAgo = today.subtract(const Duration(days: 4));

      final gamificationRepository = FakeGamificationRepository(
        gamification: GamificationEntity(
          totalXP: 500,
          level: 5,
          unlockedBadges: const [],
          currentStreak: 10,
          lastStreakCheckDate: fourDaysAgo,
          lastDailyOpenDate: null,
        ),
      );

      final logRepository = FakeLogRepository(
        logsByDate: {
          dateKey(yesterday): [
            logOnDate(yesterday, 3), // score 85, valid
          ],
        },
      );

      final useCase = CheckAndUpdateStreakUseCase(
        gamificationRepository,
        logRepository,
      );

      final result = await useCase();

      expect(result.isRight(), true);

      result.fold(
        (_) => fail('Expected success'),
        (data) {
          // Old streak 10 should not continue after missed days.
          // It resets first, then yesterday becomes streak 1.
          expect(data.newStreak, 1);
          expect(data.xpAwarded, AppConstants.xpGoodDay);
        },
      );

      expect(gamificationRepository.updatedStreak, 1);
    });
  });
}

class FakeGamificationRepository implements GamificationRepository {
  GamificationEntity gamification;

  int? updatedStreak;
  DateTime? updatedCheckDate;
  int addedXP = 0;

  FakeGamificationRepository({
    required this.gamification,
  });

  @override
  Future<Either<String, GamificationEntity>> getGamification() async {
    return Right(gamification);
  }

  @override
  Future<Either<String, void>> addXP(int xp) async {
    addedXP += xp;

    final newTotalXP = gamification.totalXP + xp;

    gamification = GamificationEntity(
      totalXP: newTotalXP,
      level: GamificationEntity.calculateLevel(newTotalXP),
      unlockedBadges: gamification.unlockedBadges,
      currentStreak: gamification.currentStreak,
      lastStreakCheckDate: gamification.lastStreakCheckDate,
      lastDailyOpenDate: gamification.lastDailyOpenDate,
    );

    return const Right(null);
  }

  @override
  Future<Either<String, void>> updateStreak(
    int newStreak, {
    DateTime? checkDate,
  }) async {
    updatedStreak = newStreak;
    updatedCheckDate = checkDate;

    gamification = GamificationEntity(
      totalXP: gamification.totalXP,
      level: gamification.level,
      unlockedBadges: gamification.unlockedBadges,
      currentStreak: newStreak,
      lastStreakCheckDate: checkDate ?? DateTime.now(),
      lastDailyOpenDate: gamification.lastDailyOpenDate,
    );

    return const Right(null);
  }

  @override
  Future<Either<String, void>> unlockBadge(String badgeId) async {
    final badges = List<String>.from(gamification.unlockedBadges);

    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
    }

    gamification = GamificationEntity(
      totalXP: gamification.totalXP,
      level: gamification.level,
      unlockedBadges: badges,
      currentStreak: gamification.currentStreak,
      lastStreakCheckDate: gamification.lastStreakCheckDate,
      lastDailyOpenDate: gamification.lastDailyOpenDate,
    );

    return const Right(null);
  }

  @override
  Future<Either<String, bool>> hasBadge(String badgeId) async {
    return Right(gamification.unlockedBadges.contains(badgeId));
  }

  @override
  Future<Either<String, List<String>>> checkAndUnlockBadges({
    required int currentStreak,
    required int currentLevel,
    required int todayScore,
    required int totalLogsCount,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<String, int>> getCurrentStreak() async {
    return Right(gamification.currentStreak);
  }

  @override
  Future<Either<String, bool>> checkDailyOpenXP() async {
    return const Right(false);
  }
}

class FakeLogRepository implements LogRepository {
  final Map<String, List<LogEntryEntity>> logsByDate;
  final List<LogEntryEntity> addedLogs = [];

  FakeLogRepository({
    this.logsByDate = const {},
  });

  String _dateKey(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    return cleanDate.toIso8601String();
  }

  @override
  Future<Either<String, void>> addLog(LogEntryEntity log) async {
    addedLogs.add(log);
    return const Right(null);
  }

  @override
  Future<Either<String, List<LogEntryEntity>>> getLogsForDate(
    DateTime date,
  ) async {
    return Right(logsByDate[_dateKey(date)] ?? []);
  }

  @override
  Future<Either<String, List<LogEntryEntity>>> getRecentLogs({
    int limit = 10,
  }) async {
    final logs = logsByDate.values.expand((logs) => logs).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Right(logs.take(limit).toList());
  }

  @override
  Future<Either<String, int>> getTotalLogsCount() async {
    final count = logsByDate.values.fold<int>(
      0,
      (total, logs) => total + logs.length,
    );

    return Right(count);
  }
}