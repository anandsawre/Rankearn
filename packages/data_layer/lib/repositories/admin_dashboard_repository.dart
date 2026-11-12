import 'dart:math' as math;
import 'package:shared_core/shared_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_dashboard_models.dart';
import '../supabase/supabase_config.dart';

/// Production repository powering the Admin Dashboard Overview tab.
/// Fetches live counts, time-series aggregations, recent entities,
/// activity events, and real backend health metrics from Supabase.
class AdminDashboardRepository {
  final SupabaseClient? _explicitClient;

  AdminDashboardRepository({SupabaseClient? client}) : _explicitClient = client;

  SupabaseClient? get _client => _explicitClient ?? SupabaseConfig.clientSafe;

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Fetch complete live dashboard snapshot for the given filters.
  Future<Result<AdminDashboardSnapshot>> fetchOverviewSnapshot({
    required DateTime attemptsStartDate,
    required DateTime attemptsEndDate,
    required String userGrowthPeriod,
  }) async {
    final client = _client;
    if (client == null) {
      return const Failure('Database connection is not initialized.');
    }

    final totalStopwatch = Stopwatch()..start();
    final nowLocal = DateTime.now();
    final todayStartLocal = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final fourteenDaysAgoUtc = todayStartLocal.subtract(const Duration(days: 14)).toUtc();

    final normalizedAttemptsStart = DateTime(
      attemptsStartDate.year,
      attemptsStartDate.month,
      attemptsStartDate.day,
    );
    final normalizedAttemptsEnd = DateTime(
      attemptsEndDate.year,
      attemptsEndDate.month,
      attemptsEndDate.day,
    );
    final attemptsEndExclusiveUtc =
        normalizedAttemptsEnd.add(const Duration(days: 1)).toUtc();
    final earliestAttemptsUtc = normalizedAttemptsStart.toUtc().isBefore(fourteenDaysAgoUtc)
        ? normalizedAttemptsStart.toUtc()
        : fourteenDaysAgoUtc;

    final profileWindowStartLocal = _resolveUserGrowthStart(userGrowthPeriod, todayStartLocal);
    final earliestProfilesUtc = profileWindowStartLocal.toUtc().isBefore(fourteenDaysAgoUtc)
        ? profileWindowStartLocal.toUtc()
        : fourteenDaysAgoUtc;

    bool dbUsersOk = false;
    bool contentOk = false;
    bool attemptsOk = false;
    bool notificationsOk = false;
    bool configOk = false;

    int? dbLatencyMs;
    int? contentLatencyMs;
    int? attemptsLatencyMs;

    int profilesCount = 0;
    List<Map<String, dynamic>> recentProfileRows = [];
    List<DateTime> profileCreatedDates = [];

    int testsCount = 0;
    List<Map<String, dynamic>> testRows = [];
    List<Map<String, dynamic>> categoryRows = [];
    List<Map<String, dynamic>> examCategoryRows = [];

    int questionsCount = 0;
    List<DateTime> questionCreatedDates = [];

    int attemptsCount = 0;
    List<Map<String, dynamic>> attemptRows = [];

    List<Map<String, dynamic>> activityLogRows = [];

    Object? primaryError;

    // 1. Users & Profiles Probe
    final usersFuture = () async {
      final sw = Stopwatch()..start();
      try {
        final countRes = await client.from('profiles').count(CountOption.exact);
        final recentRes = await client
            .from('profiles')
            .select('id, name, email, status, created_at')
            .order('created_at', ascending: false)
            .limit(5);
        final historyRes = await client
            .from('profiles')
            .select('created_at')
            .gte('created_at', earliestProfilesUtc.toIso8601String())
            .order('created_at', ascending: false)
            .limit(5000);

        profilesCount = countRes;
        recentProfileRows = List<Map<String, dynamic>>.from(recentRes as List);
        profileCreatedDates = _extractDates(historyRes as List, 'created_at');
        dbUsersOk = true;
      } catch (e) {
        primaryError ??= e;
      } finally {
        sw.stop();
        dbLatencyMs = sw.elapsedMilliseconds;
      }
    }();

    // 2. Content (Tests, Questions, Categories) Probe
    final contentFuture = () async {
      final sw = Stopwatch()..start();
      try {
        final testsCountRes = await client.from('tests').count(CountOption.exact);
        final testsRes = await client
            .from('tests')
            .select('*')
            .order('created_at', ascending: false)
            .limit(2000);
        final questionsCountRes = await client.from('questions').count(CountOption.exact);
        final questionsHistRes = await client
            .from('questions')
            .select('created_at')
            .gte('created_at', fourteenDaysAgoUtc.toIso8601String())
            .order('created_at', ascending: false)
            .limit(5000);
        final categoriesRes = await client
            .from('categories')
            .select('*')
            .order('display_order', ascending: true);
        final examCategoriesRes = await client
            .from('exam_categories')
            .select('id, name');

        testsCount = testsCountRes;
        testRows = List<Map<String, dynamic>>.from(testsRes as List);
        questionsCount = questionsCountRes;
        questionCreatedDates = _extractDates(questionsHistRes as List, 'created_at');
        categoryRows = List<Map<String, dynamic>>.from(categoriesRes as List);
        examCategoryRows = List<Map<String, dynamic>>.from(examCategoriesRes as List);
        contentOk = true;
      } catch (e) {
        primaryError ??= e;
      } finally {
        sw.stop();
        contentLatencyMs = sw.elapsedMilliseconds;
      }
    }();

    // 3. Attempts Probe
    final attemptsFuture = () async {
      final sw = Stopwatch()..start();
      try {
        final attemptsCountRes = await client.from('attempts').count(CountOption.exact);
        final attemptsHistRes = await client
            .from('attempts')
            .select('id, test_id, user_id, score, status, created_at')
            .gte('created_at', earliestAttemptsUtc.toIso8601String())
            .lt('created_at', attemptsEndExclusiveUtc.toIso8601String())
            .order('created_at', ascending: false)
            .limit(5000);

        attemptsCount = attemptsCountRes;
        attemptRows = List<Map<String, dynamic>>.from(attemptsHistRes as List);
        attemptsOk = true;
      } catch (e) {
        primaryError ??= e;
      } finally {
        sw.stop();
        attemptsLatencyMs = sw.elapsedMilliseconds;
      }
    }();

    // 4. Optional Secondary Probes (Notifications, App Configs)
    // Note: Activity feed is built directly from tests, profiles, and attempts below.
    final optionalFuture = () async {

      try {
        await client.from('notifications').select('id').limit(1);
        notificationsOk = true;
      } catch (_) {
        notificationsOk = false;
      }

      try {
        await client.from('app_configs').select('key').limit(1);
        configOk = true;
      } catch (_) {
        configOk = false;
      }
    }();

    await Future.wait([usersFuture, contentFuture, attemptsFuture, optionalFuture]);
    totalStopwatch.stop();

    if (!dbUsersOk && !contentOk && !attemptsOk) {
      return Failure(
        'Failed to load dashboard data from database: ${primaryError ?? 'Network error'}',
        primaryError,
      );
    }

    // Build Metrics
    final testCreatedDates = _extractDates(testRows, 'created_at');
    final attemptCreatedDates = _extractDates(attemptRows, 'created_at');

    final usersMetric = _buildMetricSummary(
      total: profilesCount,
      dates: profileCreatedDates,
      nowLocal: nowLocal,
      todayStartLocal: todayStartLocal,
      emptyWeekLabel: '0 this week',
    );
    final quizzesMetric = _buildMetricSummary(
      total: testsCount,
      dates: testCreatedDates,
      nowLocal: nowLocal,
      todayStartLocal: todayStartLocal,
      emptyWeekLabel: '0 this week',
    );
    final questionsMetric = _buildMetricSummary(
      total: questionsCount,
      dates: questionCreatedDates,
      nowLocal: nowLocal,
      todayStartLocal: todayStartLocal,
      emptyWeekLabel: '0 this week',
    );
    final attemptsMetric = _buildMetricSummary(
      total: attemptsCount,
      dates: attemptCreatedDates,
      nowLocal: nowLocal,
      todayStartLocal: todayStartLocal,
      emptyWeekLabel: '0 this week',
    );

    // Compute Active Live Quizzes using the exact same rules as Live Quiz Tab
    int activeLiveCount = 0;
    final liveQuizDates = <DateTime>[];
    for (final r in testRows) {
      if (r['is_tournament'] == true) continue;
      final hasSchedule = r['scheduled_start_time'] != null;
      final isLq = (r['id']?.toString().startsWith('lq-') ?? false);
      final mode = (r['test_mode'] ?? '').toString().toLowerCase();
      final isLiveQuizType = hasSchedule || isLq || mode == 'live_quiz' || mode == 'live';
      if (!isLiveQuizType) continue;

      final statusStr = (r['status'] ?? '').toString().toLowerCase();
      if (statusStr == 'draft') continue;

      final rawStart = r['scheduled_start_time'] != null
          ? DateTime.tryParse(r['scheduled_start_time'].toString())?.toLocal()
          : null;
      final durationMins = (r['duration_minutes'] as num?)?.toInt() ?? 45;
      final rawEnd = r['scheduled_end_time'] != null
          ? DateTime.tryParse(r['scheduled_end_time'].toString())?.toLocal()
          : rawStart?.add(Duration(minutes: durationMins));

      bool isLiveNow = false;
      if (rawStart != null && rawEnd != null) {
        isLiveNow = !nowLocal.isBefore(rawStart) && !nowLocal.isAfter(rawEnd);
      } else if (rawStart != null) {
        isLiveNow = !nowLocal.isBefore(rawStart) && statusStr != 'completed';
      } else {
        isLiveNow = statusStr == 'live' || statusStr == 'active';
      }

      if (isLiveNow) activeLiveCount++;

      final refDate = rawStart ??
          (r['created_at'] != null
              ? DateTime.tryParse(r['created_at'].toString())?.toLocal()
              : null);
      if (refDate != null) liveQuizDates.add(refDate);
    }

    final activeLiveSparkline = _buildSevenDaySparkline(liveQuizDates, todayStartLocal);

    // Build Attempts Line Chart
    final attemptsChart = _buildAttemptsChart(
      dates: attemptCreatedDates,
      startLocal: normalizedAttemptsStart,
      endLocal: normalizedAttemptsEnd,
    );

    // Build User Growth Bar Chart
    final userGrowthChart = _buildUserGrowthChart(
      dates: profileCreatedDates,
      period: userGrowthPeriod,
      todayStartLocal: todayStartLocal,
    );

    // Build Category Wise Quizzes Donut Breakdown
    final categoryBreakdown = _buildCategoryBreakdown(
      testRows: testRows,
      categoryRows: categoryRows,
      examCategoryRows: examCategoryRows,
    );

    // Build Recent Quizzes (top 5)
    final catLookup = _buildCategoryLookup(categoryRows, examCategoryRows);
    final recentQuizzes = testRows.take(5).map((r) {
      final statusStr = (r['status'] ?? 'published').toString().trim();
      final statusLower = statusStr.toLowerCase();
      final statusDisplay = statusStr.isEmpty
          ? 'Published'
          : '${statusStr[0].toUpperCase()}${statusStr.substring(1).toLowerCase()}';
      final subjectLabel = _resolveCategoryLabel(r, catLookup);
      final createdAt = DateTime.tryParse(r['created_at']?.toString() ?? '')?.toLocal() ??
          nowLocal;
      return DashboardRecentQuiz(
        id: r['id']?.toString() ?? '',
        title: r['title']?.toString() ?? 'Untitled Quiz',
        subjectLabel: subjectLabel,
        totalQuestions: (r['total_questions'] as num?)?.toInt() ?? 0,
        status: statusDisplay,
        isPublished: statusLower == 'published',
        createdAt: createdAt,
      );
    }).toList();

    // Build Recent Users (top 5)
    final recentUsers = recentProfileRows.take(5).map((r) {
      final createdAt = DateTime.tryParse(r['created_at']?.toString() ?? '')?.toLocal() ??
          nowLocal;
      return DashboardRecentUser(
        id: r['id']?.toString() ?? '',
        name: (r['name']?.toString().trim().isNotEmpty == true)
            ? r['name'].toString().trim()
            : 'Registered User',
        email: r['email']?.toString() ?? '',
        status: r['status']?.toString() ?? 'active',
        createdAt: createdAt,
      );
    }).toList();

    // Build Real Activity Feed from DB events
    final recentActivities = _buildRecentActivities(
      activityLogRows: activityLogRows,
      recentQuizzes: recentQuizzes,
      recentUsers: recentUsers,
      attemptRows: attemptRows,
      testRows: testRows,
    );

    // Build Genuine System Service Health Checks
    final avgLatency = dbLatencyMs ?? totalStopwatch.elapsedMilliseconds;
    final realtimeState = client.realtime.connState;
    final realtimeStatusLabel = switch (realtimeState) {
      SocketStates.open => 'Connected',
      SocketStates.connecting => 'Connecting',
      _ => 'Standby',
    };

    final services = [
      DashboardSystemService(
        name: 'Database (Profiles)',
        status: dbUsersOk ? 'Operational' : 'Unreachable',
        isHealthy: dbUsersOk,
        latencyMs: dbLatencyMs,
      ),
      DashboardSystemService(
        name: 'Quizzes & Question Bank',
        status: contentOk ? 'Operational' : 'Error',
        isHealthy: contentOk,
        latencyMs: contentLatencyMs,
      ),
      DashboardSystemService(
        name: 'Attempts & Analytics',
        status: attemptsOk ? 'Operational' : 'Error',
        isHealthy: attemptsOk,
        latencyMs: attemptsLatencyMs,
      ),
      DashboardSystemService(
        name: 'App Config Store',
        status: configOk ? 'Operational' : 'Restricted',
        isHealthy: configOk,
      ),
      DashboardSystemService(
        name: 'Notifications Feed',
        status: notificationsOk ? 'Operational' : 'Auth Required',
        isHealthy: notificationsOk || !SupabaseConfig.isInitialized ? notificationsOk : true,
      ),
      DashboardSystemService(
        name: 'Realtime WebSocket',
        status: realtimeStatusLabel,
        isHealthy: true,
      ),
    ];

    return Success(
      AdminDashboardSnapshot(
        usersMetric: usersMetric,
        quizzesMetric: quizzesMetric,
        questionsMetric: questionsMetric,
        attemptsMetric: attemptsMetric,
        activeLiveQuizzesCount: activeLiveCount,
        activeLiveQuizzesSparkline: activeLiveSparkline,
        attemptsChart: attemptsChart,
        userGrowthChart: userGrowthChart,
        totalCategoriesQuizzesCount: testsCount > testRows.length ? testsCount : testRows.length,
        categoryBreakdown: categoryBreakdown,
        recentQuizzes: recentQuizzes,
        recentUsers: recentUsers,
        recentActivities: recentActivities,
        services: services,
        apiLatencyMs: avgLatency,
        fetchedAt: DateTime.now(),
      ),
    );
  }

