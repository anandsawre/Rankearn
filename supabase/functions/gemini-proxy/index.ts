// Supabase Edge Function: gemini-proxy
// Purpose: Secure Gemini 1.5 Flash AI proxy for Admin AI Test Creator & Analysis.
// Never exposes GEMINI_API_KEY to client applications.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!jwt) {
      return new Response(JSON.stringify({ error: "Missing Authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Initialize Supabase Admin client to verify caller JWT and Admin role reliably
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    const adminClient = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    const { data: { user }, error: userError } = await adminClient.auth.getUser(jwt);
    if (userError || !user) {
      return new Response(
        JSON.stringify({
          error: "Unauthorized user",
          details: userError?.message || "Invalid or expired access token",
        }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // Verify Admin status in database
    const { data: adminRole } = await adminClient
      .from("user_roles")
      .select("role")
      .eq("user_id", user.id)
      .eq("role", "admin")
      .maybeSingle();

    if (!adminRole) {
      return new Response(JSON.stringify({ error: "Forbidden: Admin role required for AI generation" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      return new Response(JSON.stringify({ error: "Server GEMINI_API_KEY not configured" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json();
    const retiredModels = new Set([
      "gemini-1.5-flash",
      "gemini-2.0-flash",
      "gemini-2.5-flash",
    ]);
    const requestedModel = typeof body.model === "string" && body.model.trim()
      ? body.model.trim()
      : "gemini-3.8-flash";
    const primaryModel = retiredModels.has(requestedModel)
      ? "gemini-3.8-flash"
      : requestedModel;

    const upstreamPayload = {
      contents: body.contents,
      generationConfig: body.generationConfig || {
        temperature: 0.2,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: "application/json",
      },
      systemInstruction: body.systemInstruction,
      safetySettings: body.safetySettings,
    };

    const modelsToTry = primaryModel === "gemini-flash-lite-latest"
      ? [primaryModel]
      : [primaryModel, "gemini-flash-lite-latest"];

    let response: Response | null = null;
    for (const model of modelsToTry) {
      const upstreamUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
      response = await fetch(upstreamUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(upstreamPayload),
      });
      if (response.ok || (response.status !== 404 && response.status !== 503)) {
        break;
      }
    }

    if (!response || !response.ok) {
      const errText = response ? await response.text() : "No response";
      return new Response(JSON.stringify({ error: `Upstream AI provider error: ${errText}` }), {
        status: response ? response.status : 502,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const data = await response.json();
    return new Response(JSON.stringify(data), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message || "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
