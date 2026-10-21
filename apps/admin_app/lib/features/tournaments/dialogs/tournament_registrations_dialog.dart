import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/tournament_item.dart';

class TournamentRegistrationsDialog extends StatelessWidget {
  final TournamentItem? tournament;

  const TournamentRegistrationsDialog({super.key, this.tournament});

  @override
  Widget build(BuildContext context) {
    final title = tournament != null
        ? 'Registrations: ${tournament!.title}'
        : 'All Tournament Registrations';

    final participants = [
      {'name': 'Rahul Sharma', 'email': 'rahul.s@example.com', 'initials': 'RS', 'color': const Color(0xFF5636F5), 'joined': 'Oct 21, 2026, 04:30 PM', 'fee': '₹0 (Free)', 'status': 'Confirmed', 'rank': 1},
      {'name': 'Pooja Verma', 'email': 'pooja.v@example.com', 'initials': 'PV', 'color': const Color(0xFFF04483), 'joined': 'Oct 21, 2026, 03:15 PM', 'fee': '₹10', 'status': 'Confirmed', 'rank': 2},
      {'name': 'Amit Kumar', 'email': 'amit.k@example.com', 'initials': 'AK', 'color': const Color(0xFF2587F8), 'joined': 'Oct 21, 2026, 02:40 PM', 'fee': '₹0 (Free)', 'status': 'Confirmed', 'rank': 3},
      {'name': 'Sneha Patel', 'email': 'sneha.p@example.com', 'initials': 'SP', 'color': const Color(0xFF00C48C), 'joined': 'Oct 21, 2026, 01:20 PM', 'fee': '₹5', 'status': 'Confirmed', 'rank': 4},
      {'name': 'Vikram Singh', 'email': 'vikram.s@example.com', 'initials': 'VS', 'color': const Color(0xFFFF9F0A), 'joined': 'Oct 20, 2026, 11:10 PM', 'fee': '₹20', 'status': 'Confirmed', 'rank': 5},
      {'name': 'Ananya Mishra', 'email': 'ananya.m@example.com', 'initials': 'AM', 'color': const Color(0xFF8B5CF6), 'joined': 'Oct 20, 2026, 09:45 PM', 'fee': '₹10', 'status': 'Confirmed', 'rank': 6},
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      backgroundColor: Colors.white,
      child: Container(
        width: 680,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9F0A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.group_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const Text(
                          'Verified registrations and entry fee records',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFE2E8F0)),

            SizedBox(
              height: 310,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth = constraints.maxWidth;
                  final participantWidth = (tableWidth * 0.40).clamp(180.0, 300.0);
                  final registeredWidth = (tableWidth * 0.28).clamp(140.0, 200.0);
                  final feeWidth = (tableWidth * 0.16).clamp(80.0, 120.0);
                  final statusWidth = (tableWidth - participantWidth - registeredWidth - feeWidth - 16).clamp(80.0, 140.0);

                  return SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: tableWidth),
                        child: DataTable(
                          headingRowHeight: 38,
                          dataRowMinHeight: 46,
                          dataRowMaxHeight: 52,
                          horizontalMargin: 8,
                          columnSpacing: 0,
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                          border: const TableBorder(
                            horizontalInside: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                          ),
                          columns: [
                            DataColumn(
                              label: SizedBox(
                                width: participantWidth,
                                child: const Text(
                                  'Participant',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: registeredWidth,
                                child: const Text(
                                  'Registered At',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: feeWidth,
                                child: const Text(
                                  'Fee Paid',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: statusWidth,
                                child: const Text(
                                  'Status',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                              ),
                            ),
                          ],
                          rows: participants.map((p) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: participantWidth,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: (p['color'] as Color).withValues(alpha: 0.12),
                                          child: Text(
                                            p['initials'].toString(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: p['color'] as Color,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p['name'].toString(),
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                p['email'].toString(),
                                                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: registeredWidth,
                                    child: Text(
                                      p['joined'].toString(),
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: feeWidth,
                                    child: Text(
                                      p['fee'].toString(),
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: p['fee'].toString().contains('Free') ? const Color(0xFF10B981) : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: statusWidth,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          p['status'].toString(),
                                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
