import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/live_poll_model.dart';

class CreatePollPanel extends StatefulWidget {
  final LivePollData pollData;
  final ValueChanged<LivePollData> onPollChanged;
  final VoidCallback onLaunchPoll;
  final VoidCallback onReset;

  const CreatePollPanel({
    super.key,
    required this.pollData,
    required this.onPollChanged,
    required this.onLaunchPoll,
    required this.onReset,
  });

  @override
  State<CreatePollPanel> createState() => _CreatePollPanelState();
}

class _CreatePollPanelState extends State<CreatePollPanel> {
  late TextEditingController _questionController;
  final Map<String, TextEditingController> _optionControllers = {};

  final List<int> _durationOptions = [15, 30, 45, 60, 120, 300];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.pollData.question);
    _syncOptionControllers();
  }

  @override
  void didUpdateWidget(covariant CreatePollPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pollData.question != widget.pollData.question &&
        _questionController.text != widget.pollData.question) {
      _questionController.text = widget.pollData.question;
    }
    _syncOptionControllers();
  }

  void _syncOptionControllers() {
    for (final opt in widget.pollData.options) {
      if (!_optionControllers.containsKey(opt.id)) {
        _optionControllers[opt.id] = TextEditingController(text: opt.text);
      } else if (_optionControllers[opt.id]!.text != opt.text) {
        _optionControllers[opt.id]!.text = opt.text;
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (widget.pollData.options.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 8 options allowed.')),
      );
      return;
    }
    final labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final nextIndex = widget.pollData.options.length;
    final nextLabel = nextIndex < labels.length ? labels[nextIndex] : '${nextIndex + 1}';
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final updatedList = List<LivePollOption>.from(widget.pollData.options)
      ..add(LivePollOption(
        id: newId,
        label: nextLabel,
        text: 'Option ${nextIndex + 1}',
        votes: 0,
      ));
    
    _optionControllers[newId] = TextEditingController(text: 'Option ${nextIndex + 1}');
    widget.pollData.options = updatedList;
    widget.onPollChanged(widget.pollData);
  }

  void _removeOption(int index) {
    if (widget.pollData.options.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum 2 options required.')),
      );
      return;
    }
    final removed = widget.pollData.options[index];
    _optionControllers[removed.id]?.dispose();
    _optionControllers.remove(removed.id);

    final labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final updated = List<LivePollOption>.from(widget.pollData.options)..removeAt(index);
    for (int i = 0; i < updated.length; i++) {
      final lbl = i < labels.length ? labels[i] : '${i + 1}';
      updated[i] = updated[i].copyWith(label: lbl);
    }
    widget.pollData.options = updated;
    widget.onPollChanged(widget.pollData);
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds Seconds';
    final mins = seconds ~/ 60;
    return '$mins Minute${mins > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final poll = widget.pollData;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.pollCard,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.pollCard,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header: Purple square with + and "Create Poll" title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.pollPurplePrimary,
                  borderRadius: AppRadii.borderSm,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Create Poll',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Poll Type Selector (Single Choice, Multiple Choice, Yes / No)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: AppRadii.borderMd,
            ),
            child: Row(
              children: LivePollType.values.map((t) {
                final isSelected = poll.type == t;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        poll.type = t;
                        if (t == LivePollType.yesNo) {
                          poll.options = [
                            LivePollOption(id: 'yn1', label: 'A', text: 'Yes', votes: 120),
                            LivePollOption(id: 'yn2', label: 'B', text: 'No', votes: 45),
                          ];
                        }
                      });
                      widget.onPollChanged(poll);
                    },
                    borderRadius: AppRadii.borderSm,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.pollPurplePrimary : Colors.transparent,
                        borderRadius: AppRadii.borderSm,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.pollPurplePrimary.withAlpha(80),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        t.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Question Textarea
          RichText(
            text: const TextSpan(
              text: 'Poll Question ',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              children: [
                TextSpan(text: '*', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _questionController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter your poll question...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(12),
              border: const OutlineInputBorder(
                borderRadius: AppRadii.borderMd,
                borderSide: BorderSide(color: AppColors.borderStrong),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadii.borderMd,
                borderSide: BorderSide(color: AppColors.borderStrong),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadii.borderMd,
                borderSide: BorderSide(color: AppColors.pollPurplePrimary, width: 1.5),
              ),
            ),
            onChanged: (val) {
              poll.question = val;
              widget.onPollChanged(poll);
            },
          ),
          const SizedBox(height: 16),

          // 4. Options
          RichText(
            text: const TextSpan(
              text: 'Options ',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              children: [
                TextSpan(text: '*', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Reorderable list of options
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: poll.options.length,
            onReorderItem: (oldIndex, newIndex) {
              final updated = List<LivePollOption>.from(widget.pollData.options);
              final item = updated.removeAt(oldIndex);
              updated.insert(newIndex, item);

              final labels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
              for (int i = 0; i < updated.length; i++) {
                final lbl = i < labels.length ? labels[i] : '${i + 1}';
                updated[i] = updated[i].copyWith(label: lbl);
              }
              widget.pollData.options = updated;
              widget.onPollChanged(widget.pollData);
            },
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              final opt = poll.options[index];
              final ctrl = _optionControllers[opt.id] ?? TextEditingController(text: opt.text);

              return Container(
                key: ValueKey(opt.id),
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Drag Handle
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.drag_indicator, size: 18, color: AppColors.textMuted),
                      ),
                    ),
                    // Option letter badge (A, B, C, D)
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.pollPurpleLight,
                        borderRadius: AppRadii.borderMd,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        opt.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.pollPurplePrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Input Field (Standard Design System Height, Natural Centering)
                    Expanded(
                      child: TextField(
                        controller: ctrl,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Option ${index + 1}',
                          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                          border: const OutlineInputBorder(
                            borderRadius: AppRadii.borderMd,
                            borderSide: BorderSide(color: AppColors.borderStrong),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: AppRadii.borderMd,
                            borderSide: BorderSide(color: AppColors.borderStrong),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: AppRadii.borderMd,
                            borderSide: BorderSide(color: AppColors.pollPurplePrimary, width: 1.5),
                          ),
                        ),
                        onChanged: (val) {
                          opt.text = val;
                          widget.onPollChanged(poll);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                      onPressed: () => _removeOption(index),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Remove Option',
                    ),
                  ],
                ),
              );
            },
          ),

          // Add Option Button
          InkWell(
            onTap: _addOption,
            borderRadius: AppRadii.borderSm,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.pollPurpleBg,
                borderRadius: AppRadii.borderSm,
                border: Border.all(color: AppColors.pollPurpleBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 16, color: AppColors.pollPurplePrimary),
                  SizedBox(width: 6),
                  Text(
                    'Add Option',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pollPurplePrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 5. Poll Duration Selector (Custom Tokenized AppDropdown)
          AppDropdown<int>(
            label: 'Poll Duration',
            inlineLabel: false,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            value: poll.durationSeconds,
            height: 48,
            borderRadius: AppRadii.borderMd,
            borderColor: AppColors.borderStrong,
            focusedBorderColor: AppColors.pollPurplePrimary,
            selectedItemColor: AppColors.pollPurplePrimary,
            selectedItemBackgroundColor: AppColors.pollPurpleLight,
            prefixIcon: const Icon(
              Icons.access_time_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            items: _durationOptions.map((sec) {
              return AppDropdownItem<int>(
                value: sec,
                label: _formatDuration(sec),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  poll.durationSeconds = val;
                  poll.remainingSeconds = val;
                });
                widget.onPollChanged(poll);
              }
            },
          ),
          const SizedBox(height: 14),

          // 6. Show Live Result Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Show Live Result',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              Switch(
                value: poll.showLiveResult,
                activeThumbColor: AppColors.pollPurplePrimary,
                activeTrackColor: AppColors.pollPurpleBorder,
                onChanged: (val) {
                  setState(() => poll.showLiveResult = val);
                  widget.onPollChanged(poll);
                },
              ),
            ],
          ),

          // 7. Allow Option Change Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Allow Option Change',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              Switch(
                value: poll.allowOptionChange,
                activeThumbColor: AppColors.pollPurplePrimary,
                activeTrackColor: AppColors.pollPurpleBorder,
                onChanged: (val) {
                  setState(() => poll.allowOptionChange = val);
                  widget.onPollChanged(poll);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 8. Bottom Action Row: Reset + Launch Live Poll
          Row(
            children: [
              // Reset Button
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: widget.onReset,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.borderStrong),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Launch Live Poll Button
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: AppColors.pollButtonGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pollPurplePrimary.withAlpha(100),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: widget.onLaunchPoll,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Launch Live Poll',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

