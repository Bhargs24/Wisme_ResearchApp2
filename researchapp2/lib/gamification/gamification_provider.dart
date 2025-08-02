import 'package:flutter/material.dart';

class GamificationProvider extends ChangeNotifier {
  int _xp = 0;
  int _streak = 0; // days
  DateTime? _lastActivityDate;
  final List<String> _badges = [];

  int get xp => _xp;
  int get streak => _streak;
  List<String> get badges => List.unmodifiable(_badges);

  // XP logic
  void addXP(int amount) {
    _xp += amount;
    notifyListeners();
  }

  // Badge logic
  void unlockBadge(String badge) {
    if (!_badges.contains(badge)) {
      _badges.add(badge);
      notifyListeners();
    }
  }

  // Streak logic (call on activity, e.g., journey/episode completion or feedback)
  void updateStreak() {
    final today = DateTime.now();
    if (_lastActivityDate == null) {
      _streak = 1;
    } else {
      final diff = today.difference(_lastActivityDate!).inDays;
      if (diff == 1) {
        _streak += 1;
      } else if (diff > 1) {
        _streak = 1;
      }
      // If diff == 0, same day, do not increment
    }
    _lastActivityDate = today;
    notifyListeners();
  }

  // Reset streak (e.g., on missed day)
  void resetStreak() {
    _streak = 0;
    _lastActivityDate = null;
    notifyListeners();
  }

  // For persistence (to be implemented)
  Map<String, dynamic> toMap() => {
    'xp': _xp,
    'streak': _streak,
    'badges': _badges,
    'lastActivityDate': _lastActivityDate?.toIso8601String(),
  };

  void fromMap(Map<String, dynamic> map) {
    _xp = map['xp'] ?? 0;
    _streak = map['streak'] ?? 0;
    _badges.clear();
    if (map['badges'] != null) {
      _badges.addAll(List<String>.from(map['badges']));
    }
    _lastActivityDate = map['lastActivityDate'] != null
        ? DateTime.parse(map['lastActivityDate'])
        : null;
    notifyListeners();
  }
} 