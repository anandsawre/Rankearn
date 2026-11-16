import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_core/shared_core.dart';
import '../models/banner_model.dart';
import '../supabase/supabase_config.dart';

class BannersRepository {
  final SupabaseClient? _client;

  BannersRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.clientSafe;

  /// Fetches active promotional banners ordered by priority.
  Future<Result<List<BannerModel>>> getActiveBanners({String? displayMode}) async {
    final client = _client ?? SupabaseConfig.clientSafe;
    if (client == null) {
      return const Failure('Supabase client is not available');
    }

    try {
      final response = await client
          .from('app_banners')
          .select()
          .eq('is_active', true)
          .order('priority', ascending: true);

      final list = (response as List)
          .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
          .where((banner) {
            if (displayMode == null) return true;
            return banner.displayMode == displayMode;
          })
          .toList();

      return Success(list);
    } catch (e) {
      return Failure('Failed to fetch banners: $e');
    }
  }

  /// Streams active promotional banners in realtime (optionally filtered by displayMode).
  Stream<List<BannerModel>> streamActiveBanners({String? displayMode}) {
    final client = _client ?? SupabaseConfig.clientSafe;
    if (client == null) {
      return const Stream.empty();
    }

    return client
        .from('app_banners')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('priority', ascending: true)
        .map((rows) {
          final all = rows.map((e) => BannerModel.fromJson(e)).toList();
          if (displayMode == null) return all;
          return all.where((b) => b.displayMode == displayMode).toList();
        });
  }

  /// Increments click count for attribution.
  Future<void> recordClick(String bannerId) async {
    final client = _client ?? SupabaseConfig.clientSafe;
    if (client == null || bannerId.isEmpty) return;

    try {
      await client.rpc('increment_banner_clicks', params: {'banner_id': bannerId});
    } catch (_) {
      try {
        final current = await client.from('app_banners').select('clicks').eq('id', bannerId).maybeSingle();
        final count = (current?['clicks'] as num?)?.toInt() ?? 0;
        await client.from('app_banners').update({'clicks': count + 1}).eq('id', bannerId);
      } catch (_) {}
    }
  }
}
