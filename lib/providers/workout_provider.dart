import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _workoutService = WorkoutService();

  final List<Workout> _workouts = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Workout> get workouts => _workouts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  Future<void> loadInitialWorkouts() async {
    _workouts.clear();
    _currentPage = 1;
    _isLoading = true;
    _errorMessage = null;
    _hasMore = true;
    notifyListeners();

    try {
      final fetchedWorkouts = await _workoutService.fetchWorkouts(page: _currentPage);
      _workouts.addAll(fetchedWorkouts);
      if (fetchedWorkouts.isEmpty) {
        _hasMore = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentPage++;
      final fetchedWorkouts = await _workoutService.fetchWorkouts(page: _currentPage);
      if (fetchedWorkouts.isEmpty) {
        _hasMore = false;
      } else {
        _workouts.addAll(fetchedWorkouts);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
