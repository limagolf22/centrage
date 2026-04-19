import 'package:shared_preferences/shared_preferences.dart';

/// Persistent configuration service using shared_preferences.
/// On web, this uses localStorage. On native platforms, it uses native preferences.
class AppConfig {
  static AppConfig? _instance;
  static SharedPreferences? _prefs;

  // Keys for stored values
  static const String _keyPilotWeight = 'pilot_weight';
  static const String _keyParachuteWeight = 'parachute_weight';

  // Default values
  double pilotWeight = 80.0;
  double parachuteWeight = 5.0;

  AppConfig._();

  /// Get singleton instance
  static AppConfig get instance {
    _instance ??= AppConfig._();
    return _instance!;
  }

  /// Initialize the config - must be called before using
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await instance._load();
  }

  /// Load all values from persistent storage
  Future<void> _load() async {
    pilotWeight = _prefs?.getDouble(_keyPilotWeight) ?? 70.0;
    parachuteWeight = _prefs?.getDouble(_keyParachuteWeight) ?? 5.0;
  }

  /// Save pilot weight
  Future<void> setPilotWeight(double weight) async {
    pilotWeight = weight;
    await _prefs?.setDouble(_keyPilotWeight, weight);
  }

  /// Save parachute weight
  Future<void> setParachuteWeight(double weight) async {
    parachuteWeight = weight;
    await _prefs?.setDouble(_keyParachuteWeight, weight);
  }

  /// Clear all stored configuration
  Future<void> clear() async {
    await _prefs?.clear();
    pilotWeight = 80.0;
    parachuteWeight = 5.0;
  }
}

/// Global accessor for app configuration
AppConfig get config => AppConfig.instance;
