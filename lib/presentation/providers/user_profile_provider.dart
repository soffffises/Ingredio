import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredio/data/local/hive_database.dart';
import 'package:ingredio/di/service_locator.dart';

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier(getIt<HiveDatabase>());
});

class UserProfileState {
  final String? name;

  const UserProfileState({this.name});

  bool get isRegistered => name != null && name!.trim().isNotEmpty;
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final HiveDatabase _hiveDatabase;

  UserProfileNotifier(this._hiveDatabase)
      : super(UserProfileState(name: _hiveDatabase.loadUserName()));

  Future<void> register(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;
    await _hiveDatabase.saveUserName(trimmedName);
    state = UserProfileState(name: trimmedName);
  }

  Future<void> logout() async {
    await _hiveDatabase.clearUserName();
    state = const UserProfileState();
  }

  Future<void> deleteAllData() async {
    await _hiveDatabase.clearAllData();
    state = const UserProfileState();
  }
}
