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
        .handleError((err) {
          debugPrint('Support messages stream error: $err');
        })
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
    try {
      await widget.onSendMessage(text);
      _replyController.clear();
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
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
      maxWidth: 780,
      actions: [
        AppModalDialog.cancelButton(context, label: 'Close'),
      ],
      child: SizedBox(
        height: 540,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 580;

            final conversationPane = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: AppRadii.adminCardInner,
                    border: Border.all(color: AppColors.adminBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SUBJECT',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: AppColors.adminSecondaryText,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subject,
                        style: AppTypography.adminCardTitle.copyWith(fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Messages List
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.forum_outlined, size: 36, color: AppColors.borderStrong),
                              const SizedBox(height: AppSpacing.xs),
                              const Text('No previous messages.', style: AppTypography.adminTableSecondary),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemBuilder: (context, idx) {
                            final m = _messages[idx];
                            final isUser = m['isUser'] == true;
                            return Align(
                              alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                constraints: const BoxConstraints(maxWidth: 340),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isUser ? AppColors.surfaceSubtle : AppColors.adminPurple,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(AppRadii.md),
                                    topRight: const Radius.circular(AppRadii.md),
                                    bottomLeft: Radius.circular(isUser ? 3.0 : AppRadii.md),
                                    bottomRight: Radius.circular(isUser ? AppRadii.md : 3.0),
                                  ),
                                  border: isUser ? Border.all(color: AppColors.adminBorder) : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      m['text']?.toString() ?? '',
                                      style: AppTypography.bodySmall.copyWith(
                                        fontSize: 12.5,
                                        color: isUser ? AppColors.adminPrimaryText : Colors.white,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      m['time']?.toString() ?? '',
                                      style: AppTypography.labelSmall.copyWith(
                                        fontSize: 9.5,
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
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppModalDialog.textField(
                        controller: _replyController,
                        hint: 'Type response to candidate...',
                        prefixIcon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.adminSecondaryText),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppModalDialog.primaryButton(
                      onPressed: _isSending ? null : _handleSend,
                      icon: _isSending
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 14),
                      child: Text(
                        _isSending ? '...' : 'Send',
                        style: const TextStyle(
                          fontFamily: AppTypography.fontHeading,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );

            final sidebarControls = SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ticket Status', style: AppTypography.adminFieldLabelSmall),
                  const SizedBox(height: AppSpacing.xs),
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
                  const SizedBox(height: AppSpacing.md),

                  Text('Priority Level', style: AppTypography.adminFieldLabelSmall),
                  const SizedBox(height: AppSpacing.xs),
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
                  const SizedBox(height: AppSpacing.md),

                  Text('Assigned Agent', style: AppTypography.adminFieldLabelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: AppRadii.adminControl,
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded, size: 14, color: AppColors.adminPurple),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            'Support Lead (Admin)',
                            style: AppTypography.adminTablePrimary.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text('Internal Notes', style: AppTypography.adminFieldLabelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  AppModalDialog.textField(
                    controller: _internalNotesController,
                    hint: 'Staff notes & context...',
                    maxLines: 4,
                    minLines: 3,
                  ),
                ],
              ),
            );

            if (isNarrow) {
              return Column(
                children: [
                  Expanded(child: conversationPane),
                  const SizedBox(height: AppSpacing.sm),
                  sidebarControls,
                ],
              );
            }

            return Row(
              children: [
                Expanded(flex: 3, child: conversationPane),
                const SizedBox(width: AppSpacing.md),
                const VerticalDivider(width: 1, color: AppColors.adminBorder),
                const SizedBox(width: AppSpacing.md),
                SizedBox(width: 210, child: sidebarControls),
              ],
            );
          },
        ),
      ),
    );
  }
}
