import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CreatePostCard extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> post) onPublish;
  final VoidCallback onReset;

  const CreatePostCard({
    super.key,
    required this.onPublish,
    required this.onReset,
  });

  @override
  State<CreatePostCard> createState() => _CreatePostCardState();
}

class _CreatePostCardState extends State<CreatePostCard> {
  String _activeType = 'post'; // 'post', 'poll', 'announcement'
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();

  final List<String> _tags = ['Study', 'Quiz', 'RRB', 'Science'];
  final _tagInputController = TextEditingController();

  bool _schedulePost = false;
  bool _pinToTop = false;
  bool _sendNotification = true;
  String? _selectedAttachment; // 'image', 'video', 'pdf', 'link'
  bool _isPublishing = false;

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _handleReset() {
    setState(() {
      _contentController.clear();
      _titleController.clear();
      _schedulePost = false;
      _pinToTop = false;
      _sendNotification = true;
      _selectedAttachment = null;
    });
    widget.onReset();
  }

  Future<void> _handlePublish() async {
    final text = _contentController.text.trim();
    if (text.isEmpty || _isPublishing) return;

    setState(() => _isPublishing = true);
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : (text.length > 40 ? '${text.substring(0, 40)}...' : text);

    final newPost = {
      'id': 'post-${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'content': text,
      'excerpt': text,
      'type': _activeType,
      'category': _tags.isNotEmpty ? _tags.first : 'General',
      'tags': List<String>.from(_tags),
      'date': 'Today',
      'isPinned': _pinToTop,
      'isScheduled': _schedulePost,
      'attachmentType': _selectedAttachment,
      'views': '0',
      'likes': '0',
      'comments': '0',
      'shares': '0',
      'imageUrl': _selectedAttachment == 'image'
          ? 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=800&auto=format&fit=crop&q=60'
          : '',
    };

    await widget.onPublish(newPost);
    _contentController.clear();
    _titleController.clear();
    if (mounted) setState(() => _isPublishing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, size: 20, color: AppColors.adminPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Create Community Post', style: AppTypography.adminCardTitle, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Post Type Selector
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.adminBackground,
              borderRadius: AppRadii.adminControl,
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Row(
              children: [
                _buildTypeTab('post', 'Post', flex: 3),
                _buildTypeTab('poll', 'Poll', flex: 3),
                _buildTypeTab('announcement', 'Announcement', flex: 5),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Optional Title for Announcement / Poll
          if (_activeType != 'post') ...[
            AppTextField(
              controller: _titleController,
              hintText: _activeType == 'poll' ? 'Poll Question Title *' : 'Announcement Headline *',
            ),
            const SizedBox(height: 10),
          ],

          // Content Box
          AppTextField(
            controller: _contentController,
            hintText: 'What\'s on your mind? Share with your learners...',
            maxLines: 4,
          ),
          const SizedBox(height: 14),

          // Attachment Pills Row
          Row(
            children: [
              _buildAttachmentBtn('image', Icons.image_outlined, 'Image'),
              const SizedBox(width: 8),
              _buildAttachmentBtn('video', Icons.play_circle_outline_rounded, 'Video'),
              const SizedBox(width: 8),
              _buildAttachmentBtn('pdf', Icons.picture_as_pdf_outlined, 'PDF'),
              const SizedBox(width: 8),
              _buildAttachmentBtn('link', Icons.link_rounded, 'Link'),
            ],
          ),
          const SizedBox(height: 16),

          // Add Tags
          Text('Add Tags (Optional)', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.adminBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.adminBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tag, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.adminPrimaryText)),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => setState(() => _tags.remove(tag)),
                          child: const Icon(Icons.close_rounded, size: 12, color: AppColors.adminSecondaryText),
                        ),
                      ],
                    ),
                  )),
              InkWell(
                onTap: _showAddTagDialog,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.adminPurpleLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.adminPurple.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_rounded, size: 14, color: AppColors.adminPurple),
                      SizedBox(width: 4),
                      Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.adminPurple)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Post Settings
          Text('Post Settings', style: AppTypography.adminFieldLabelSmall),
          const SizedBox(height: 8),
          _buildSettingSwitch('Schedule Post', Icons.calendar_today_rounded, _schedulePost, (v) => setState(() => _schedulePost = v)),
          const SizedBox(height: 6),
          _buildSettingSwitch('Pin to Top', Icons.push_pin_outlined, _pinToTop, (v) => setState(() => _pinToTop = v)),
          const SizedBox(height: 6),
          _buildSettingSwitch('Send Notification', Icons.notifications_none_rounded, _sendNotification, (v) => setState(() => _sendNotification = v)),
          const SizedBox(height: 20),

          // Buttons: Reset & Post Now
          Row(
            children: [
              Expanded(
                child: AppButton.adminSecondary(
                  label: 'Reset',
                  onPressed: _handleReset,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: AppButton.adminPrimary(
                  label: _isPublishing ? 'Posting...' : 'Post Now',
                  leadingIcon: const Icon(Icons.send_rounded, size: 16),
                  onPressed: _isPublishing ? null : _handlePublish,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String id, String label, {int flex = 1}) {
    final isSelected = _activeType == id;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => setState(() => _activeType = id),
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.adminPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.adminSecondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBtn(String id, IconData icon, String label) {
    final isSelected = _selectedAttachment == id;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedAttachment = isSelected ? null : id),
        borderRadius: AppRadii.adminControl,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.adminPurpleLight : AppColors.adminBackground,
            borderRadius: AppRadii.adminControl,
            border: Border.all(color: isSelected ? AppColors.adminPurple : AppColors.adminBorder),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.adminPurple : AppColors.adminSecondaryText),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.adminPurple : AppColors.adminSecondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.adminSecondaryText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.adminPrimaryText),
          ),
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.adminPurple,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _showAddTagDialog() {
    _tagInputController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tag', style: AppTypography.adminCardTitle),
        content: AppTextField(
          controller: _tagInputController,
          hintText: 'e.g. UPSC, General Studies',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newTag = _tagInputController.text.trim();
              if (newTag.isNotEmpty && !_tags.contains(newTag)) {
                setState(() => _tags.add(newTag));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPurple),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

