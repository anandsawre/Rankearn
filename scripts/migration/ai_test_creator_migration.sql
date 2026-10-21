-- ============================================================================
-- Rankearn Admin Panel — AI Test Creator Database Schema & Migration
-- Tables: ai_generated_tests, ai_test_questions, ai_test_templates
-- ============================================================================

-- 1. Create ai_generated_tests Table
CREATE TABLE IF NOT EXISTS public.ai_generated_tests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    row_number INTEGER,
    title TEXT NOT NULL,
    subtitle TEXT,
    subject TEXT NOT NULL DEFAULT 'General Science',
    difficulty TEXT NOT NULL DEFAULT 'Medium',
    question_count INTEGER NOT NULL DEFAULT 50,
    duration_minutes INTEGER NOT NULL DEFAULT 60,
    status TEXT NOT NULL DEFAULT 'Published',
    created_on TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by TEXT NOT NULL DEFAULT 'Admin',
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Create ai_test_questions Table
CREATE TABLE IF NOT EXISTS public.ai_test_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_id UUID NOT NULL REFERENCES public.ai_generated_tests(id) ON DELETE CASCADE,
    question_number INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    question_text_hi TEXT,
    options JSONB NOT NULL,
    correct_option_index INTEGER NOT NULL DEFAULT 0,
    explanation TEXT,
    explanation_hi TEXT,
    subject TEXT,
    difficulty TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Create ai_test_templates Table
CREATE TABLE IF NOT EXISTS public.ai_test_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    subject TEXT NOT NULL,
    default_difficulty TEXT NOT NULL DEFAULT 'Medium',
    default_question_count INTEGER NOT NULL DEFAULT 50,
    default_duration_minutes INTEGER NOT NULL DEFAULT 60,
    target_exam TEXT NOT NULL DEFAULT 'Competitive Exam',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Indexes for fast search, subject, status and date queries
CREATE INDEX IF NOT EXISTS idx_ai_generated_tests_subject ON public.ai_generated_tests(subject);
CREATE INDEX IF NOT EXISTS idx_ai_generated_tests_difficulty ON public.ai_generated_tests(difficulty);
CREATE INDEX IF NOT EXISTS idx_ai_generated_tests_status ON public.ai_generated_tests(status);
CREATE INDEX IF NOT EXISTS idx_ai_generated_tests_created_on ON public.ai_generated_tests(created_on DESC);
CREATE INDEX IF NOT EXISTS idx_ai_test_questions_test_id ON public.ai_test_questions(test_id);

-- 5. Row Level Security Policies
ALTER TABLE public.ai_generated_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_test_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_test_templates ENABLE ROW LEVEL SECURITY;

DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'ai_generated_tests' AND policyname = 'Admins can manage ai_generated_tests'
    ) THEN
        CREATE POLICY "Admins can manage ai_generated_tests" 
        ON public.ai_generated_tests 
        FOR ALL 
        USING (auth.jwt() ->> 'role' = 'service_role' OR auth.role() = 'authenticated')
        WITH CHECK (auth.jwt() ->> 'role' = 'service_role' OR auth.role() = 'authenticated');
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'ai_test_questions' AND policyname = 'Admins can manage ai_test_questions'
    ) THEN
        CREATE POLICY "Admins can manage ai_test_questions" 
        ON public.ai_test_questions 
        FOR ALL 
        USING (auth.jwt() ->> 'role' = 'service_role' OR auth.role() = 'authenticated')
        WITH CHECK (auth.jwt() ->> 'role' = 'service_role' OR auth.role() = 'authenticated');
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'ai_test_templates' AND policyname = 'Admins can manage ai_test_templates'
    ) THEN
        CREATE POLICY "Admins can manage ai_test_templates" 
        ON public.ai_test_templates 
        FOR ALL 
        USING (auth.jwt() ->> 'role' = 'service_role' OR auth.role() = 'authenticated')
        WITH CHECK (auth.jwt() ->> 'role' = 'service_role' OR auth.role() = 'authenticated');
    END IF;
END $$;

-- 6. Seed Data Matching Canonical Reference Screenshot
INSERT INTO public.ai_generated_tests 
(id, row_number, title, subtitle, subject, difficulty, question_count, duration_minutes, status, created_on, created_by)
VALUES
('a1111111-1111-1111-1111-111111111111', 1, 'RRB Technician Mock Test', 'AI generated full syllabus test', 'General Science', 'Medium', 50, 60, 'Published', '2026-10-18 10:30:00+00', 'Admin'),
('a2222222-2222-2222-2222-222222222222', 2, 'Railway Maths Practice Test', 'Topic wise AI generated test', 'Mathematics', 'Easy', 40, 45, 'Published', '2026-10-17 11:15:00+00', 'Admin'),
('a3333333-3333-3333-3333-333333333333', 3, 'Reasoning Speed Test', 'AI generated mixed questions', 'Reasoning', 'Hard', 60, 60, 'Draft', '2026-10-15 14:20:00+00', 'Admin'),
('a4444444-4444-4444-4444-444444444444', 4, 'Current Affairs Weekly Test', 'Latest current affairs questions', 'Current Affairs', 'Medium', 50, 45, 'Published', '2026-10-12 09:00:00+00', 'Admin'),
('a5555555-5555-5555-5555-555555555555', 5, 'Chemistry Chapter Test', 'Chapter wise practice test', 'Chemistry', 'Medium', 40, 40, 'Published', '2026-10-10 16:45:00+00', 'Admin'),
('a6666666-6666-6666-6666-666666666666', 6, 'Biology NEET Practice Test', 'AI generated NEET pattern test', 'Biology', 'Hard', 75, 90, 'Published', '2026-10-08 12:00:00+00', 'Admin'),
('a7777777-7777-7777-7777-777777777777', 7, 'Full Syllabus Combined Test', 'AI generated mixed subject test', 'Mixed', 'Medium', 100, 120, 'Processing', '2026-10-05 15:30:00+00', 'Admin')
ON CONFLICT (id) DO NOTHING;