  /// Load persisted Quick Action toggles from Supabase `app_configs` if present.
  Future<Map<String, bool>?> fetchQuickActionPreferences() async {
    final client = _client;
    if (client == null) return null;
    try {
      final res = await client
          .from('app_configs')
          .select('value')
          .eq('key', 'admin_quick_actions')
          .maybeSingle();
      if (res != null && res['value'] is Map) {
        final raw = Map<String, dynamic>.from(res['value'] as Map);
        return raw.map((k, v) => MapEntry(k, v == true));
      }
    } catch (_) {
      // Optional config key
    }
    return null;
  }

  /// Persist Quick Action toggles to Supabase `app_configs`.
  Future<bool> saveQuickActionPreferences(Map<String, bool> preferences) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('app_configs').upsert({
        'key': 'admin_quick_actions',
        'value': preferences,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Private Aggregation Helpers
  // ---------------------------------------------------------------------------

  List<DateTime> _extractDates(List<dynamic> rows, String field) {
    final result = <DateTime>[];
    for (final row in rows) {
      if (row is Map) {
        final raw = row[field];
        if (raw != null) {
          final parsed = DateTime.tryParse(raw.toString());
          if (parsed != null) result.add(parsed.toLocal());
        }
      }
    }
    return result;
  }

  DateTime _resolveUserGrowthStart(String period, DateTime todayStartLocal) {
    switch (period) {
      case 'Last 30 Days':
        return todayStartLocal.subtract(const Duration(days: 29));
      case 'Last 90 Days':
        return todayStartLocal.subtract(const Duration(days: 89));
      case 'This Year':
        return DateTime(todayStartLocal.year, 1, 1);
      case 'Last 7 Days':
      default:
        return todayStartLocal.subtract(const Duration(days: 6));
    }
  }

  DashboardMetricSummary _buildMetricSummary({
    required int total,
    required List<DateTime> dates,
    required DateTime nowLocal,
    required DateTime todayStartLocal,
    required String emptyWeekLabel,
  }) {
    final sevenDaysAgo = nowLocal.subtract(const Duration(days: 7));
    final fourteenDaysAgo = nowLocal.subtract(const Duration(days: 14));

    int currentWeek = 0;
    int prevWeek = 0;

    for (final dt in dates) {
      if (!dt.isBefore(sevenDaysAgo)) {
        currentWeek++;
      } else if (!dt.isBefore(fourteenDaysAgo)) {
        prevWeek++;
      }
    }

    String growthLabel = '';
    bool isPositive = true;

    if (prevWeek > 0) {
      final pct = (((currentWeek - prevWeek) / prevWeek) * 100).round();
      isPositive = pct >= 0;
      growthLabel = '${pct >= 0 ? '+' : ''}$pct%';
    } else if (currentWeek > 0 && total > 0) {
      final pct = ((currentWeek / total) * 100).round();
      isPositive = true;
      growthLabel = '+$pct%';
    }

    final subtitle = currentWeek > 0 ? '+$currentWeek this week' : emptyWeekLabel;
    final sparkline = _buildSevenDaySparkline(dates, todayStartLocal);

    return DashboardMetricSummary(
      total: total,
      currentWeekCount: currentWeek,
      previousWeekCount: prevWeek,
      growthLabel: growthLabel,
      isGrowthPositive: isPositive,
      subtitle: subtitle,
      sparklineData: sparkline,
    );
  }

  List<double> _buildSevenDaySparkline(List<DateTime> dates, DateTime todayStartLocal) {
    final buckets = List<double>.filled(7, 0);
    for (final dt in dates) {
      final dayOnly = DateTime(dt.year, dt.month, dt.day);
      final diff = todayStartLocal.difference(dayOnly).inDays;
      if (diff >= 0 && diff < 7) {
        final idx = 6 - diff;
        buckets[idx] += 1;
      }
    }
    return buckets;
  }

  DashboardSeriesData _buildAttemptsChart({
    required List<DateTime> dates,
    required DateTime startLocal,
    required DateTime endLocal,
  }) {
    final safeEnd = endLocal.isBefore(startLocal) ? startLocal : endLocal;
    final totalDays = safeEnd.difference(startLocal).inDays + 1;

    final labels = <String>[];
    final values = <double>[];
    final bucketStarts = <DateTime>[];

    if (totalDays <= 10) {
      for (int i = 0; i < totalDays; i++) {
        final day = startLocal.add(Duration(days: i));
        final nextDay = day.add(const Duration(days: 1));
        final count = dates.where((d) => !d.isBefore(day) && d.isBefore(nextDay)).length;
        labels.add(_formatShortDate(day));
        values.add(count.toDouble());
        bucketStarts.add(day);
      }
    } else if (totalDays <= 90) {
      const targetBuckets = 7;
      final stepDays = (totalDays / targetBuckets).ceil();
      DateTime cursor = startLocal;
      while (!cursor.isAfter(safeEnd)) {
        final next = cursor.add(Duration(days: stepDays));
        final clampedEnd = next.isAfter(safeEnd.add(const Duration(days: 1)))
            ? safeEnd.add(const Duration(days: 1))
            : next;
        final count = dates.where((d) => !d.isBefore(cursor) && d.isBefore(clampedEnd)).length;
        labels.add(_formatShortDate(cursor));
        values.add(count.toDouble());
        bucketStarts.add(cursor);
        cursor = next;
      }
    } else {
      DateTime cursor = DateTime(startLocal.year, startLocal.month, 1);
      final endMonth = DateTime(safeEnd.year, safeEnd.month, 1);
      while (!cursor.isAfter(endMonth)) {
        final nextMonth = DateTime(cursor.year, cursor.month + 1, 1);
        final count = dates.where((d) => !d.isBefore(cursor) && d.isBefore(nextMonth)).length;
        labels.add('${_months[cursor.month - 1]} ${cursor.year.toString().substring(2)}');
        values.add(count.toDouble());
        bucketStarts.add(cursor);
        cursor = nextMonth;
      }
    }

    int? peakIdx;
    double peakVal = -1;
    for (int i = 0; i < values.length; i++) {
      if (values[i] > peakVal) {
        peakVal = values[i];
        peakIdx = i;
      }
    }

    if (peakVal <= 0) {
      peakIdx = null;
    }

    return DashboardSeriesData(
      labels: labels,
      values: values,
      highlightedIndex: peakIdx,
      tooltipDate: peakIdx != null ? _formatFullDate(bucketStarts[peakIdx]) : null,
      tooltipValue: peakIdx != null ? '${_formatCount(peakVal.round())} attempts' : null,
    );
  }

  DashboardSeriesData _buildUserGrowthChart({
    required List<DateTime> dates,
    required String period,
    required DateTime todayStartLocal,
  }) {
    final labels = <String>[];
    final values = <double>[];

    switch (period) {
      case 'Last 30 Days':
        final start = todayStartLocal.subtract(const Duration(days: 29));
        for (int i = 0; i < 6; i++) {
          final bStart = start.add(Duration(days: i * 5));
          final bEnd = bStart.add(const Duration(days: 5));
          final count = dates.where((d) => !d.isBefore(bStart) && d.isBefore(bEnd)).length;
          labels.add(_formatShortDate(bStart));
          values.add(count.toDouble());
        }
        break;
      case 'Last 90 Days':
        final start = todayStartLocal.subtract(const Duration(days: 89));
        for (int i = 0; i < 6; i++) {
          final bStart = start.add(Duration(days: i * 15));
          final bEnd = bStart.add(const Duration(days: 15));
          final count = dates.where((d) => !d.isBefore(bStart) && d.isBefore(bEnd)).length;
          labels.add(_formatShortDate(bStart));
          values.add(count.toDouble());
        }
        break;
      case 'This Year':
        final monthCount = todayStartLocal.month;
        for (int m = 1; m <= monthCount; m++) {
          final mStart = DateTime(todayStartLocal.year, m, 1);
          final mEnd = DateTime(todayStartLocal.year, m + 1, 1);
          final count = dates.where((d) => !d.isBefore(mStart) && d.isBefore(mEnd)).length;
          labels.add(_months[m - 1]);
          values.add(count.toDouble());
        }
        break;
      case 'Last 7 Days':
      default:
        for (int i = 6; i >= 0; i--) {
          final day = todayStartLocal.subtract(Duration(days: i));
          final next = day.add(const Duration(days: 1));
          final count = dates.where((d) => !d.isBefore(day) && d.isBefore(next)).length;
          labels.add(_formatShortDate(day));
          values.add(count.toDouble());
        }
        break;
    }

    return DashboardSeriesData(labels: labels, values: values);
  }

  Map<String, _CategoryMeta> _buildCategoryLookup(
    List<Map<String, dynamic>> categoryRows,
    List<Map<String, dynamic>> examCategoryRows,
  ) {
    final map = <String, _CategoryMeta>{};
    for (final c in categoryRows) {
      final id = c['id']?.toString().trim() ?? '';
      final name = c['name']?.toString().trim() ?? '';
      final color = c['icon_color']?.toString().trim();
      if (id.isNotEmpty && name.isNotEmpty) {
        map[id.toLowerCase()] = _CategoryMeta(name: name, hexColor: color);
      }
      if (name.isNotEmpty) {
        map[name.toLowerCase()] = _CategoryMeta(name: name, hexColor: color);
      }
    }
    for (final e in examCategoryRows) {
      final id = e['id']?.toString().trim() ?? '';
      final name = e['name']?.toString().trim() ?? '';
      if (id.isNotEmpty && name.isNotEmpty && !map.containsKey(id.toLowerCase())) {
        map[id.toLowerCase()] = _CategoryMeta(name: name, hexColor: null);
      }
    }
    return map;
  }

  String _resolveCategoryLabel(
    Map<String, dynamic> testRow,
    Map<String, _CategoryMeta> lookup,
  ) {
    final catCol = testRow['category']?.toString().trim() ?? '';
    final catIdCol = testRow['category_id']?.toString().trim() ?? '';
    final examIdCol = testRow['exam_category_id']?.toString().trim() ?? '';

    for (final key in [catIdCol, catCol, examIdCol]) {
      if (key.isEmpty) continue;
      final meta = lookup[key.toLowerCase()];
      if (meta != null) return meta.name;
    }

    if (catCol.isNotEmpty) return catCol;
    if (catIdCol.isNotEmpty) return catIdCol;
    if (examIdCol.isNotEmpty) return examIdCol.toUpperCase();
    return 'Uncategorized';
  }

  List<DashboardCategoryBreakdown> _buildCategoryBreakdown({
    required List<Map<String, dynamic>> testRows,
    required List<Map<String, dynamic>> categoryRows,
    required List<Map<String, dynamic>> examCategoryRows,
  }) {
    if (testRows.isEmpty) return [];

    final lookup = _buildCategoryLookup(categoryRows, examCategoryRows);
    final counts = <String, int>{};

    for (final row in testRows) {
      final label = _resolveCategoryLabel(row, lookup);
      counts[label] = (counts[label] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = testRows.length;
    final top = sorted.take(5).toList();
    final remainder = sorted.skip(5).fold<int>(0, (sum, e) => sum + e.value);

    final result = <DashboardCategoryBreakdown>[];
    for (final entry in top) {
      final meta = lookup[entry.key.toLowerCase()];
      result.add(
        DashboardCategoryBreakdown(
          label: entry.key,
          count: entry.value,
          percentage: (entry.value / total) * 100,
          hexColor: meta?.hexColor,
        ),
      );
    }

    if (remainder > 0) {
      result.add(
        DashboardCategoryBreakdown(
          label: 'Others',
          count: remainder,
          percentage: (remainder / total) * 100,
          hexColor: '#94A3B8',
        ),
      );
    }

    return result;
  }

  List<DashboardActivityEvent> _buildRecentActivities({
    required List<Map<String, dynamic>> activityLogRows,
    required List<DashboardRecentQuiz> recentQuizzes,
    required List<DashboardRecentUser> recentUsers,
    required List<Map<String, dynamic>> attemptRows,
    required List<Map<String, dynamic>> testRows,
  }) {
    final events = <DashboardActivityEvent>[];

    for (final log in activityLogRows) {
      final desc = log['description']?.toString().trim() ?? '';
      final created = DateTime.tryParse(log['created_at']?.toString() ?? '')?.toLocal();
      if (desc.isNotEmpty && created != null) {
        events.add(
          DashboardActivityEvent(
            id: 'log_${log['id'] ?? created.millisecondsSinceEpoch}',
            type: DashboardActivityType.userActivity,
            title: desc,
            createdAt: created,
          ),
        );
      }
    }

    for (final q in recentQuizzes) {
      events.add(
        DashboardActivityEvent(
          id: 'quiz_${q.id}',
          type: q.subjectLabel.toLowerCase().contains('live')
              ? DashboardActivityType.liveQuiz
              : DashboardActivityType.quizCreated,
          title: 'Quiz: ${q.title}',
          createdAt: q.createdAt,
        ),
      );
    }

    for (final u in recentUsers) {
      events.add(
        DashboardActivityEvent(
          id: 'user_${u.id}',
          type: DashboardActivityType.userRegistered,
          title: 'User registered: ${u.name}',
          createdAt: u.createdAt,
        ),
      );
    }

    final testTitleMap = <String, String>{};
    for (final t in testRows) {
      final tid = t['id']?.toString() ?? '';
      final title = t['title']?.toString() ?? '';
      if (tid.isNotEmpty && title.isNotEmpty) {
        testTitleMap[tid] = title;
      }
    }

    for (final a in attemptRows.take(5)) {
      final created = DateTime.tryParse(a['created_at']?.toString() ?? '')?.toLocal();
      if (created != null) {
        final testTitle = testTitleMap[a['test_id']?.toString() ?? ''] ?? 'Quiz';
        final score = a['score'];
        final scoreStr = score != null ? ' (Score: $score)' : '';
        events.add(
          DashboardActivityEvent(
            id: 'attempt_${a['id'] ?? created.millisecondsSinceEpoch}',
            type: DashboardActivityType.attemptCompleted,
            title: 'Attempt submitted: $testTitle$scoreStr',
            createdAt: created,
          ),
        );
      }
    }

    events.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final seenTitles = <String>{};
    final deduped = <DashboardActivityEvent>[];
    for (final ev in events) {
      if (seenTitles.add(ev.title)) {
        deduped.add(ev);
        if (deduped.length >= math.min(6, events.length)) break;
      }
    }
    return deduped;
  }

  String _formatShortDate(DateTime dt) =>
      '${_months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}';

  String _formatFullDate(DateTime dt) =>
      '${_months[dt.month - 1]} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';

  String _formatCount(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class _CategoryMeta {
  final String name;
  final String? hexColor;

  const _CategoryMeta({required this.name, this.hexColor});
}

