import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ingredio/data/local/hive_database.dart';
import 'package:ingredio/di/service_locator.dart';

final hiveDatabaseProvider = Provider<HiveDatabase>((ref) {
  return getIt<HiveDatabase>();
});
