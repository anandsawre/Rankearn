import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'widgets/feedback_hero_card.dart';
import 'widgets/feedback_quick_actions.dart';
import 'widgets/feedback_kpi_row.dart';
import 'widgets/feedback_filter_panel.dart';
import 'widgets/feedback_data_table.dart';
import 'widgets/feedback_analytics_panel.dart';
import 'dialogs/feedback_detail_dialog.dart';
import 'dialogs/reply_feedback_dialog.dart';

class FeedbackTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialFeedbacks;
  const FeedbackTab({super.key, this.initialFeedbacks});

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = true;

  // Filters
  final _searchController = TextEditingController();
  String _selectedRating = 'all';
  String _selectedType = 'all';
  String _selectedSentiment = 'all';
  String _selectedFeature = 'all';
  String _selectedDateRange = '30days';
  String _activeTab = 'all';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialFeedbacks != null) {
      _feedbacks = List.from(widget.initialFeedbacks!);
      _isLoading = false;
    } else {
      _fetchFeedbacks();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFeedbacks() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() {
          _feedbacks = [];
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final res = await client.from('feedbacks').select().order('created_at', ascending: false);
      if (mounted) {
        final list = (res as List).map((row) {
          final ratingVal = row['rating'];
          final int parsedRating = (ratingVal is num) ? ratingVal.toInt() : 5;

          return {
            'id': row['id']?.toString() ?? '',
            'userId': row['user_id']?.toString(),
            'name': row['user_name']?.toString() ?? 'Candidate',
            'uid': 'UID: ${row['id']?.toString().substring(0, 6) ?? 'RK100'}',
            'email': row['user_email']?.toString() ?? 'user@rankearn.com',
            'rating': parsedRating,
            'date': row['created_at'] != null ? row['created_at'].toString().split('T').first : 'Recent',
            'comment': row['comment']?.toString() ?? '',
            'type': row['type']?.toString() ?? 'Feedback',
            'feature': row['feature']?.toString() ?? 'Platform',
          };
        }).toList();

        setState(() {
          _feedbacks = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _feedbacks = [];
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredFeedbacks() {
    return _feedbacks.where((f) {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final name = (f['name'] ?? '').toString().toLowerCase();
        final uid = (f['uid'] ?? '').toString().toLowerCase();
        final comment = (f['comment'] ?? '').toString().toLowerCase();
        if (!name.contains(query) && !uid.contains(query) && !comment.contains(query)) {
          return false;
        }
      }

      final rating = (f['rating'] as num?)?.toInt() ?? 5;
      if (_selectedRating != 'all' && rating.toString() != _selectedRating) {
        return false;
      }

      final type = (f['type'] ?? '').toString().toLowerCase();
      if (_selectedType != 'all' && !type.contains(_selectedType.toLowerCase())) {
        return false;
      }

      if (_selectedSentiment != 'all') {
        if (_selectedSentiment == 'positive' && rating < 4) return false;
        if (_selectedSentiment == 'neutral' && rating != 3) return false;
        if (_selectedSentiment == 'negative' && rating > 2) return false;
      }

      final feature = (f['feature'] ?? '').toString().toLowerCase();
      if (_selectedFeature != 'all' && !feature.contains(_selectedFeature.toLowerCase())) {
        return false;
      }

      // Tab filters
      if (_activeTab == 'positive' && rating < 4) return false;
      if (_activeTab == 'neutral' && rating != 3) return false;
      if (_activeTab == 'negative' && rating > 2) return false;

      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedRating = 'all';
      _selectedType = 'all';
      _selectedSentiment = 'all';
      _selectedFeature = 'all';
      _selectedDateRange = '30days';
      _activeTab = 'all';
    });
  }

  void _showViewFeedbackDialog(Map<String, dynamic> feedback) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => FeedbackDetailDialog(
        feedback: feedback,
        onReply: () => _showReplyDialog(feedback),
      ),
    );
  }

  void _showReplyDialog(Map<String, dynamic> feedback) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => ReplyFeedbackDialog(
        feedback: feedback,
        onSendReply: (msg) {
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            client.from('notifications').insert({
              'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
              'user_id': feedback['userId'] ?? feedback['id'] ?? 'global',
              'title': 'Response to Your Feedback',
              'message': msg,
              'type': 'feedback_reply',
              'created_at': DateTime.now().toIso8601String(),
            }).then((_) {});
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Response notification sent to ${feedback['name']}!')),
          );
        },
      ),
    );
  }

  void _exportFeedbackCsv() {
    final buffer = StringBuffer('ID,User Name,Rating,Comment,Date\n');
    for (final f in _feedbacks) {
      final commentSafe = (f['comment'] ?? '').toString().replaceAll('"', '""');
      buffer.writeln('${f['id']},${f['name']},${f['rating']},"$commentSafe",${f['date']}');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📥 Exported ${_feedbacks.length} feedback records to clipboard as CSV!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: AppColors.adminPurple),
        ),
      );
    }

    final totalCount = _feedbacks.length;
    final double avgRating = totalCount > 0
        ? _feedbacks.fold<int>(0, (sum, f) => sum + ((f['rating'] as int?) ?? 0)) / totalCount
        : 0.0;
    final positiveCount = _feedbacks.where((f) => ((f['rating'] as int?) ?? 0) >= 4).length;
    final neutralCount = _feedbacks.where((f) => ((f['rating'] as int?) ?? 0) == 3).length;
    final negativeCount = _feedbacks.where((f) => ((f['rating'] as int?) ?? 0) <= 2).length;

    final ratingCounts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final f in _feedbacks) {
      final r = (f['rating'] as int?) ?? 5;
      if (r >= 1 && r <= 5) {
        ratingCounts[r] = (ratingCounts[r] ?? 0) + 1;
      }
    }

    final filteredList = _getFilteredFeedbacks();

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Banner (Left) + Quick Actions (Right)
          LayoutBuilder(
            builder: (context, constraints) {
              final heroCard = FeedbackHeroCard(
                onRefresh: _fetchFeedbacks,
              );
              final quickActions = FeedbackQuickActions(
                onReplyFeedback: () {
                  final list = _getFilteredFeedbacks();
                  if (list.isNotEmpty) {
                    _showReplyDialog(list.first);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No feedback selected to reply to')),
                    );
                  }
                },
                onFilterPositive: () {
                  setState(() {
                    _selectedSentiment = 'positive';
                    _activeTab = 'positive';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filtered to positive feedbacks')),
                  );
                },
                onFilterIssues: () {
                  setState(() {
                    _selectedType = 'issue';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filtered to bug reports & issues')),
                  );
                },
                onExportCsv: _exportFeedbackCsv,
                onManageRatings: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Platform Rating: 5-star student review system active.')),
                  );
                },
              );

              if (constraints.maxWidth > 980) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 58,
                      child: heroCard,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 42,
                      child: quickActions,
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    heroCard,
                    const SizedBox(height: 16),
                    quickActions,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 18),

          // 2. 5 KPI Cards Row
          FeedbackKpiRow(
            averageRating: avgRating,
            totalCount: totalCount,
            positiveCount: positiveCount,
            neutralCount: neutralCount,
            negativeCount: negativeCount,
          ),
          const SizedBox(height: 20),

          // 3. 3-Panel Layout (Left Filter, Center Table, Right Analytics)
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1150;
              final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1150;

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Filter Panel (260px)
                    SizedBox(
                      width: 260,
                      child: FeedbackFilterPanel(
                        searchController: _searchController,
                        selectedRating: _selectedRating,
                        selectedType: _selectedType,
                        selectedSentiment: _selectedSentiment,
                        selectedFeature: _selectedFeature,
                        selectedDateRange: _selectedDateRange,
                        onRatingChanged: (v) {
                          if (v != null) setState(() => _selectedRating = v);
                        },
                        onTypeChanged: (v) {
                          if (v != null) setState(() => _selectedType = v);
                        },
                        onSentimentChanged: (v) {
                          if (v != null) setState(() => _selectedSentiment = v);
                        },
                        onFeatureChanged: (v) {
                          if (v != null) setState(() => _selectedFeature = v);
                        },
                        onDateRangeChanged: (v) {
                          if (v != null) setState(() => _selectedDateRange = v);
                        },
                        onApplyFilters: () => setState(() {}),
                        onReset: _resetFilters,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Center: Data Table (Expanded)
                    Expanded(
                      child: FeedbackDataTable(
                        feedbacks: filteredList,
                        activeTab: _activeTab,
                        onTabChanged: (tab) => setState(() => _activeTab = tab),
                        onViewFeedback: _showViewFeedbackDialog,
                        onReplyFeedback: _showReplyDialog,
                        currentPage: _currentPage,
                        totalCount: totalCount,
                        onPageChanged: (p) => setState(() => _currentPage = p),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right: Analytics Panel (290px)
                    SizedBox(
                      width: 290,
                      child: FeedbackAnalyticsPanel(
                        totalCount: totalCount,
                        positiveCount: positiveCount,
                        neutralCount: neutralCount,
                        negativeCount: negativeCount,
                        ratingCounts: ratingCounts,
                        onReplyAll: () {
                          if (filteredList.isNotEmpty) {
                            _showReplyDialog(filteredList.first);
                          }
                        },
                        onManageRatings: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Rating & Review policies active.')),
                          );
                        },
                        onExportCsv: _exportFeedbackCsv,
                      ),
                    ),
                  ],
                );
              } else if (isTablet) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 250,
                          child: FeedbackFilterPanel(
                            searchController: _searchController,
                            selectedRating: _selectedRating,
                            selectedType: _selectedType,
                            selectedSentiment: _selectedSentiment,
                            selectedFeature: _selectedFeature,
                            selectedDateRange: _selectedDateRange,
                            onRatingChanged: (v) {
                              if (v != null) setState(() => _selectedRating = v);
                            },
                            onTypeChanged: (v) {
                              if (v != null) setState(() => _selectedType = v);
                            },
                            onSentimentChanged: (v) {
                              if (v != null) setState(() => _selectedSentiment = v);
                            },
                            onFeatureChanged: (v) {
                              if (v != null) setState(() => _selectedFeature = v);
                            },
                            onDateRangeChanged: (v) {
                              if (v != null) setState(() => _selectedDateRange = v);
                            },
                            onApplyFilters: () => setState(() {}),
                            onReset: _resetFilters,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FeedbackAnalyticsPanel(
                            totalCount: totalCount,
                            positiveCount: positiveCount,
                            neutralCount: neutralCount,
                            negativeCount: negativeCount,
                            ratingCounts: ratingCounts,
                            onReplyAll: () {},
                            onManageRatings: () {},
                            onExportCsv: _exportFeedbackCsv,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FeedbackDataTable(
                      feedbacks: filteredList,
                      activeTab: _activeTab,
                      onTabChanged: (tab) => setState(() => _activeTab = tab),
                      onViewFeedback: _showViewFeedbackDialog,
                      onReplyFeedback: _showReplyDialog,
                      currentPage: _currentPage,
                      totalCount: totalCount,
                      onPageChanged: (p) => setState(() => _currentPage = p),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    FeedbackFilterPanel(
                      searchController: _searchController,
                      selectedRating: _selectedRating,
                      selectedType: _selectedType,
                      selectedSentiment: _selectedSentiment,
                      selectedFeature: _selectedFeature,
                      selectedDateRange: _selectedDateRange,
                      onRatingChanged: (v) {
                        if (v != null) setState(() => _selectedRating = v);
                      },
                      onTypeChanged: (v) {
                        if (v != null) setState(() => _selectedType = v);
                      },
                      onSentimentChanged: (v) {
                        if (v != null) setState(() => _selectedSentiment = v);
                      },
                      onFeatureChanged: (v) {
                        if (v != null) setState(() => _selectedFeature = v);
                      },
                      onDateRangeChanged: (v) {
                        if (v != null) setState(() => _selectedDateRange = v);
                      },
                      onApplyFilters: () => setState(() {}),
                      onReset: _resetFilters,
                    ),
                    const SizedBox(height: 16),
                    FeedbackDataTable(
                      feedbacks: filteredList,
                      activeTab: _activeTab,
                      onTabChanged: (tab) => setState(() => _activeTab = tab),
                      onViewFeedback: _showViewFeedbackDialog,
                      onReplyFeedback: _showReplyDialog,
                      currentPage: _currentPage,
                      totalCount: totalCount,
                      onPageChanged: (p) => setState(() => _currentPage = p),
                    ),
                    const SizedBox(height: 16),
                    FeedbackAnalyticsPanel(
                      totalCount: totalCount,
                      positiveCount: positiveCount,
                      neutralCount: neutralCount,
                      negativeCount: negativeCount,
                      ratingCounts: ratingCounts,
                      onReplyAll: () {},
                      onManageRatings: () {},
                      onExportCsv: _exportFeedbackCsv,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
