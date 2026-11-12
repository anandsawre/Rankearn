import 'package:flutter/material.dart';

/// Supported Material icons for Target Exams stored by key in `exam_categories.icon_url`.
const List<({String key, String label, IconData icon})> kExamIconOptions = [
  (key: 'school', label: 'Education', icon: Icons.school_rounded),
  (key: 'account_balance', label: 'Civil Services', icon: Icons.account_balance_rounded),
  (key: 'assignment', label: 'Exam Paper', icon: Icons.assignment_rounded),
  (key: 'train', label: 'Railways', icon: Icons.train_rounded),
  (key: 'savings', label: 'Banking', icon: Icons.savings_rounded),
  (key: 'military_tech', label: 'Defence', icon: Icons.military_tech_rounded),
  (key: 'menu_book', label: 'Syllabus', icon: Icons.menu_book_rounded),
  (key: 'gavel', label: 'Law & Judiciary', icon: Icons.gavel_rounded),
  (key: 'gps_fixed', label: 'Target', icon: Icons.gps_fixed_rounded),
  (key: 'science', label: 'Science', icon: Icons.science_rounded),
  (key: 'medical_services', label: 'Medical', icon: Icons.medical_services_rounded),
  (key: 'bolt', label: 'Engineering', icon: Icons.bolt_rounded),
  (key: 'emoji_events', label: 'Trophy', icon: Icons.emoji_events_rounded),
  (key: 'public', label: 'General', icon: Icons.public_rounded),
];

/// Maps stored icon keys (or fallback legacy values) to a Material [IconData].
IconData? resolveExamIconData(String? key) {
  if (key == null) return Icons.school_rounded;
  final clean = key.trim();
  if (clean.isEmpty) return Icons.school_rounded;
  for (final option in kExamIconOptions) {
    if (option.key == clean) return option.icon;
  }
  return null;
}

/// Renders an exam icon from a Material icon key, network/asset URL, or legacy emoji.
Widget buildExamIconWidget(
  String? iconUrl, {
  double size = 20,
  Color color = const Color(0xFFFF9500),
}) {
  final clean = iconUrl?.trim() ?? '';
  if (clean.isEmpty) {
    return Icon(Icons.school_rounded, size: size, color: color);
  }
  if (clean.startsWith('http://') || clean.startsWith('https://')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        clean,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(Icons.school_rounded, size: size, color: color),
      ),
    );
  }
  if (clean.startsWith('assets/')) {
    return Image.asset(
      clean,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(Icons.school_rounded, size: size, color: color),
    );
  }
  final iconData = resolveExamIconData(clean);
  if (iconData != null) {
    return Icon(iconData, size: size, color: color);
  }
  return Text(clean, style: TextStyle(fontSize: size - 2));
}

