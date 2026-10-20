-- ============================================================================
-- Rankearn Admin Panel: Users Management Migration & Schema Definition
-- ============================================================================

-- 1. Ensure public.profiles table exists with all admin management columns
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL DEFAULT 'Candidate',
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    profile_photo_url TEXT,
    role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'premium', 'teacher', 'moderator', 'admin')),
    enrollments_count INT NOT NULL DEFAULT 0,
    tests_attempted_count INT NOT NULL DEFAULT 0,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked')),
    coins INT NOT NULL DEFAULT 50,
    total_earned INT NOT NULL DEFAULT 0,
    total_spent INT NOT NULL DEFAULT 0,
    withdrawable_balance NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Ensure optional columns exist if table was already created
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'student';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS enrollments_count INT NOT NULL DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS tests_attempted_count INT NOT NULL DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_active_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'active';

-- 2. User Activity Audit Log Table
CREATE TABLE IF NOT EXISTS public.user_activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    user_name TEXT NOT NULL,
    action_type TEXT NOT NULL CHECK (action_type IN ('registered', 'upgraded_premium', 'completed_test', 'profile_updated', 'account_blocked', 'role_changed')),
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Indexes for fast filtering, search, and pagination
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_status ON public.profiles(status);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_name ON public.profiles(name);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_activity_logs_created_at ON public.user_activity_logs(created_at DESC);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_activity_logs ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies
DROP POLICY IF EXISTS "Public can view active profiles" ON public.profiles;
CREATE POLICY "Public can view active profiles" ON public.profiles
    FOR SELECT USING (status != 'blocked');

DROP POLICY IF EXISTS "Admins have full CRUD access to profiles" ON public.profiles;
CREATE POLICY "Admins have full CRUD access to profiles" ON public.profiles
    FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Admins have full CRUD access to user_activity_logs" ON public.user_activity_logs;
CREATE POLICY "Admins have full CRUD access to user_activity_logs" ON public.user_activity_logs
    FOR ALL USING (true) WITH CHECK (true);

-- 6. Seed Data Matching Exact Visual Reference Specification
INSERT INTO public.profiles (id, name, email, phone, role, enrollments_count, tests_attempted_count, last_active_at, status, created_at)
VALUES 
    ('11111111-1111-1111-1111-111111111101', 'Rahul Sharma', 'rahul.sharma@example.com', '+91 98765 43210', 'student', 12, 48, NOW(), 'active', '2026-10-18 10:30:00+00'),
    ('11111111-1111-1111-1111-111111111102', 'Priya Verma', 'priya.verma@example.com', '+91 98765 43211', 'student', 8, 32, NOW() - INTERVAL '5 minutes', 'active', '2026-10-17 11:15:00+00'),
    ('11111111-1111-1111-1111-111111111103', 'Amit Kumar', 'amit.kumar@example.com', '+91 98765 43212', 'premium', 28, 124, NOW() - INTERVAL '1 hour', 'active', '2026-10-16 09:45:00+00'),
    ('11111111-1111-1111-1111-111111111104', 'Neha Singh', 'neha.singh@example.com', '+91 98765 43213', 'student', 5, 18, NOW() - INTERVAL '3 hours', 'active', '2026-10-15 14:20:00+00'),
    ('11111111-1111-1111-1111-111111111105', 'Vikash Yadav', 'vikash.yadav@example.com', '+91 98765 43214', 'student', 15, 62, NOW() - INTERVAL '6 hours', 'inactive', '2026-10-14 16:50:00+00'),
    ('11111111-1111-1111-1111-111111111106', 'Anjali Patel', 'anjali.patel@example.com', '+91 98765 43215', 'premium', 22, 96, NOW() - INTERVAL '1 day', 'active', '2026-10-13 12:10:00+00'),
    ('11111111-1111-1111-1111-111111111107', 'Saurabh Gupta', 'saurabh.gupta@example.com', '+91 98765 43216', 'student', 0, 0, NOW() - INTERVAL '2 days', 'blocked', '2026-10-12 08:30:00+00')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    enrollments_count = EXCLUDED.enrollments_count,
    tests_attempted_count = EXCLUDED.tests_attempted_count,
    status = EXCLUDED.status;

-- 7. Seed Recent Activity Logs
INSERT INTO public.user_activity_logs (user_name, action_type, description, created_at)
VALUES
    ('Rahul Sharma', 'registered', 'New user registered: Rahul Sharma', NOW() - INTERVAL '5 minutes'),
    ('Priya Verma', 'upgraded_premium', 'User upgraded to premium: Priya Verma', NOW() - INTERVAL '1 hour'),
    ('Amit Kumar', 'completed_test', 'User completed test: Amit Kumar', NOW() - INTERVAL '2 hours'),
    ('Neha Singh', 'profile_updated', 'User profile updated: Neha Singh', NOW() - INTERVAL '3 hours'),
    ('Saurabh Gupta', 'account_blocked', 'User account blocked: Saurabh Gupta', NOW() - INTERVAL '5 hours');
