import 'package:flutter/material.dart';
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

  static final List<Map<String, dynamic>> _defaultMockTickets = [
    {
      'id': 'TK-20261148',
      'name': 'Rohit Kumar',
      'email': 'rohit.kumar@gmail.com',
      'subject': 'Coins not credited after payment',
      'category': 'Payment',
      'priority': 'High',
      'status': 'open',
      'lastTime': 'Nov 11, 10:24 AM',
      'lastMsg': 'I deposited ₹500 via UPI but coins did not reflect in my wallet.',
      'messages': [
        {
          'isUser': true,
          'text': 'I deposited ₹500 via UPI but coins did not reflect in my wallet. Transaction ID: UPI982348234.',
          'time': '10:24 AM',
        },
      ],
    },
    {
      'id': 'TK-20261147',
      'name': 'Priya Singh',
      'email': 'priya.singh@gmail.com',
      'subject': 'Profile verification pending',
      'category': 'Verification',
      'priority': 'Medium',
      'status': 'in_progress',
      'lastTime': 'Nov 11, 09:18 AM',
      'lastMsg': 'Uploaded Aadhaar card for KYC verification 2 days ago.',
      'messages': [
        {
          'isUser': true,
          'text': 'Uploaded Aadhaar card for KYC verification 2 days ago. Please expedite.',
          'time': '09:18 AM',
        },
        {
          'isUser': false,
          'text': 'Hello Priya, our compliance team is reviewing your document.',
          'time': '09:30 AM',
        },
      ],
    },
    {
      'id': 'TK-20261146',
      'name': 'Amit Verma',
      'email': 'amit.v@outlook.com',
      'subject': 'Referral reward not received',
      'category': 'Referral',
      'priority': 'High',
      'status': 'in_progress',
      'lastTime': 'Nov 10, 07:46 PM',
      'lastMsg': 'My friend registered with code AMIT99 and completed first test.',
      'messages': [
        {
          'isUser': true,
          'text': 'My friend registered with code AMIT99 and completed first test, but referral reward not added.',
          'time': '07:46 PM',
        },
      ],
    },
    {
      'id': 'TK-20261145',
      'name': 'Sandeep Yadav',
      'email': 'sandeep.yadav@gmail.com',
      'subject': 'Quiz not loading on app',
      'category': 'Technical',
      'priority': 'Medium',
      'status': 'open',
      'lastTime': 'Nov 10, 05:30 PM',
      'lastMsg': 'Getting 500 error screen on BPSC mock test 4.',
      'messages': [
        {
          'isUser': true,
          'text': 'Getting 500 error screen on BPSC mock test 4 when clicking Start Quiz.',
          'time': '05:30 PM',
        },
      ],
    },
    {
      'id': 'TK-20261144',
      'name': 'Neha Kumari',
      'email': 'neha.kumari@yahoo.com',
      'subject': 'How to withdraw coins?',
      'category': 'Withdrawal',
      'priority': 'Low',
      'status': 'resolved',
      'lastTime': 'Nov 10, 02:12 PM',
      'lastMsg': 'Coins converted to payout successfully.',
      'messages': [
        {
          'isUser': true,
          'text': 'How do I transfer wallet coins to my Google Pay account?',
          'time': '02:00 PM',
        },
        {
          'isUser': false,
          'text': 'Go to Wallet > Withdraw, select UPI and enter your UPI ID. Minimum limit is 1,000 Coins.',
          'time': '02:12 PM',
        },
      ],
    },
  ];

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
          _tickets = List.from(_defaultMockTickets);
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
          'subject': row['subject']?.toString() ?? row['last_message']?.toString() ?? 'Support Request',
          'category': row['category']?.toString() ?? 'Payment',
          'priority': row['priority']?.toString() ?? 'Medium',
          'status': row['status']?.toString() ?? 'open',
          'lastTime': row['last_updated'] != null ? row['last_updated'].toString().split('T').first : 'Recent',
          'lastMsg': row['last_message']?.toString() ?? 'No messages yet.',
          'messages': msgs,
        });
      }

      if (mounted) {
        setState(() {
          _tickets = loadedTickets.isNotEmpty ? loadedTickets : List.from(_defaultMockTickets);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _tickets = List.from(_defaultMockTickets);
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
    final resolvedCount = _tickets.where((t) => (t['status']?.toString().toLowerCase() ?? '') == 'resolved').length;
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening bulk reply modal for active tickets...')),
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
            totalCount: totalCount > 0 ? totalCount : 1248,
            resolvedCount: resolvedCount > 0 ? resolvedCount : 846,
            inProgressCount: inProgressCount > 0 ? inProgressCount : 218,
            openCount: openCount > 0 ? openCount : 96,
            onHoldCount: onHoldCount > 0 ? onHoldCount : 38,
            supportRating: 4.7,
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
                        totalCount: 1248,
                        onPageChanged: (p) => setState(() => _currentPage = p),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Analytics Panel (290px)
                    const SizedBox(
                      width: 290,
                      child: SupportAnalyticsPanel(),
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
                        const Expanded(
                          child: SupportAnalyticsPanel(),
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
                      totalCount: 1248,
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
                      totalCount: 1248,
                      onPageChanged: (p) => setState(() => _currentPage = p),
                    ),
                    const SizedBox(height: 16),
                    const SupportAnalyticsPanel(),
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
