// Supabase Edge Function: submit-quiz
// Purpose: Privileged server-side scoring and attempt finalization.
// Prevents client tampering of test scores, coin rewards, or accuracy.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface SubmitQuizPayload {
  testId: string;
  answers: Record<string, number>; // questionId -> selectedOptionIndex (0-3)
  timeTakenSeconds: number;
}

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing Authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Initialize Supabase Client with caller's JWT
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    // Verify user identity
    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized user session" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body: SubmitQuizPayload = await req.json();
    const { testId, answers, timeTakenSeconds } = body;

    if (!testId || !answers) {
      return new Response(JSON.stringify({ error: "Invalid test submission payload" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Use Service Role client to retrieve true answer keys (RLS may hide correct answers during active test)
    const adminClient = createClient(supabaseUrl, supabaseServiceKey);

    // 1. Fetch Test configuration
    const { data: test, error: testError } = await adminClient
      .from("tests")
      .select("id, title, total_marks, negative_mark_per_wrong, passing_marks")
      .eq("id", testId)
      .single();

    if (testError || !test) {
      return new Response(JSON.stringify({ error: "Test not found" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 2. Fetch all true questions for this test
    const { data: questions, error: qError } = await adminClient
      .from("questions")
      .select("id, correct_answer_index, marks_positive, marks_negative")
      .eq("test_id", testId);

    if (qError || !questions) {
      return new Response(JSON.stringify({ error: "Failed to load test questions" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 3. Compute Official Server-Verified Score
    let correctCount = 0;
    let wrongCount = 0;
    let skippedCount = 0;
    let rawScore = 0.0;

    for (const q of questions) {
      const selected = answers[q.id];
      if (selected === undefined || selected === null || selected === -1) {
        skippedCount++;
        continue;
      }

      if (selected === q.correct_answer_index) {
        correctCount++;
        rawScore += Number(q.marks_positive || 1.0);
      } else {
        wrongCount++;
        const neg = Number(q.marks_negative || test.negative_mark_per_wrong || 0.0);
        rawScore -= neg;
      }
    }

    const totalQuestions = questions.length;
    const attemptedCount = correctCount + wrongCount;
    const accuracy = attemptedCount > 0 ? (correctCount / attemptedCount) * 100.0 : 0.0;
    const finalScore = Math.max(0.0, Math.round(rawScore * 100) / 100);
    const isPassed = finalScore >= (test.passing_marks || 0);

    // 4. Save Attempt Record via RPC or direct insert
    const { data: attempt, error: attemptError } = await adminClient
      .from("quiz_attempts")
      .insert({
        user_id: user.id,
        test_id: testId,
        score: finalScore,
        accuracy: Math.round(accuracy * 10) / 10,
        total_questions: totalQuestions,
        correct_answers: correctCount,
        wrong_answers: wrongCount,
        skipped_answers: skippedCount,
        time_taken_seconds: timeTakenSeconds || 0,
        status: "completed",
        completed_at: new Date().toISOString(),
        user_responses: answers,
      })
      .select()
      .single();

    if (attemptError) {
      return new Response(JSON.stringify({ error: "Failed to persist attempt record" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({
        success: true,
        attemptId: attempt.id,
        score: finalScore,
        accuracy: Math.round(accuracy * 10) / 10,
        totalQuestions,
        correctCount,
        wrongCount,
        skippedCount,
        isPassed,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message || "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
