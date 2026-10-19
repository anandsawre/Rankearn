import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://jybjomgwmabouahvvcuo.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp5YmpvbWd3bWFib3VhaHZ2Y3VvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0MzIwNDksImV4cCI6MjA5MDAwODA0OX0.Bc8Bw-vGJ3gCrEzV-YsMEl-6PLFSAPBg1hEOM15lKX4';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
