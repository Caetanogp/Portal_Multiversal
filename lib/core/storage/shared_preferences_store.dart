import 'package:shared_preferences/shared_preferences.dart';

import 'key_value_store.dart';

class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }
}
