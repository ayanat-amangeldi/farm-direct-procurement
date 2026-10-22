import 'package:shared_preferences/shared_preferences.dart';
import 'order_store.dart';

/// Non-critical prototype data only; real procurement requires a backend.
class PreferencesOrderPersistence implements OrderPersistence {
  final _preferences = SharedPreferencesAsync();
  static const _key = 'farm_direct_demo_orders_v1';
  @override
  Future<String?> read() => _preferences.getString(_key);
  @override
  Future<void> write(String value) => _preferences.setString(_key, value);
}
