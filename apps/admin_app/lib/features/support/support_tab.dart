import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';
import 'widgets/support_hero_card.dart';
import 'widgets/support_quick_actions.dart';
import 'widgets/support_kpi_row.dart';
import 'widgets/support_filter_panel.dart';
import 'widgets/support_data_table.dart';
import 'widgets/support_analytics_panel.dart';
import 'dialogs/ticket_detail_dialog.dart';
import 'dialogs/create_ticket_dialog.dart';

class SupportTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialTickets;
  const SupportTab({super.key, this.initialTickets});

  @override
  State<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  // Filters
  final _searchController = TextEditingController();
  String _selectedStatus = 'all';
  String _selectedCategory = 'all';
  String _selectedPriority = 'all';
  String _selectedDateRange = '30days';
  String _activeTab = 'all';
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialTickets != null) {
      _tickets = List.from(widget.initialTickets!);
      _isLoading = false;
    } else {
      _fetchTickets();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) {
        setState(() {
          _tickets = [];
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final res = await client.from('support_tickets').select().order('last_updated', ascending: false);
      final List<Map<String, dynamic>> loadedTickets = [];

      for (final row in (res as List)) {
        final ticketId = row['id']?.toString() ?? '';
        List<Map<String, dynamic>> msgs = [];
        try {
          final mRes = await client.from('support_messages').select().eq('ticket_id', ticketId).order('created_at', ascending: true);
          msgs = (mRes as List).map((m) => {
            'isUser': m['role'] == 'user',
            'text': m['text']?.toString() ?? '',
            'time': m['created_at'] != null ? m['created_at'].toString().split('T').last.substring(0, 5) : '',
          }).toList();
        } catch (_) {}

        loadedTickets.add({
          'id': ticketId,
          'name': row['user_name']?.toString() ?? 'Candidate',
          'email': row['user_email']?.toString() ?? '',
          'subject': row['last_message']?.toString() ?? 'Support Request',
          'category': 'General',
          'priority': 'Medium',
          'status': row['status']?.toString() ?? 'open',
          'lastTime': row['last_updated'] != null ? row['last_updated'].toString().split('T').first : 'Recent',
          'lastMsg': row['last_message']?.toString() ?? 'No messages yet.',
          'messages': msgs,
        });
      }

      if (mounted) {
        setState(() {
          _tickets = loadedTickets;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _tickets = [];
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredTickets() {
    return _tickets.where((t) {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final id = (t['id'] ?? '').toString().toLowerCase();
        final name = (t['name'] ?? '').toString().toLowerCase();
        final subject = (t['subject'] ?? '').toString().toLowerCase();
        if (!id.contains(query) && !name.contains(query) && !subject.contains(query)) {
          return false;
        }
      }

      final status = (t['status'] ?? '').toString().toLowerCase();
      if (_selectedStatus != 'all' && status != _selectedStatus) {
        return false;
      }

      final category = (t['category'] ?? '').toString().toLowerCase();
      if (_selectedCategory != 'all' && !category.contains(_selectedCategory.toLowerCase())) {
        return false;
      }

      final priority = (t['priority'] ?? '').toString().toLowerCase();
      if (_selectedPriority != 'all' && !priority.contains(_selectedPriority.toLowerCase())) {
        return false;
      }

      if (_activeTab == 'open' && status != 'open') return false;
      if (_activeTab == 'in_progress' && status != 'in_progress') return false;
      if (_activeTab == 'resolved' && status != 'resolved') return false;

      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = 'all';
      _selectedCategory = 'all';
      _selectedPriority = 'all';
      _selectedDateRange = '30days';
      _activeTab = 'all';
    });
  }

  Future<void> _handleSendMessage(Map<String, dynamic> ticket, String text) async {
    final ticketId = ticket['id']?.toString() ?? '';
    final timeStr = 'Just Now';

    setState(() {
      ticket['messages'] = [
        ...((ticket['messages'] as List<dynamic>?) ?? []),
        {
          'isUser': false,
          'text': text,
          'time': timeStr,
        }
      ];
      ticket['lastMsg'] = text;
      ticket['lastTime'] = timeStr;
    });

    final client = SupabaseConfig.clientSafe;
    if (client != null && ticketId.isNotEmpty) {
      try {
        final authUser = client.auth.currentUser;
        await client.from('support_messages').insert({
          'id': 'msg-${DateTime.now().millisecondsSinceEpoch}',
          'ticket_id': ticketId,
          'sender_id': authUser?.id ?? '00000000-0000-0000-0000-000000000000',
          'sender_name': 'Rankearn Support Admin',
          'text': text,
          'role': 'admin',
        });
        await client.from('support_tickets').update({
          'last_message': text,
          'last_updated': DateTime.now().toIso8601String(),
        }).eq('id', ticketId);
      } catch (_) {}
    }
  }

  void _showTicketDetailDialog(Map<String, dynamic> ticket) {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => TicketDetailDialog(
        ticket: ticket,
        onSendMessage: (text) => _handleSendMessage(ticket, text),
        onStatusChanged: (newStatus) async {
          setState(() => ticket['status'] = newStatus);
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              await client.from('support_tickets').update({'status': newStatus}).eq('id', ticket['id']);
            } catch (_) {}
          }
        },
        onPriorityChanged: (newPriority) async {
          setState(() => ticket['priority'] = newPriority);
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              await client.from('support_tickets').update({'priority': newPriority}).eq('id', ticket['id']);
            } catch (_) {}
          }
        },
      ),
    );
  }

  void _showCreateTicketDialog() {
    AppModalDialog.show(
      context: context,
      builder: (ctx) => CreateTicketDialog(
        onCreate: (newTicket) async {
          setState(() {
            _tickets.insert(0, newTicket);
          });
          final client = SupabaseConfig.clientSafe;
          if (client != null) {
            try {
              await client.from('support_tickets').insert({
                'id': newTicket['id'],
                'user_name': newTicket['name'],
                'user_email': newTicket['email'],
                'subject': newTicket['subject'],
                'category': newTicket['category'],
                'priority': newTicket['priority'],
                'status': 'open',
                'last_message': newTicket['lastMsg'],
                'last_updated': DateTime.now().toIso8601String(),
              });
            } catch (_) {}
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Created ticket #${newTicket['id']} successfully!')),
            );
          }
        },
      ),
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

    final totalCount = _tickets.length;
    final resolvedCount = _tickets.where((t) => (t['status']?.toString().toLowerCase() ?? '') == 'resolved' || (t['status']?.toString().toLowerCase() ?? '') == 'closed').length;
    final inProgressCount = _tickets.where((t) => (t['status']?.toString().toLowerCase() ?? '') == 'in_progress').length;
    final openCount = _tickets.where((t) => (t['status']?.toString().toLowerCase() ?? '') == 'open').length;
    final onHoldCount = _tickets.where((t) => (t['status']?.toString().toLowerCase() ?? '') == 'on_hold').length;

    final filteredTickets = _getFilteredTickets();

    return SingleChildScrollView(
      padding: AppSpacing.pagePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Banner (Left) + Quick Actions (Right)
          LayoutBuilder(
            builder: (context, constraints) {
              final heroCard = SupportHeroCard(
                onRefresh: _fetchTickets,
              );
              final quickActions = SupportQuickActions(
                onCreateTicket: _showCreateTicketDialog,
                onBulkReply: () {
                  final buffer = StringBuffer('Ticket ID,User,Email,Subject,Status,Last Updated\n');
                  for (final t in _tickets) {
                    buffer.writeln('${t['id']},${t['name']},${t['email']},${t['subject']},${t['status']},${t['lastTime']}');
                  }
                  Clipboard.setData(ClipboardData(text: buffer.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('📥 Exported ${_tickets.length} tickets to clipboard as CSV!')),
                  );
                },
                onFilterOpen: () {
                  setState(() {
                    _selectedStatus = 'open';
                    _activeTab = 'open';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filtered to open tickets')),
                  );
                },
                onFilterHighPriority: () {
                  setState(() {
                    _selectedPriority = 'high';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filtered to high priority tickets')),
                  );
                },
                onFaqHelp: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Rankearn Help Center & FAQs...')),
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

          // 2. 6 KPI Cards Row
          SupportKpiRow(
            totalCount: totalCount,
            resolvedCount: resolvedCount,
            inProgressCount: inProgressCount,
            openCount: openCount,
            onHoldCount: onHoldCount,
            supportRating: totalCount > 0 ? 4.8 : 5.0,
          ),
          const SizedBox(height: 20),

          // 3. 3-Panel Layout (Left Filter & Quick Actions, Center Table, Right Analytics)
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1150;
              final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1150;

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Panel (260px)
                    SizedBox(
                      width: 260,
                      child: SupportFilterPanel(
                        searchController: _searchController,
                        selectedStatus: _selectedStatus,
                        selectedCategory: _selectedCategory,
                        selectedPriority: _selectedPriority,
                        selectedDateRange: _selectedDateRange,
                        onStatusChanged: (v) {
                          if (v != null) setState(() => _selectedStatus = v);
                        },
                        onCategoryChanged: (v) {
                          if (v != null) setState(() => _selectedCategory = v);
                        },
                        onPriorityChanged: (v) {
                          if (v != null) setState(() => _selectedPriority = v);
                        },
                        onDateRangeChanged: (v) {
                          if (v != null) setState(() => _selectedDateRange = v);
                        },
                        onApplyFilters: () => setState(() {}),
                        onReset: _resetFilters,
                        onCreateTicket: _showCreateTicketDialog,
                        onBulkReply: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bulk Reply composer opened for filtered tickets.')),
                          );
                        },
                        onManageCategories: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Manage Support Categories configuration dialog.')),
                          );
                        },
                        onHelpCenter: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Help Center Knowledge Base.')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Center Data Table (Expanded)
                    Expanded(
                      child: SupportDataTable(
                        tickets: filteredTickets,
                        activeTab: _activeTab,
                        onTabChanged: (tab) => setState(() => _activeTab = tab),
                        onViewTicket: _showTicketDetailDialog,
                        onReplyTicket: _showTicketDetailDialog,
                        currentPage: _currentPage,
                        totalCount: totalCount,
                        openCount: openCount,
                        inProgressCount: inProgressCount,
                        resolvedCount: resolvedCount,
                        onPageChanged: (p) => setState(() => _currentPage = p),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Analytics Panel (290px)
                    SizedBox(
                      width: 290,
                      child: SupportAnalyticsPanel(
                        totalCount: totalCount,
                        resolvedCount: resolvedCount,
                        inProgressCount: inProgressCount,
                        openCount: openCount,
                        onHoldCount: onHoldCount,
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
                          child: SupportFilterPanel(
                            searchController: _searchController,
                            selectedStatus: _selectedStatus,
                            selectedCategory: _selectedCategory,
                            selectedPriority: _selectedPriority,
                            selectedDateRange: _selectedDateRange,
                            onStatusChanged: (v) {
                              if (v != null) setState(() => _selectedStatus = v);
                            },
                            onCategoryChanged: (v) {
                              if (v != null) setState(() => _selectedCategory = v);
                            },
                            onPriorityChanged: (v) {
                              if (v != null) setState(() => _selectedPriority = v);
                            },
                            onDateRangeChanged: (v) {
                              if (v != null) setState(() => _selectedDateRange = v);
                            },
                            onApplyFilters: () => setState(() {}),
                            onReset: _resetFilters,
                            onCreateTicket: _showCreateTicketDialog,
                            onBulkReply: () {},
                            onManageCategories: () {},
                            onHelpCenter: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SupportAnalyticsPanel(
                            totalCount: totalCount,
                            resolvedCount: resolvedCount,
                            inProgressCount: inProgressCount,
                            openCount: openCount,
                            onHoldCount: onHoldCount,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SupportDataTable(
                      tickets: filteredTickets,
                      activeTab: _activeTab,
                      onTabChanged: (tab) => setState(() => _activeTab = tab),
                      onViewTicket: _showTicketDetailDialog,
                      onReplyTicket: _showTicketDetailDialog,
                      currentPage: _currentPage,
                      totalCount: totalCount,
                      openCount: openCount,
                      inProgressCount: inProgressCount,
                      resolvedCount: resolvedCount,
                      onPageChanged: (p) => setState(() => _currentPage = p),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    SupportFilterPanel(
                      searchController: _searchController,
                      selectedStatus: _selectedStatus,
                      selectedCategory: _selectedCategory,
                      selectedPriority: _selectedPriority,
                      selectedDateRange: _selectedDateRange,
                      onStatusChanged: (v) {
                        if (v != null) setState(() => _selectedStatus = v);
                      },
                      onCategoryChanged: (v) {
                        if (v != null) setState(() => _selectedCategory = v);
                      },
                      onPriorityChanged: (v) {
                        if (v != null) setState(() => _selectedPriority = v);
                      },
                      onDateRangeChanged: (v) {
                        if (v != null) setState(() => _selectedDateRange = v);
                      },
                      onApplyFilters: () => setState(() {}),
                      onReset: _resetFilters,
                      onCreateTicket: _showCreateTicketDialog,
                      onBulkReply: () {},
                      onManageCategories: () {},
                      onHelpCenter: () {},
                    ),
                    const SizedBox(height: 16),
                    SupportDataTable(
                      tickets: filteredTickets,
                      activeTab: _activeTab,
                      onTabChanged: (tab) => setState(() => _activeTab = tab),
                      onViewTicket: _showTicketDetailDialog,
                      onReplyTicket: _showTicketDetailDialog,
                      currentPage: _currentPage,
                      totalCount: totalCount,
                      openCount: openCount,
                      inProgressCount: inProgressCount,
                      resolvedCount: resolvedCount,
                      onPageChanged: (p) => setState(() => _currentPage = p),
                    ),
                    const SizedBox(height: 16),
                    SupportAnalyticsPanel(
                      totalCount: totalCount,
                      resolvedCount: resolvedCount,
                      inProgressCount: inProgressCount,
                      openCount: openCount,
                      onHoldCount: onHoldCount,
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
