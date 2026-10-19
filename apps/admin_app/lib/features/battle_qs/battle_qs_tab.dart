import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class BattleQsTab extends StatefulWidget {
  const BattleQsTab({super.key});

  @override
  State<BattleQsTab> createState() => _BattleQsTabState();
}

class _BattleQsTabState extends State<BattleQsTab> {
  String _activeSubTab = 'list'; // 'list', 'add_manual', 'bots', 'settings'
  String _searchQuery = '';

  final List<Map<String, dynamic>> _battleQuestions = [
    {
      'id': 'bq-1',
      'qEn': 'Which planet in the solar system is known as the "Red Planet"?',
      'qHi': 'सौरमंडल में किस ग्रह को "लाल ग्रह" के नाम से जाना जाता है?',
      'options': ['Mars (मंगल)', 'Venus (शुक्र)', 'Jupiter (बृहस्पति)', 'Mercury (बुध)'],
      'correctIndex': 0,
      'topic': 'General Science',
      'difficulty': 'Easy',
    },
    {
      'id': 'bq-2',
      'qEn': 'Who authored the ancient Indian political treatise "Arthashastra"?',
      'qHi': 'प्राचीन भारतीय राजनीतिक ग्रंथ "अर्थशास्त्र" के लेखक कौन थे?',
      'options': ['Chanakya (चाणक्य)', 'Kalidasa (कालिदास)', 'Aryabhata (आर्यभट्ट)', 'Banabhatta (बाणभट्ट)'],
      'correctIndex': 0,
      'topic': 'Ancient History',
      'difficulty': 'Moderate',
    },
    {
      'id': 'bq-3',
      'qEn': 'What is the chemical symbol for Gold in the periodic table?',
      'qHi': 'आवर्त सारणी में सोने (Gold) का रासायनिक प्रतीक क्या है?',
      'options': ['Au', 'Ag', 'Fe', 'Pb'],
      'correctIndex': 0,
      'topic': 'Chemistry',
      'difficulty': 'Easy',
    },
  ];

  final List<Map<String, dynamic>> _bots = [
    {'id': 'bot-1', 'name': 'Aditi_PSC', 'avatar': 'A', 'accuracy': '68%', 'isActive': true},
    {'id': 'bot-2', 'name': 'Vikram_Speed', 'avatar': 'V', 'accuracy': '74%', 'isActive': true},
    {'id': 'bot-3', 'name': 'Rohan_SSC', 'avatar': 'R', 'accuracy': '62%', 'isActive': true},
    {'id': 'bot-4', 'name': 'Pooja_Aspirant', 'avatar': 'P', 'accuracy': '80%', 'isActive': true},
  ];

  // Battle configuration
  int _timePerQuestion = 10;
  int _totalQuestions = 5;
  double _prizeMultiplier = 1.8;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Header
          _buildMasterHeader(),
          const SizedBox(height: 20),

          // Sub-navigation Filter Bar
          _buildSubNavFilter(),
          const SizedBox(height: 20),

