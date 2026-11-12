// Supabase Edge Function: gemini-proxy
// Purpose: Zero-dependency, low-memory Gemini AI proxy for Admin AI Test Creator.
// Never exposes GEMINI_API_KEY to client applications.

declare const Deno: {
  serve: (handler: (req: Request) => Response | Promise<Response>) => unknown;
  env: { get: (key: string) => string | undefined };
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(payload: unknown, status: number): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace(/^Bearer\s+/i, "").trim();
    if (!jwt) {
      return jsonResponse({ error: "Missing Authorization header" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    if (!supabaseUrl || !supabaseServiceKey) {
      return jsonResponse({ error: "Supabase environment not configured" }, 500);
    }

    // 1. Verify caller JWT via lightweight Auth REST (avoids heavy SDK bundle)
    const userRes = await fetch(`${supabaseUrl}/auth/v1/user`, {
      headers: {
        Authorization: `Bearer ${jwt}`,
        apikey: supabaseServiceKey,
      },
    });

    if (!userRes.ok) {
      const errText = await userRes.text();
      return jsonResponse(
        {
          error: "Unauthorized user",
          details: errText || `Auth status ${userRes.status}`,
        },
        401,
      );
    }

    const user = await userRes.json();
    const userId = typeof user?.id === "string" ? user.id : "";
    if (!userId) {
      return jsonResponse({ error: "Unauthorized user", details: "Missing user ID" }, 401);
    }

    // 2. Verify Admin role in public.user_roles
    const roleRes = await fetch(
      `${supabaseUrl}/rest/v1/user_roles?select=role&user_id=eq.${encodeURIComponent(userId)}&role=eq.admin&limit=1`,
      {
        headers: {
          Authorization: `Bearer ${supabaseServiceKey}`,
          apikey: supabaseServiceKey,
        },
      },
    );

    if (!roleRes.ok) {
      return jsonResponse({ error: "Failed to verify admin role" }, 500);
    }
    const roles = await roleRes.json();
    if (!Array.isArray(roles) || roles.length === 0) {
      return jsonResponse({ error: "Forbidden: Admin role required for AI generation" }, 403);
    }

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      return jsonResponse({ error: "Server GEMINI_API_KEY not configured" }, 500);
    }

    const body = await req.json();
    const retiredOrSlowModels = new Set([
      "gemini-1.5-flash",
      "gemini-2.0-flash",
      "gemini-2.5-flash",
      "gemini-3.8-flash",
    ]);
    const requestedModel = typeof body.model === "string" && body.model.trim()
      ? body.model.trim()
      : "gemini-flash-lite-latest";
    const primaryModel = retiredOrSlowModels.has(requestedModel)
      ? "gemini-flash-lite-latest"
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
      ? ["gemini-flash-lite-latest", "gemini-flash-latest"]
      : [primaryModel, "gemini-flash-lite-latest"];

    let response: Response | null = null;
    let lastFetchError = "";
    for (const model of modelsToTry) {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 90000);
      try {
        const upstreamUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
        response = await fetch(upstreamUrl, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(upstreamPayload),
          signal: controller.signal,
        });
      } catch (fetchErr: unknown) {
        lastFetchError = fetchErr instanceof Error ? fetchErr.message : String(fetchErr);
        response = null;
        continue;
      } finally {
        clearTimeout(timeoutId);
      }

      if (response.ok || (response.status !== 404 && response.status !== 503)) {
        break;
      }
    }

    if (!response || !response.ok) {
      const errText = response ? await response.text() : (lastFetchError || "No response");
      return jsonResponse(
        { error: `Upstream AI provider error: ${errText}` },
        response ? response.status : 504,
      );
    }

    // Pass raw JSON text directly without double parse/stringify overhead
    const rawJson = await response.text();
    return new Response(rawJson, {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Internal server error";
    return jsonResponse({ error: message }, 500);
  }
});
