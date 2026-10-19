import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class SupportTab extends StatefulWidget {
  const SupportTab({super.key});

  @override
  State<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  final _messageController = TextEditingController();
  int _selectedTicketIndex = 0;

  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'tick-1',
      'name': 'Rahul Verma',
      'email': 'rahul.verma@outlook.com',
      'status': 'open',
      'lastTime': '11:24 AM',
      'lastMsg': 'Sir, my UPI top-up of ₹250 has not reflected in my coin balance yet.',
      'messages': [
        {'isUser': true, 'text': 'Hello Admin, I completed UPI transfer 20 mins ago.', 'time': '11:15 AM'},
        {'isUser': true, 'text': 'UTR is ICICI4920194821. Please verify and credit 5000 coins.', 'time': '11:20 AM'},
        {'isUser': false, 'text': 'Hello Rahul! Our finance desk has reviewed your UTR. Your 5,000 Coins have been credited to your wallet.', 'time': '11:22 AM'},
        {'isUser': true, 'text': 'Sir, my UPI top-up of ₹250 has not reflected in my coin balance yet.', 'time': '11:24 AM'},
      ],
    },
    {
      'id': 'tick-2',
      'name': 'Sneha Patel',
      'email': 'sneha.patel@gmail.com',
      'status': 'resolved',
      'lastTime': 'Yesterday',
      'lastMsg': 'Thank you! The question discrepancy in Mock 2 has been rectified.',
      'messages': [
        {'isUser': true, 'text': 'Question #42 in BPSC Mock 1 had an incorrect answer key.', 'time': 'Yesterday, 03:00 PM'},
        {'isUser': false, 'text': 'We updated the answer key and recomputed scores for all candidates.', 'time': 'Yesterday, 03:30 PM'},
        {'isUser': true, 'text': 'Thank you! The question discrepancy in Mock 2 has been rectified.', 'time': 'Yesterday, 03:45 PM'},
      ],
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      final t = _tickets[_selectedTicketIndex];
      (t['messages'] as List).add({
        'isUser': false,
        'text': text,
        'time': 'Just Now',
      });
      t['lastMsg'] = text;
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTicket = _tickets[_selectedTicketIndex];
    final messages = activeTicket['messages'] as List<dynamic>;

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
                        final isSelected = idx == _selectedTicketIndex;
                        final isOpen = t['status'] == 'open';

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
                                  child: Text(t['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(t['name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                          Text(t['lastTime'], style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        t['lastMsg'],
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
                            Text(activeTicket['name'], style: AppTypography.titleLarge),
                            Text(activeTicket['email'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                        Row(
                          children: [
                            AppButton(
                              label: activeTicket['status'] == 'open' ? 'Mark Resolved' : 'Re-open Ticket',
                              variant: activeTicket['status'] == 'open' ? AppButtonVariant.primary : AppButtonVariant.outlined,
                              size: AppButtonSize.small,
                              onPressed: () {
                                setState(() {
                                  activeTicket['status'] = activeTicket['status'] == 'open' ? 'resolved' : 'open';
                                });
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
                                  m['text'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUser ? const Color(0xFF1E293B) : Colors.white,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m['time'],
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
