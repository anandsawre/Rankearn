/// Domain models representing live production metrics and analytics
/// for the Rankearn Admin Dashboard Overview tab.
library;

class DashboardMetricSummary {
  final int total;
  final int currentWeekCount;
  final int previousWeekCount;
  final String growthLabel;
  final bool isGrowthPositive;
  final String subtitle;
  final List<double> sparklineData;

  const DashboardMetricSummary({
    required this.total,
    required this.currentWeekCount,
    required this.previousWeekCount,
    required this.growthLabel,
    required this.isGrowthPositive,
    required this.subtitle,
    required this.sparklineData,
  });
}

class DashboardSeriesData {
  final List<String> labels;
  final List<double> values;
  final int? highlightedIndex;
  final String? tooltipDate;
  final String? tooltipValue;

  const DashboardSeriesData({
    required this.labels,
    required this.values,
    this.highlightedIndex,
    this.tooltipDate,
    this.tooltipValue,
  });
}

class DashboardCategoryBreakdown {
  final String label;
  final int count;
  final double percentage;
  final String? hexColor;

  const DashboardCategoryBreakdown({
    required this.label,
    required this.count,
    required this.percentage,
    this.hexColor,
  });
}

class DashboardRecentQuiz {
  final String id;
  final String title;
  final String subjectLabel;
  final int totalQuestions;
  final String status;
  final bool isPublished;
  final DateTime createdAt;

  const DashboardRecentQuiz({
    required this.id,
    required this.title,
    required this.subjectLabel,
    required this.totalQuestions,
    required this.status,
    required this.isPublished,
    required this.createdAt,
  });
}

class DashboardRecentUser {
  final String id;
  final String name;
  final String email;
  final String status;
  final DateTime createdAt;

  const DashboardRecentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.createdAt,
  });
}

enum DashboardActivityType {
  quizCreated,
  userRegistered,
  attemptCompleted,
  liveQuiz,
  topupRequest,
  withdrawalRequest,
  userActivity,
}

class DashboardActivityEvent {
  final String id;
  final DashboardActivityType type;
  final String title;
  final DateTime createdAt;

  const DashboardActivityEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt,
  });
}

class DashboardSystemService {
  final String name;
  final String status;
  final bool isHealthy;
  final int? latencyMs;

  const DashboardSystemService({
    required this.name,
    required this.status,
    required this.isHealthy,
    this.latencyMs,
  });
}

class AdminDashboardSnapshot {
  final DashboardMetricSummary usersMetric;
  final DashboardMetricSummary quizzesMetric;
  final DashboardMetricSummary questionsMetric;
  final DashboardMetricSummary attemptsMetric;
  final int activeLiveQuizzesCount;
  final List<double> activeLiveQuizzesSparkline;
  final DashboardSeriesData attemptsChart;
  final DashboardSeriesData userGrowthChart;
  final int totalCategoriesQuizzesCount;
  final List<DashboardCategoryBreakdown> categoryBreakdown;
  final List<DashboardRecentQuiz> recentQuizzes;
  final List<DashboardRecentUser> recentUsers;
  final List<DashboardActivityEvent> recentActivities;
  final List<DashboardSystemService> services;
  final int apiLatencyMs;
  final DateTime fetchedAt;

  const AdminDashboardSnapshot({
    required this.usersMetric,
    required this.quizzesMetric,
    required this.questionsMetric,
    required this.attemptsMetric,
    required this.activeLiveQuizzesCount,
    required this.activeLiveQuizzesSparkline,
    required this.attemptsChart,
    required this.userGrowthChart,
    required this.totalCategoriesQuizzesCount,
    required this.categoryBreakdown,
    required this.recentQuizzes,
    required this.recentUsers,
    required this.recentActivities,
    required this.services,
    required this.apiLatencyMs,
    required this.fetchedAt,
  });

  bool get isAllOperational =>
      services.isNotEmpty && services.every((s) => s.isHealthy);
}

