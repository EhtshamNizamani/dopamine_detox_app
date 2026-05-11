import 'dart:async';

import 'package:dopamine_detox_app/features/auth/domain/entities/user_entity.dart';
import 'package:dopamine_detox_app/features/auth/domain/usecases/check_auth_status.dart';
import 'package:dopamine_detox_app/features/auth/domain/usecases/sign_in_anonymously.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  final SignInAnonymously signInAnonymously;
  final CheckAuthStatus checkAuthStatus;
  
  AuthViewModel({
    required this.signInAnonymously,
    required this.checkAuthStatus,
  });
  
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _authSubscription;
  
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  void init() {
    _isLoading = true;
    notifyListeners();
    
    // Listen to auth state changes from stream
    _authSubscription = checkAuthStatus().listen((result) {
      result.fold(
        (error) {
          _error = error;
          _isLoading = false;
          notifyListeners();
        },
        (user) {
          _currentUser = user;
          _isLoading = false;
          notifyListeners();
        },
      );
    });
  }
  
  Future<bool> signIn() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await signInAnonymously();
    return result.fold(
      (error) {
        _error = error;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (user) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}