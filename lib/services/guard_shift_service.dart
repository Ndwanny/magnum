import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the guard's clock-in state across app restarts.
class GuardShiftService extends ChangeNotifier {
  static const _keyClockIn = 'guard_clock_in_time';
  static const _keySite = 'guard_clock_in_site';

  DateTime? _clockInTime;
  String? _site;
  bool _isLoaded = false;

  DateTime? get clockInTime => _clockInTime;
  String? get site => _site;
  bool get isClockedIn => _clockInTime != null;
  bool get isLoaded => _isLoaded;

  Duration get hoursWorked =>
      _clockInTime != null ? DateTime.now().difference(_clockInTime!) : Duration.zero;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_keyClockIn);
    if (ms != null) {
      _clockInTime = DateTime.fromMillisecondsSinceEpoch(ms);
      _site = prefs.getString(_keySite);
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> clockIn(String site) async {
    _clockInTime = DateTime.now();
    _site = site;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyClockIn, _clockInTime!.millisecondsSinceEpoch);
    await prefs.setString(_keySite, site);
    notifyListeners();
  }

  Future<void> clockOut() async {
    _clockInTime = null;
    _site = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyClockIn);
    await prefs.remove(_keySite);
    notifyListeners();
  }
}
