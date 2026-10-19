-- ====================================================================
-- RANK EARN SAFE LOCAL/DEV SEED DATA
-- ====================================================================

-- 1. App Configurations
INSERT INTO public.app_configs (key, value) VALUES
  ('payment_settings', '{
    "upiId": "rankearn@upi",
    "merchantName": "Rankearn Official",
    "qrNote": "Enter exact amount and copy 12-digit UTR below",
    "coinsPerRupee": 20
  }'::jsonb),
  ('withdrawal_settings', '{
    "minCoins": 1000,
    "isUPIEnabled": true,
    "isBankEnabled": true,
    "feePercentage": 0,
    "withdrawalNote": "Withdrawals are processed within 24 hours directly to your UPI ID or Bank account.",
    "coinsPerRupee": 20
  }'::jsonb),
  ('lucky_wheel', '{
    "isActive": true,
    "spinCost": 0,
    "slices": [
      { "label": "5 Coins", "value": 5, "type": "coins", "color": "#10b981", "probability": 30 },
      { "label": "10 Coins", "value": 10, "type": "coins", "color": "#3b82f6", "probability": 25 },
      { "label": "25 Coins", "value": 25, "type": "coins", "color": "#6366f1", "probability": 15 },
      { "label": "Try Again", "value": 0, "type": "nothing", "color": "#64748b", "probability": 10 },
      { "label": "50 Coins", "value": 50, "type": "coins", "color": "#f59e0b", "probability": 10 },
      { "label": "5 Coins", "value": 5, "type": "coins", "color": "#10b981", "probability": 5 },
      { "label": "100 Coins", "value": 100, "type": "coins", "color": "#f43f5e", "probability": 3 },
      { "label": "10 Coins", "value": 10, "type": "coins", "color": "#3b82f6", "probability": 2 }
    ]
  }'::jsonb),
  ('referral_settings', '{
    "isActive": true,
    "referrerReward": 50,
    "refereeReward": 25,
    "commissionRate": 5,
    "minWithdrawal": 1000
  }'::jsonb),
  ('auth_settings', '{
    "requireEmailVerification": false
  }'::jsonb),
  ('feature_flags', '{
    "showSubscriptionTab": true
  }'::jsonb),
  ('battle_settings', '{
    "totalQuestions": 5,
    "timePerQuestion": 10,
    "botAccuracy": 0.65,
    "prizeMultiplier": 1.8,
    "entryStakes": [10, 50, 100]
  }'::jsonb)
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- 2. Exam Categories
INSERT INTO public.exam_categories (id, name, normalized_name, icon_url, display_order) VALUES
  ('bpsc', 'BPSC', 'bpsc', 'https://api.dicebear.com/7.x/identicon/svg?seed=bpsc', 1),
  ('ssc', 'SSC CGL', 'ssc', 'https://api.dicebear.com/7.x/identicon/svg?seed=ssc', 2),
  ('upsc', 'UPSC CSE', 'upsc', 'https://api.dicebear.com/7.x/identicon/svg?seed=upsc', 3),
  ('railway', 'Railway RRB', 'railway', 'https://api.dicebear.com/7.x/identicon/svg?seed=rrb', 4),
  ('banking', 'Banking IBPS', 'banking', 'https://api.dicebear.com/7.x/identicon/svg?seed=banking', 5)
ON CONFLICT (id) DO NOTHING;

-- 3. Subjects / Categories
INSERT INTO public.categories (id, name, exam_category_id, topics) VALUES
  ('cat_history', 'Indian History', 'bpsc', ARRAY['Ancient History', 'Medieval India', 'Modern Freedom Struggle']),
  ('cat_polity', 'Indian Polity', 'upsc', ARRAY['Preamble', 'Fundamental Rights', 'Directive Principles']),
  ('cat_quant', 'Quantitative Aptitude', 'ssc', ARRAY['Percentages', 'Profit & Loss', 'Time & Work', 'Algebra']),
  ('cat_science', 'General Science', 'railway', ARRAY['Physics', 'Chemistry', 'Biology'])
ON CONFLICT (id) DO NOTHING;

-- 4. Sample Test Series
INSERT INTO public.tests (
  id, title, exam_category_id, category_id, test_mode, duration_minutes,
  total_questions, negative_marking, is_premium, status, is_tournament, entry_fee_coins
) VALUES
  ('test_bpsc_mock_1', '70th BPSC Prelims Full Mock Test 1', 'bpsc', 'cat_history', 'mock', 120, 5, 0.25, false, 'published', false, 0),
  ('test_ssc_cgl_live', 'SSC CGL Grand Championship Tournament 🏆', 'ssc', 'cat_quant', 'tournament', 30, 5, 0.50, false, 'published', true, 20)
ON CONFLICT (id) DO NOTHING;

-- 5. Sample Questions for BPSC Mock 1
INSERT INTO public.questions (
  id, test_id, question_number, question_text_english, question_text_hindi, options, correct_answer, explanation_english, subject, topic
) VALUES
  ('q_bpsc_1', 'test_bpsc_mock_1', 1,
   'Who was the founder of the Maurya Empire?',
   'मौर्य साम्राज्य के संस्थापक कौन थे?',
   '[{"textEnglish": "Chandragupta Maurya", "textHindi": "चन्द्रगुप्त मौर्य"}, {"textEnglish": "Ashoka", "textHindi": "अशोक"}, {"textEnglish": "Bindusara", "textHindi": "बिन्दुसार"}, {"textEnglish": "Bimbisara", "textHindi": "बिम्बिसार"}]'::jsonb,
   0, 'Chandragupta Maurya founded the Maurya Empire in 322 BCE with the guidance of Chanakya.', 'History', 'Ancient History'),
  ('q_bpsc_2', 'test_bpsc_mock_1', 2,
   'Which article of the Indian Constitution deals with the Right to Equality?',
   'भारतीय संविधान का कौन सा अनुच्छेद समानता के अधिकार से संबंधित है?',
   '[{"textEnglish": "Article 12", "textHindi": "अनुच्छेद 12"}, {"textEnglish": "Article 14", "textHindi": "अनुच्छेद 14"}, {"textEnglish": "Article 19", "textHindi": "अनुच्छेद 19"}, {"textEnglish": "Article 21", "textHindi": "अनुच्छेद 21"}]'::jsonb,
   1, 'Article 14 guarantees equality before the law and equal protection of the laws.', 'Polity', 'Fundamental Rights')
ON CONFLICT (id) DO NOTHING;

-- 6. Sample Promotional Banner
INSERT INTO public.app_banners (id, image_url, title, link, is_active, priority) VALUES
  ('banner_welcome', 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=1200&auto=format&fit=crop', 'Rankearn Championship League', '/earn', true, 1)
ON CONFLICT (id) DO NOTHING;
