import 'package:flutter/material.dart';
import '../../domain/entities/log_entry_entity.dart';
import '../../domain/usecases/add_log_usecase.dart';

class ActivityLogViewModel extends ChangeNotifier {
  final AddLogUseCase addLogUseCase;

  ActivityLogViewModel({required this.addLogUseCase});

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
      (_) {
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