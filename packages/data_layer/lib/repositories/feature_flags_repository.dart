import 'dart:async';
import 'package:flutter/foundation.dart';
import '../supabase/supabase_config.dart';

/// Centralized repository for managing and syncing application Feature Flags
/// with Supabase `public.app_configs` table (`key: 'feature_flags'`).
class FeatureFlagsRepository {
  static final FeatureFlagsRepository _instance = FeatureFlagsRepository._internal();
  factory FeatureFlagsRepository() => _instance;
  FeatureFlagsRepository._internal();

  static const Map<String, bool> defaultFlags = {
    '1v1_battle': true,
    'multiplayer_battle': true,
    'live_quiz': true,
    'mock_test_series': true,
    'fortune_wheel': true,
    'referral_earn': true,
    'live_poll': true,
    'community': true,
  };

  Map<String, bool> _cachedFlags = Map<String, bool>.from(defaultFlags);
  final _flagsController = StreamController<Map<String, bool>>.broadcast();

  Map<String, bool> get currentFlags => Map<String, bool>.unmodifiable(_cachedFlags);
  Stream<Map<String, bool>> get flagsStream => _flagsController.stream;

  bool isEnabled(String key, {bool defaultValue = true}) {
    return _cachedFlags[key] ?? defaultValue;
  }

  /// Loads current feature flags from Supabase `public.app_configs`
  Future<Map<String, bool>> getFeatureFlags() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return _cachedFlags;

    try {
      final res = await client
          .from('app_configs')
          .select('value')
          .eq('key', 'feature_flags')
          .maybeSingle();

      if (res != null && res['value'] is Map) {
        final map = res['value'] as Map;
        final updated = Map<String, bool>.from(defaultFlags);
        for (final entry in map.entries) {
          if (entry.value is bool) {
            updated[entry.key.toString()] = entry.value as bool;
          }
        }
        _cachedFlags = updated;
        _flagsController.add(_cachedFlags);
      }
    } catch (e) {
      debugPrint('FeatureFlagsRepository.getFeatureFlags error: $e');
    }
    return _cachedFlags;
  }

  /// Immediately updates a single feature flag and saves to Supabase
  Future<bool> setFeatureFlag(String key, bool enabled) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return false;

    // Optimistically update cache and notify stream
    _cachedFlags[key] = enabled;
    _flagsController.add(_cachedFlags);

    try {
      final existingRes = await client
          .from('app_configs')
          .select('value')
          .eq('key', 'feature_flags')
          .maybeSingle();

      final existingMap = (existingRes != null && existingRes['value'] is Map)
          ? Map<String, dynamic>.from(existingRes['value'] as Map)
          : Map<String, dynamic>.from(defaultFlags);

      existingMap[key] = enabled;

      await client.from('app_configs').upsert({
        'key': 'feature_flags',
        'value': existingMap,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('FeatureFlagsRepository.setFeatureFlag error: $e');
      _cachedFlags[key] = !enabled;
      _flagsController.add(_cachedFlags);
      return false;
    }
  }

  /// Replaces/updates entire feature flags map in Supabase
  Future<bool> setAllFeatureFlags(Map<String, bool> flags) async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) return false;

    _cachedFlags = Map<String, bool>.from(flags);
    _flagsController.add(_cachedFlags);

    try {
      await client.from('app_configs').upsert({
        'key': 'feature_flags',
        'value': flags,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('FeatureFlagsRepository.setAllFeatureFlags error: $e');
      return false;
    }
  }

  /// Broadcast stream of feature flags updates (notifies listeners whenever flags are loaded or modified)
  Stream<Map<String, bool>> streamFeatureFlags() {
    return _flagsController.stream;
  }
}
