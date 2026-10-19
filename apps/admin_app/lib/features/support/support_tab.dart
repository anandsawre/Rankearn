import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class SupportTab extends StatefulWidget {
  final List<Map<String, dynamic>>? initialTickets;
  const SupportTab({super.key, this.initialTickets});

  @override
  State<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  final _messageController = TextEditingController();
  int _selectedTicketIndex = 0;
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

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

  Future<void> _fetchTickets() async {
    final client = SupabaseConfig.clientSafe;
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _tickets.isEmpty) return;

    final t = _tickets[_selectedTicketIndex];
    final ticketId = t['id']?.toString() ?? '';

    setState(() {
      (t['messages'] as List).add({
        'isUser': false,
        'text': text,
        'time': 'Just Now',
      });
      t['lastMsg'] = text;
      _messageController.clear();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        ),
      );
    }

    if (_tickets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height - 110,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.borderXl,
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent, color: AppColors.brandPrimary, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('No Active Support Tickets', style: AppTypography.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'When candidates submit help requests from their mobile app, tickets and chat histories will appear in this inbox.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    final safeIndex = _selectedTicketIndex < _tickets.length ? _selectedTicketIndex : 0;
    final activeTicket = _tickets[safeIndex];
    final messages = (activeTicket['messages'] as List<dynamic>?) ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height - 110,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.borderXl,
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: const [
            BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Left Pane: Ticket Inbox
            SizedBox(
              width: 340,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.support_agent, color: AppColors.brandPrimary),
                        SizedBox(width: 10),
                        Text('Candidate Tickets', style: AppTypography.titleLarge),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _tickets.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF8FAFC)),
                      itemBuilder: (context, idx) {
                        final t = _tickets[idx];
                        final isSelected = idx == safeIndex;
                        final isOpen = t['status'] == 'open';
                        final name = t['name']?.toString() ?? 'Candidate';

                        return InkWell(
                          onTap: () => setState(() => _selectedTicketIndex = idx),
                          child: Container(
                            color: isSelected ? const Color(0xFFECFDF5) : Colors.transparent,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  child: Text(name.isNotEmpty ? name[0] : 'U', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                          Text(t['lastTime']?.toString() ?? '', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        t['lastMsg']?.toString() ?? '',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: isOpen ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                                          borderRadius: AppRadii.borderPill,
                                        ),
                                        child: Text(
                                          isOpen ? 'PENDING' : 'RESOLVED',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w900,
                                            color: isOpen ? const Color(0xFFD97706) : const Color(0xFF059669),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1, color: Color(0xFFF1F5F9)),

            // Right Pane: Active Chat Thread
            Expanded(
              child: Column(
                children: [
                  // Active Ticket Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activeTicket['name']?.toString() ?? '', style: AppTypography.titleLarge),
                            Text(activeTicket['email']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                        Row(
                          children: [
                            AppButton(
                              label: activeTicket['status'] == 'open' ? 'Mark Resolved' : 'Re-open Ticket',
                              variant: activeTicket['status'] == 'open' ? AppButtonVariant.primary : AppButtonVariant.outlined,
                              size: AppButtonSize.small,
                              onPressed: () async {
                                final newStatus = activeTicket['status'] == 'open' ? 'resolved' : 'open';
                                setState(() {
                                  activeTicket['status'] = newStatus;
                                });
                                final client = SupabaseConfig.clientSafe;
                                if (client != null) {
                                  try {
                                    await client.from('support_tickets').update({'status': newStatus}).eq('id', activeTicket['id']);
                                  } catch (_) {}
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Messages Stream
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: messages.length,
                      itemBuilder: (context, idx) {
                        final m = messages[idx];
                        final isUser = m['isUser'] == true;

                        return Align(
                          alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            constraints: const BoxConstraints(maxWidth: 480),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isUser ? const Color(0xFFF1F5F9) : AppColors.brandPrimary,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isUser ? 2 : 16),
                                bottomRight: Radius.circular(isUser ? 16 : 2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                              children: [
                                Text(
                                  m['text']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUser ? const Color(0xFF1E293B) : Colors.white,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m['time']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isUser ? const Color(0xFF94A3B8) : Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Message Input Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _messageController,
                            hintText: 'Type response to candidate...',
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppColors.brandPrimary),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
