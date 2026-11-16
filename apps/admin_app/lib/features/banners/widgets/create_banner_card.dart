import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class CreateBannerCard extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController linkController;
  final TextEditingController priorityController;
  final String? imageUrl;
  final ValueChanged<String?> onImageUrlChanged;
  final String bannerType;
  final ValueChanged<String> onBannerTypeChanged;
  final String displayMode;
  final ValueChanged<String> onDisplayModeChanged;
  final bool isScheduled;
  final ValueChanged<bool> onScheduleToggled;
  final DateTime? startDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onEndDateChanged;
  final bool isActive;
  final ValueChanged<bool> onActiveToggled;
  final bool isSaving;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback onPreview;

  const CreateBannerCard({
    super.key,
    required this.titleController,
    required this.linkController,
    required this.priorityController,
    required this.imageUrl,
    required this.onImageUrlChanged,
    required this.bannerType,
    required this.onBannerTypeChanged,
    required this.displayMode,
    required this.onDisplayModeChanged,
    required this.isScheduled,
    required this.onScheduleToggled,
    required this.startDate,
    required this.onStartDateChanged,
    required this.endDate,
    required this.onEndDateChanged,
    required this.isActive,
    required this.onActiveToggled,
    required this.isSaving,
    required this.onReset,
    required this.onSave,
    required this.onPreview,
  });

  @override
  State<CreateBannerCard> createState() => _CreateBannerCardState();
}

