import 'package:dopamine_detox_app/features/activity_log/domain/usecases/get_total_logs_count.dart';
import 'package:dopamine_detox_app/features/gamification/domain/usecases/add_xp.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/log_entry_entity.dart';
import '../../domain/usecases/add_log_usecase.dart';

class ActivityLogViewModel extends ChangeNotifier {
  final AddLogUseCase addLogUseCase;
  final AddXPUseCase addXPUseCase;  
  final GetTotalLogsCountUseCase getTotalLogsCount; // new

  ActivityLogViewModel({required this.addLogUseCase, required this.addXPUseCase, required this.getTotalLogsCount});

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> logActivity(String activityName, int intensity) async {
    _isLoading = true;
    notifyListeners();

    final log = LogEntryEntity(
      activityName: activityName,
      intensity: intensity,
      timestamp: DateTime.now(),
    );

    final result = await addLogUseCase(log);
    return result.fold(
      (error) {
        _error = error;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) async {
        int xp = intensity == 1 ? 10 : (intensity == 2 ? 20 : 30);
        await addXPUseCase(xp);
        
        // Get total logs count after inserting
        final countResult = await getTotalLogsCount();
         countResult.fold(
          (error) => print('Error getting count: $error'),
          (count) async {
            if (count == 1) {
              // TODO: Unlock first log badge via use case
              print('First log badge unlocked!');
            }
          },
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }
  
}