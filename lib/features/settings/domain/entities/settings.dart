import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final bool notificationsEnabled;
  final bool darkModeEnabled;  // future use

  const SettingsEntity({
    required this.notificationsEnabled,
    this.darkModeEnabled = true,
  });

  @override
  List<Object?> get props => [notificationsEnabled, darkModeEnabled];
}