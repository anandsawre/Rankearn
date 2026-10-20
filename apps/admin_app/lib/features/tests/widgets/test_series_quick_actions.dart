import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

/// Rankearn Quick Actions Card
/// Recreates the 5 squircle actions, header with lightning icon, and customize pill.
class TestSeriesQuickActions extends StatelessWidget {
  final VoidCallback onCreateTestSeries;
  final VoidCallback onAddTestPaper;
  final VoidCallback onManageSubjects;
  final VoidCallback onImportTests;
  final VoidCallback onAiGenerate;

  const TestSeriesQuickActions({
    super.key,
    required this.onCreateTestSeries,
    required this.onAddTestPaper,
    required this.onManageSubjects,
    required this.onImportTests,
    required this.onAiGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 124,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle, width: 1.2),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Quick Actions + Customize Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7ED),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Color(0xFFF59E0B),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                borderRadius: AppRadii.borderMd,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Customize Quick Actions layout preferences.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.borderMd,
                    border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings_outlined, size: 11, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text(
                        'Customize',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),

          // 5 Quick Action Buttons in Row
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  bgColor: const Color(0xFFF5F6FF),
                  iconBgColor: const Color(0xFF5C4EFA),
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Create\nTest Series',
                  onTap: onCreateTestSeries,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickActionButton(
                  bgColor: const Color(0xFFF0F8FF),
                  iconBgColor: const Color(0xFF0084FF),
                  icon: Icons.description_outlined,
                  label: 'Add\nTest Paper',
                  onTap: onAddTestPaper,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickActionButton(
                  bgColor: const Color(0xFFF0FDF4),
                  iconBgColor: const Color(0xFF00B368),
                  icon: Icons.folder_outlined,
                  label: 'Manage\nSubjects',
                  onTap: onManageSubjects,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickActionButton(
                  bgColor: const Color(0xFFFFFBF0),
                  iconBgColor: const Color(0xFFFF9500),
                  icon: Icons.cloud_upload_outlined,
                  label: 'Import\nTests',
                  onTap: onImportTests,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickActionButton(
                  bgColor: const Color(0xFFFFF0F6),
                  iconBgColor: const Color(0xFFFF3385),
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Generate\nTest Series',
                  onTap: onAiGenerate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final Color bgColor;
  final Color iconBgColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.bgColor,
    required this.iconBgColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 74,
          decoration: BoxDecoration(
            color: _isHovered ? widget.bgColor.withAlpha(240) : widget.bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? widget.iconBgColor.withAlpha(80)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.iconBgColor,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: widget.iconBgColor.withAlpha(70),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
