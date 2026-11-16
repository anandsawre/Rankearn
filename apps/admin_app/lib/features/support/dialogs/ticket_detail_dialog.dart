import 'dart:async';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:data_layer/data_layer.dart';

class TicketDetailDialog extends StatefulWidget {
  final Map<String, dynamic> ticket;
  final Future<void> Function(String text) onSendMessage;
  final void Function(String status) onStatusChanged;
  final void Function(String priority) onPriorityChanged;

  const TicketDetailDialog({
    super.key,
    required this.ticket,
    required this.onSendMessage,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  @override
  State<TicketDetailDialog> createState() => _TicketDetailDialogState();
}

class _TicketDetailDialogState extends State<TicketDetailDialog> {
  final _replyController = TextEditingController();
  final _internalNotesController = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription<List<Map<String, dynamic>>>? _messagesSub;
  List<Map<String, dynamic>> _messages = [];
  late String _currentStatus;
  late String _currentPriority;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.ticket['status']?.toString() ?? 'open';
    _currentPriority = widget.ticket['priority']?.toString() ?? 'High';

    if (widget.ticket['messages'] is List) {
      _messages = List<Map<String, dynamic>>.from(
        (widget.ticket['messages'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
    }

    _subscribeToLiveMessages();
  }

  void _subscribeToLiveMessages() {
    final client = SupabaseConfig.clientSafe;
    final ticketId = widget.ticket['id']?.toString();
    if (client == null || ticketId == null || ticketId.isEmpty) return;

    _messagesSub?.cancel();
    _messagesSub = client
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true)
        .listen(
      (data) {
        if (!mounted) return;
        final updated = data.map<Map<String, dynamic>>((m) => <String, dynamic>{
          'isUser': m['role'] == 'user',
          'text': m['text']?.toString() ?? '',
          'time': m['created_at'] != null
              ? m['created_at'].toString().split('T').last.substring(0, 5)
              : '',
        }).toList();

        setState(() {
          _messages = updated;
        });
        _scrollToBottom();
      },
      onError: (_) {},
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _replyController.dispose();
    _internalNotesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    await widget.onSendMessage(text);
    _replyController.clear();
    if (mounted) setState(() => _isSending = false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final ticketId = widget.ticket['id']?.toString() ?? 'TK-20261148';
    final name = widget.ticket['name']?.toString() ?? 'Candidate';
    final email = widget.ticket['email']?.toString() ?? 'user@rankearn.app';
    final subject = widget.ticket['subject']?.toString() ?? widget.ticket['lastMsg']?.toString() ?? 'Support Query';

    return AppModalDialog(
      title: 'Ticket #$ticketId',
      subtitle: '$name • $email',
      iconData: Icons.headset_mic_rounded,
      maxWidth: 720,
      actions: [
        AppButton.adminSecondary(
          label: 'Close',
          onPressed: () => Navigator.pop(context),
        ),
      ],
      child: SizedBox(
        height: 520,
        child: Row(
          children: [
            // Left: Conversation Stream (Expanded)
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.adminBackground,
                      borderRadius: AppRadii.adminControl,
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Subject', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.adminSecondaryText)),
                        const SizedBox(height: 2),
                        Text(subject, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.adminPrimaryText)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Messages List
                  Expanded(
                    child: _messages.isEmpty
                        ? const Center(
                            child: Text('No previous messages.', style: AppTypography.adminTableSecondary),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _messages.length,
                            itemBuilder: (context, idx) {
                              final m = _messages[idx];
                              final isUser = m['isUser'] == true;
                              return Align(
                                alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  constraints: const BoxConstraints(maxWidth: 320),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isUser ? AppColors.adminBackground : AppColors.adminPurple,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(12),
                                      topRight: const Radius.circular(12),
                                      bottomLeft: Radius.circular(isUser ? 2 : 12),
                                      bottomRight: Radius.circular(isUser ? 12 : 2),
                                    ),
                                    border: isUser ? Border.all(color: AppColors.adminBorder) : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        m['text']?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isUser ? AppColors.adminPrimaryText : Colors.white,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        m['time']?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: isUser ? AppColors.adminSecondaryText : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Reply Input Bar
                  const Divider(height: 1, color: AppColors.adminBorder),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _replyController,
                          hintText: 'Type response to candidate...',
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton.adminPrimary(
                        label: _isSending ? '...' : 'Send',
                        leadingIcon: const Icon(Icons.send_rounded, size: 14),
                        onPressed: _handleSend,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const VerticalDivider(width: 1, color: AppColors.adminBorder),
            const SizedBox(width: 16),

            // Right: Ticket Metadata & Internal Controls
            SizedBox(
              width: 200,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status', style: AppTypography.adminFieldLabelSmall),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      inlineLabel: true,
                      value: _currentStatus,
                      items: const [
                        AppDropdownItem(value: 'open', label: 'Open'),
                        AppDropdownItem(value: 'in_progress', label: 'In Progress'),
                        AppDropdownItem(value: 'resolved', label: 'Resolved'),
                        AppDropdownItem(value: 'on_hold', label: 'On Hold'),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _currentStatus = v);
                          widget.onStatusChanged(v);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    Text('Priority', style: AppTypography.adminFieldLabelSmall),
                    const SizedBox(height: 6),
                    AppDropdown<String>(
                      inlineLabel: true,
                      value: _currentPriority.toLowerCase(),
                      items: const [
                        AppDropdownItem(value: 'high', label: 'High'),
                        AppDropdownItem(value: 'medium', label: 'Medium'),
                        AppDropdownItem(value: 'low', label: 'Low'),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _currentPriority = v);
                          widget.onPriorityChanged(v);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    Text('Assigned To', style: AppTypography.adminFieldLabelSmall),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.adminBackground,
                        borderRadius: AppRadii.adminControl,
                        border: Border.all(color: AppColors.adminBorder),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.shield_rounded, size: 14, color: AppColors.adminPurple),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Support Lead (Admin)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.adminPrimaryText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('Internal Notes', style: AppTypography.adminFieldLabelSmall),
                    const SizedBox(height: 6),
                    AppTextField(
                      controller: _internalNotesController,
                      hintText: 'Notes for internal staff...',
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