          // Subtab view switch
          switch (_activeSubTab) {
            'list' => _buildQuestionsListView(),
            'add_manual' => _buildAddManualView(),
            'bots' => _buildBotsView(),
            'settings' => _buildSettingsView(),
            _ => _buildQuestionsListView(),
          },
        ],
      ),
    );
  }

  Widget _buildMasterHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  borderRadius: AppRadii.borderLg,
                  boxShadow: [
                    BoxShadow(color: AppColors.brandPrimary.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.flash_on_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1v1 Battle Arena Question Bank', style: AppTypography.displayMedium),
                  SizedBox(height: 2),
                  Text('Fast-Paced 10-Second MCQ Repository & Matchmaking Bots Roster', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubNavFilter() {
    final tabs = [
      ('list', 'Questions List (${_battleQuestions.length})', Icons.format_list_bulleted),
      ('add_manual', '+ Add Question', Icons.add_circle_outline),
      ('bots', 'Matchmaking Bots (${_bots.length})', Icons.smart_toy_outlined),
      ('settings', 'Arena Settings', Icons.tune),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final isSelected = _activeSubTab == tab.$1;
          return InkWell(
            onTap: () => setState(() => _activeSubTab = tab.$1),
            borderRadius: AppRadii.borderMd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.brandPrimary : Colors.transparent,
                borderRadius: AppRadii.borderMd,
              ),
              child: Row(
                children: [
                  Icon(tab.$3, size: 14, color: isSelected ? Colors.white : const Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    tab.$2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 1. Questions List ---
  Widget _buildQuestionsListView() {
    return Column(
      children: [
        AppTextField(
          hintText: 'Search rapid battle questions by topic or keyword...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 16),
        ..._battleQuestions
            .where((q) =>
                _searchQuery.isEmpty ||
                (q['qEn'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (q['topic'] as String).toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList()
            .asMap()
            .entries
            .map((entry) {
          final idx = entry.key;
          final q = entry.value;
          final options = q['options'] as List<dynamic>;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.borderLg,
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: AppRadii.borderPill,
                          ),
                          child: Text(
                            q['topic'].toUpperCase(),
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.brandPrimaryDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Difficulty: ${q['difficulty']}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                      onPressed: () {
                        setState(() => _battleQuestions.remove(q));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Removed battle question.')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Q${idx + 1}. ${q['qEn']}', style: AppTypography.titleMedium),
                const SizedBox(height: 2),
                Text(q['qHi'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: options.asMap().entries.map((opt) {
                    final isCorrect = opt.key == q['correctIndex'];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCorrect ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                        borderRadius: AppRadii.borderSm,
                        border: Border.all(color: isCorrect ? AppColors.brandPrimary : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCorrect) ...[
                            const Icon(Icons.check, size: 12, color: AppColors.brandPrimary),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            opt.value,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isCorrect ? FontWeight.w800 : FontWeight.normal,
                              color: isCorrect ? AppColors.brandPrimaryDark : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // --- 2. Add Manual Form ---
  Widget _buildAddManualView() {
    final qEnCtrl = TextEditingController();
    final qHiCtrl = TextEditingController();
    final opt1Ctrl = TextEditingController();
    final opt2Ctrl = TextEditingController();
    final opt3Ctrl = TextEditingController();
    final opt4Ctrl = TextEditingController();
    final topicCtrl = TextEditingController(text: 'General Science');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create 1v1 Battle Question', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          AppTextField(label: 'Question in English', controller: qEnCtrl, hintText: 'Enter rapid question...'),
          const SizedBox(height: 12),
          AppTextField(label: 'Question in Hindi', controller: qHiCtrl, hintText: 'हिंदी में प्रश्न दर्ज करें...'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: AppTextField(label: 'Option A (Correct)', controller: opt1Ctrl, hintText: 'Correct Answer')),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(label: 'Option B', controller: opt2Ctrl, hintText: 'Incorrect Answer')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: AppTextField(label: 'Option C', controller: opt3Ctrl, hintText: 'Incorrect Answer')),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(label: 'Option D', controller: opt4Ctrl, hintText: 'Incorrect Answer')),
            ],
          ),
          const SizedBox(height: 14),
          AppTextField(label: 'Topic Category', controller: topicCtrl, hintText: 'General Science, History, Math'),
          const SizedBox(height: 20),
          AppButton(
            label: 'Add to Battle Bank',
            onPressed: () {
              if (qEnCtrl.text.isNotEmpty && opt1Ctrl.text.isNotEmpty) {
                setState(() {
                  _battleQuestions.insert(0, {
                    'id': 'bq-${DateTime.now().millisecondsSinceEpoch}',
                    'qEn': qEnCtrl.text,
                    'qHi': qHiCtrl.text.isEmpty ? qEnCtrl.text : qHiCtrl.text,
                    'options': [opt1Ctrl.text, opt2Ctrl.text, opt3Ctrl.text, opt4Ctrl.text],
                    'correctIndex': 0,
                    'topic': topicCtrl.text,
                    'difficulty': 'Moderate',
                  });
                  _activeSubTab = 'list';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Question added to 1v1 Battle Bank!')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // --- 3. Bots View ---
  Widget _buildBotsView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Simulated AI Matchmaking Candidates', style: AppTypography.titleLarge),
          const SizedBox(height: 4),
          const Text('These bots pair with candidates when no human opponent is queued within 5 seconds.', style: AppTypography.bodySmall),
          const SizedBox(height: 18),

          ..._bots.map((bot) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(bot['avatar'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ),
              title: Text(bot['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('Accuracy Rate: ${bot['accuracy']} • Instant Response Engine', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              trailing: Switch(
                value: bot['isActive'] == true,
                activeTrackColor: AppColors.brandPrimary,
                onChanged: (val) => setState(() => bot['isActive'] = val),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- 4. Settings View ---
  Widget _buildSettingsView() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1v1 Battle Economics & Speed Parameters', style: AppTypography.titleLarge),
          const SizedBox(height: 20),

          Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 240,
                child: AppTextField(
                  label: 'Seconds Per Question',
                  hintText: '10',
                  controller: TextEditingController(text: '$_timePerQuestion'),
                  onChanged: (val) => _timePerQuestion = int.tryParse(val) ?? 10,
                ),
              ),
              SizedBox(
                width: 240,
                child: AppTextField(
                  label: 'Questions Per Match',
                  hintText: '5',
                  controller: TextEditingController(text: '$_totalQuestions'),
                  onChanged: (val) => _totalQuestions = int.tryParse(val) ?? 5,
                ),
              ),
              SizedBox(
                width: 240,
                child: AppTextField(
                  label: 'Winner Payout Multiplier',
                  hintText: '1.8',
                  controller: TextEditingController(text: '$_prizeMultiplier'),
                  onChanged: (val) => _prizeMultiplier = double.tryParse(val) ?? 1.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Save Battle Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Battle arena settings saved.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
