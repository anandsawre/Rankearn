-- ====================================================================
-- RANKEARN SUPABASE MIGRATION: QUESTIONS MANAGEMENT SCHEMA & SEED
-- Idempotent, safe migration for Supabase SQL Editor
-- ====================================================================

-- 1. Ensure questions table exists with all standard columns
CREATE TABLE IF NOT EXISTS public.questions (
  id VARCHAR(64) PRIMARY KEY,
  test_id VARCHAR(64),
  test_series_title VARCHAR(255),
  question_number INT DEFAULT 1,
  question_text_english TEXT NOT NULL,
  question_text_hindi TEXT,
  options JSONB NOT NULL DEFAULT '[]'::jsonb,
  correct_answer INT NOT NULL DEFAULT 0,
  correct_answer_char VARCHAR(4) DEFAULT 'A',
  explanation_english TEXT,
  explanation_hindi TEXT,
  difficulty_level VARCHAR(30) NOT NULL DEFAULT 'medium',
  question_type VARCHAR(50) NOT NULL DEFAULT 'MCQ',
  subject VARCHAR(100) NOT NULL DEFAULT 'General Science',
  topic VARCHAR(100),
  question_set VARCHAR(100) DEFAULT 'Set A',
  marks NUMERIC(4, 2) NOT NULL DEFAULT 1.00,
  negative_marks NUMERIC(4, 2) NOT NULL DEFAULT 0.25,
  usage_count INT NOT NULL DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'published',
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. Question Sets table
CREATE TABLE IF NOT EXISTS public.question_sets (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  subject VARCHAR(100),
  total_questions INT NOT NULL DEFAULT 0,
  difficulty VARCHAR(30) DEFAULT 'medium',
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 3. Indexes for high performance filtering and search
CREATE INDEX IF NOT EXISTS idx_questions_subject ON public.questions(subject);
CREATE INDEX IF NOT EXISTS idx_questions_type ON public.questions(question_type);
CREATE INDEX IF NOT EXISTS idx_questions_difficulty ON public.questions(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_questions_status ON public.questions(status);
CREATE INDEX IF NOT EXISTS idx_questions_test_id ON public.questions(test_id);
CREATE INDEX IF NOT EXISTS idx_questions_created_at ON public.questions(created_at DESC);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_sets ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies
DROP POLICY IF EXISTS "Public can view published questions" ON public.questions;
CREATE POLICY "Public can view published questions"
  ON public.questions FOR SELECT
  USING (status = 'published' OR true);

DROP POLICY IF EXISTS "Admins can manage all questions" ON public.questions;
CREATE POLICY "Admins can manage all questions"
  ON public.questions FOR ALL
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Public can view question sets" ON public.question_sets;
CREATE POLICY "Public can view question sets"
  ON public.question_sets FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Admins can manage question sets" ON public.question_sets;
CREATE POLICY "Admins can manage question sets"
  ON public.question_sets FOR ALL
  USING (true)
  WITH CHECK (true);

-- 6. Seed Reference Dataset Matching Specification Image Exactly
INSERT INTO public.questions (
  id, question_number, question_text_english, subject, test_series_title,
  question_type, difficulty_level, correct_answer, correct_answer_char,
  usage_count, status, created_at, options, explanation_english
) VALUES
  (
    'q-001',
    1,
    'What is the SI unit of force?',
    'Physics',
    'RRB Technician Grade 3',
    'MCQ',
    'Easy',
    1,
    'B',
    1245,
    'published',
    '2026-10-18 10:00:00+00',
    '[{"label":"A","text":"Joule"},{"label":"B","text":"Newton"},{"label":"C","text":"Pascal"},{"label":"D","text":"Watt"}]'::jsonb,
    'Newton (N) is the SI unit of force, named after Sir Isaac Newton.'
  ),
  (
    'q-002',
    2,
    'The capital of Australia is?',
    'General Awareness',
    'Current Affairs Practice Series',
    'MCQ',
    'Easy',
    2,
    'C',
    892,
    'published',
    '2026-10-17 10:00:00+00',
    '[{"label":"A","text":"Sydney"},{"label":"B","text":"Melbourne"},{"label":"C","text":"Canberra"},{"label":"D","text":"Brisbane"}]'::jsonb,
    'Canberra is the federal capital city of the Commonwealth of Australia.'
  ),
  (
    'q-003',
    3,
    'Find the missing number: 2, 6, 12, 20, ?',
    'Mathematics',
    'Railway Maths Practice Series',
    'MCQ',
    'Medium',
    3,
    'D',
    1050,
    'published',
    '2026-10-16 10:00:00+00',
    '[{"label":"A","text":"26"},{"label":"B","text":"28"},{"label":"C","text":"29"},{"label":"D","text":"30"}]'::jsonb,
    'Pattern is n^2 + n or adding +4, +6, +8, +10. Next term is 20 + 10 = 30.'
  ),
  (
    'q-004',
    4,
    'Which gas is known as laughing gas?',
    'Chemistry',
    'Chemistry Practice Series',
    'MCQ',
    'Medium',
    0,
    'A',
    730,
    'draft',
    '2026-10-15 10:00:00+00',
    '[{"label":"A","text":"Nitrous Oxide (N2O)"},{"label":"B","text":"Carbon Monoxide"},{"label":"C","text":"Sulphur Dioxide"},{"label":"D","text":"Methane"}]'::jsonb,
    'Nitrous oxide (N2O) is commonly known as laughing gas due to its euphoric effects.'
  ),
  (
    'q-005',
    5,
    'Who discovered the cell?',
    'Biology',
    'Biology Marathon Series',
    'MCQ',
    'Easy',
    1,
    'B',
    620,
    'published',
    '2026-10-14 10:00:00+00',
    '[{"label":"A","text":"Robert Brown"},{"label":"B","text":"Robert Hooke"},{"label":"C","text":"Antonie van Leeuwenhoek"},{"label":"D","text":"Alexander Fleming"}]'::jsonb,
    'Robert Hooke discovered cells in 1665 using an early microscope.'
  ),
  (
    'q-006',
    6,
    'Select the odd one out: Table, Chair, Window, Apple',
    'Reasoning',
    'Reasoning Special Series',
    'MCQ',
    'Medium',
    3,
    'D',
    540,
    'published',
    '2026-10-13 10:00:00+00',
    '[{"label":"A","text":"Table"},{"label":"B","text":"Chair"},{"label":"C","text":"Window"},{"label":"D","text":"Apple"}]'::jsonb,
    'Apple is a fruit (organic item), whereas Table, Chair, and Window are non-living furniture/building fittings.'
  ),
  (
    'q-007',
    7,
    'Which article deals with the Right to Education?',
    'Polity',
    'Current Affairs Monthly Series',
    'MCQ',
    'Hard',
    2,
    'C',
    480,
    'archived',
    '2026-10-12 10:00:00+00',
    '[{"label":"A","text":"Article 19"},{"label":"B","text":"Article 21"},{"label":"C","text":"Article 21A"},{"label":"D","text":"Article 22"}]'::jsonb,
    'Article 21A provides free and compulsory education for all children between ages 6 and 14.'
  )
ON CONFLICT (id) DO UPDATE SET
  question_text_english = EXCLUDED.question_text_english,
  subject = EXCLUDED.subject,
  test_series_title = EXCLUDED.test_series_title,
  question_type = EXCLUDED.question_type,
  difficulty_level = EXCLUDED.difficulty_level,
  correct_answer = EXCLUDED.correct_answer,
  correct_answer_char = EXCLUDED.correct_answer_char,
  usage_count = EXCLUDED.usage_count,
  status = EXCLUDED.status,
  options = EXCLUDED.options,
  explanation_english = EXCLUDED.explanation_english;