class _CreateBannerCardState extends State<CreateBannerCard> {
  final TextEditingController _customUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.imageUrl != null) {
      _customUrlController.text = widget.imageUrl!;
    }
  }

  @override
  void didUpdateWidget(covariant CreateBannerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      _customUrlController.text = widget.imageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (widget.startDate ?? now)
          : (widget.endDate ?? now.add(const Duration(days: 7))),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.adminPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.adminPrimaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        widget.onStartDateChanged(picked);
      } else {
        widget.onEndDateChanged(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.adminCardBackground,
        borderRadius: AppRadii.adminCard,
        border: Border.all(color: AppColors.adminBorder),
        boxShadow: AppShadows.adminCard,
      ),
      padding: AppSpacing.adminCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.adminPurpleLight,
                  borderRadius: AppRadii.adminControl,
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  color: AppColors.adminPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create / Update Promo Banner',
                      style: AppTypography.adminCardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Upload banner creatives, set target links, schedule and display modes',
                      style: AppTypography.adminCardSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Image Upload & Preview Box
          _buildImageUploader(),
          const SizedBox(height: 20),

          // Title & Target Link Row
          Builder(
            builder: (context) {
              final isTwo = MediaQuery.sizeOf(context).width >= 640;
              if (isTwo) {
                return Row(
                  children: [
                    Expanded(child: _buildTitleField()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLinkField()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 14),
                  _buildLinkField(),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Banner Type & Display Mode Row
          Builder(
            builder: (context) {
              final isTwo = MediaQuery.sizeOf(context).width >= 640;
              if (isTwo) {
                return Row(
                  children: [
                    Expanded(child: _buildBannerTypeSelector()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDisplayModeSelector()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildBannerTypeSelector(),
                  const SizedBox(height: 14),
                  _buildDisplayModeSelector(),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Priority & Status Row
          Builder(
            builder: (context) {
              final isTwo = MediaQuery.sizeOf(context).width >= 640;
              final priorityField = AppTextField(
                controller: widget.priorityController,
                hintText: 'Display Priority (1–10) *',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.sort_rounded, size: 20, color: AppColors.adminSecondaryText),
              );

              final statusCard = AppStatusSwitchField(
                value: widget.isActive,
                onChanged: widget.onActiveToggled,
              );

              if (isTwo) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: priorityField),
                    const SizedBox(width: 16),
                    Expanded(child: statusCard),
                  ],
                );
              }
              return Column(
                children: [
                  priorityField,
                  const SizedBox(height: 14),
                  statusCard,
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Divider
          const Divider(color: AppColors.adminBorder, height: 1),
          const SizedBox(height: 18),

          // Schedule Send Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.adminPurple),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule Banner Campaign',
                            style: AppTypography.adminFieldLabel,
                          ),
                          Text(
                            'Automatically publish and unpublish between specific dates',
                            style: AppTypography.adminTableSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppSwitch.primary(
                value: widget.isScheduled,
                onChanged: widget.onScheduleToggled,
              ),
            ],
          ),

          if (widget.isScheduled) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(true),
                    borderRadius: AppRadii.adminControl,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.adminBackground,
                        borderRadius: AppRadii.adminControl,
                        border: Border.all(color: AppColors.adminBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_rounded, size: 18, color: AppColors.adminPurple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.startDate != null
                                  ? 'Start: ${widget.startDate!.toLocal().toString().split(' ').first}'
                                  : 'Select Start Date',
                              style: AppTypography.adminTablePrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickDate(false),
                    borderRadius: AppRadii.adminControl,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.adminBackground,
                        borderRadius: AppRadii.adminControl,
                        border: Border.all(color: AppColors.adminBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_busy_rounded, size: 18, color: AppColors.adminOrange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.endDate != null
                                  ? 'End: ${widget.endDate!.toLocal().toString().split(' ').first}'
                                  : 'Select End Date',
                              style: AppTypography.adminTablePrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          // Bottom Action Buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppButton.adminGhost(
                label: 'Reset Form',
                onPressed: widget.isSaving ? null : widget.onReset,
              ),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  AppButton.adminSecondary(
                    label: 'Preview Banner',
                    onPressed: widget.onPreview,
                  ),
                  AppButton.adminPrimary(
                    label: widget.isSaving ? 'Saving...' : 'Save Banner',
                    isLoading: widget.isSaving,
                    onPressed: widget.isSaving ? null : widget.onSave,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploader() {
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.adminBackground,
            borderRadius: AppRadii.adminControl,
            border: Border.all(
              color: hasImage ? AppColors.adminPurple : AppColors.adminBorder,
              width: hasImage ? 1.5 : 1,
            ),
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: AppRadii.adminControl,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => _buildUploadPlaceholder(),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          onPressed: () {
                            widget.onImageUrlChanged(null);
                            _customUrlController.clear();
                          },
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : _buildUploadPlaceholder(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _customUrlController,
                hintText: 'Paste direct Image URL or Storage link...',
                prefixIcon: const Icon(Icons.image_search_rounded, size: 20, color: AppColors.adminSecondaryText),
                onChanged: (v) {
                  widget.onImageUrlChanged(v.trim().isEmpty ? null : v.trim());
                },
              ),
            ),
            const SizedBox(width: 8),
            AppButton.adminPrimary(
              label: 'Apply',
              height: AppSpacing.adminControlHeight,
              onPressed: () {
                final url = _customUrlController.text.trim();
                if (url.isNotEmpty) {
                  widget.onImageUrlChanged(url);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Banner image URL set!')),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.adminPurpleLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_rounded, color: AppColors.adminPurple, size: 24),
          ),
          const SizedBox(height: 8),
          const Text(
            'Drag & drop banner creative or enter URL below',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.adminPrimaryText,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'PNG, JPG, WebP supported up to 5MB (1200x500 standard)',
            style: TextStyle(fontSize: 11, color: AppColors.adminSecondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return AppTextField(
      controller: widget.titleController,
      hintText: 'Banner Title * (e.g. 🎯 Live Mock Test Extravaganza)',
      prefixIcon: const Icon(Icons.title_rounded, size: 20, color: AppColors.adminSecondaryText),
    );
  }

  Widget _buildLinkField() {
    return AppTextField(
      controller: widget.linkController,
      hintText: 'Target Link / Route * (e.g. /tests or /contests)',
      prefixIcon: const Icon(Icons.link_rounded, size: 20, color: AppColors.adminSecondaryText),
    );
  }

  Widget _buildBannerTypeSelector() {
    final types = [
      {'value': 'promotional', 'label': 'Type: Promotional'},
      {'value': 'educational', 'label': 'Type: Educational'},
      {'value': 'seasonal', 'label': 'Type: Seasonal'},
      {'value': 'festival', 'label': 'Type: Festival'},
      {'value': 'referral', 'label': 'Type: Referral Offer'},
      {'value': 'announcement', 'label': 'Type: System Announcement'},
    ];

    return AppDropdown<String>(
      hint: 'Banner Type *',
      prefixIcon: const Icon(Icons.category_rounded, size: 18, color: AppColors.adminSecondaryText),
      value: widget.bannerType,
      height: AppSpacing.adminControlHeight,
      borderRadius: AppRadii.adminControl,
      items: types.map((t) {
        return AppDropdownItem<String>(
          value: t['value']!,
          label: t['label']!,
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) widget.onBannerTypeChanged(v);
      },
    );
  }

  Widget _buildDisplayModeSelector() {
    final modes = [
      {'value': 'home_carousel', 'label': 'Placement: Home Screen Carousel'},
      {'value': 'test_series', 'label': 'Placement: Test Series Section'},
      {'value': 'contest_spotlight', 'label': 'Placement: Contests Spotlight'},
      {'value': 'category_header', 'label': 'Placement: Category Top Header'},
      {'value': 'popup_modal', 'label': 'Placement: Pop-up Modal on Launch'},
    ];

    return AppDropdown<String>(
      hint: 'Display Mode / Placement *',
      prefixIcon: const Icon(Icons.view_carousel_rounded, size: 18, color: AppColors.adminSecondaryText),
      value: widget.displayMode,
      height: AppSpacing.adminControlHeight,
      borderRadius: AppRadii.adminControl,
      items: modes.map((m) {
        return AppDropdownItem<String>(
          value: m['value']!,
          label: m['label']!,
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) widget.onDisplayModeChanged(v);
      },
    );
  }
}
