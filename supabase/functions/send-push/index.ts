// Supabase Edge Function: send-push
// Purpose: Server-side FCM HTTP v1 Notification Dispatch across topics or user device tokens.
// Authenticated with Google OAuth 2.0 RS256 JWT using Firebase Service Account.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface PushNotificationPayload {
  title: string;
  body: string;
  imageUrl?: string;
  targetTopic?: string; // e.g. "all_users", "students", "teachers"
  targetTokens?: string[]; // Specific FCM device tokens
  targetSegment?: string;
  actionUrl?: string;
  notificationId?: string;
  data?: Record<string, string>;
}

// Service Account credentials with environment overrides
function getServiceAccount() {
  const envJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
  if (envJson) {
    try {
      return JSON.parse(envJson);
    } catch (_) {}
  }

  return {
    type: "service_account",
    project_id: Deno.env.get("FIREBASE_PROJECT_ID") || "rankearn",
    private_key_id: Deno.env.get("FIREBASE_PRIVATE_KEY_ID") || "bda9efab18471b502b09f0e1c29920a6a421d6b6",
    private_key: (
      Deno.env.get("FIREBASE_PRIVATE_KEY") ||
      "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCuRE8Weou7+Dcs\nW+cqCc2AJ5Yx+1FP6ISzoJJLdZwekPLkiP0tiuPcA9/8XHfrxDLSZSnavbom88gS\nv6hdf4GbMK2sv7AdPb3jYGGH5jw5bk+dbWsleqOlfXbmfVrENRGagYzelwHYVjaV\npW12/rI1Rzi+L+el0KD0dMN4HIe8zcmaQGx2YZShahFzRFiBA+/rYn0BuN9t/XI6\nY0S3V1kGP5g2bYhZQB25i5vW5inScxqjt/4Lj1yCaIU3UI7hUJeBkBHB5h/d/1le\n6ZAmygMqMKwHpqnm8Nj7ydGYwyqXSOnqgaezMLtzRp0JYjdv5Y+oD3Q6IjX1HRj3\nTQ9AkYNvAgMBAAECggEAVfLk2t5X+r5iX+N38Lji/PkJT9927CVvBbUFUmhQNpcg\n5OxXilW9Ki9TEoF8t/CNbE1uxi7bGAkWPYD/hhW0E5l/nvrv3owsEm/fyooYW+73\nH1rvBI4nFiD6OpXK5YiTBRQuKT5rL4rd4xKzGYRm2nYlG1A/PP3X1JmeKqhPniNE\nUnKdKRzDbBv0EC+s5IiEkL55zDGQ4SRYhAR9BSqEZvl+igLe97GFfc9cUMh5ptvx\nd3xe1oFWjmW5MzDejudNxn0/LhNS0Vv2JrtEzi+jirSzfgA1T84kCWAwkpIwCUQ0\nsCoMJzb6CpgJVaWRBofGKa6oPI0Bi5g0PAYy6dm8UQKBgQDeZGwtm43B8IBfrZ3g\nYQOu5jdVVWnUOaIEVy/jD2XTGAlXFsrvCmnWgIZYez3hZy2VOxU+y08uxO8qARQ6\nUwfY8ImtdWsRWMRs75UbJ6Kd62NiDhftXUGNxHSS2OmErBHNYn2RoLVqjXSTfymL\nAeKoY9pgqFjwFWAChhNnI6fz1wKBgQDImhTocPPlHz6EUVincBHLzydJI1AKhpTW\nJvTueC5mb7zDuq7Pzy+DFHRvmzOd8/ePuaSzZUiSzVn+/cv6dYLlYF0sqmympsHs\nwQ28DUWWwj/Jo/3cPeDXywZAOXTmcqV2Qzt8CG4cenCQ0Sd5SgYxULr5O8/ksrMB\nvMl8RGF6KQKBgBQI1/YD3XFrSSVVbrOYCczn0HRPjYkg6AecEyRRbsrlj3HZC88d\nEQvR6EhwUdLMiL644+EUT73W3/TYxAm9ESfqA30s5shZRtjJfJVFrNCtM/bRbjZk\nAFPVLutLvz3EgpYOGWHVKILA24+uFQAA23pwBGxQvjJiupN/oJ/aBndhAoGAHOXd\ndzK2X95lYihZzh0d4y9faHDW2f1TOZp5FFVp0cXs+oFNJ5CgNpDeySkhgXKgyiqj\nKFjB4KwGd+5V0SnWhnagVYvjhQpmy1VwRhPfX31yNPkT3ANp/Yw4xU3BomUHowbC\nbfbE7gNRbftDZXydccNAfCD6rOZ1VR2+JNGw/SkCgYADrJrm06s6p9QxR0MNGepq\no748pEYWiy5+OU8GhQQ37bQVgInh6FP40CmyeKTC7wyyuLx83ozW6zfDh8tyAfS1\ng/6jJCfza2sck+N6G3Rp7hjswz2mU4EvmSUu1tL95ukEJ8HFXTSAkJI9j1RNM6Pb\nZO9L+RFKCeXrYRO2+f9Irw==\n-----END PRIVATE KEY-----\n"
    ).replace(/\\n/g, "\n"),
    client_email: Deno.env.get("FIREBASE_CLIENT_EMAIL") || "firebase-adminsdk-fbsvc@rankearn.iam.gserviceaccount.com",
  };
}

function base64UrlEncode(str: string): string {
  return btoa(unescape(encodeURIComponent(str)))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

function arrayBufferToBase64Url(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = "";
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

// Generate Google OAuth2 Access Token using Web Crypto API
async function getGoogleOAuth2Token(sa: ReturnType<typeof getServiceAccount>): Promise<string> {
  const pem = sa.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");

  const rawBinary = atob(pem);
  const binaryDer = new Uint8Array(rawBinary.length);
  for (let i = 0; i < rawBinary.length; i++) {
    binaryDer[i] = rawBinary.charCodeAt(i);
  }

  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claim = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  const unsigned = `${base64UrlEncode(JSON.stringify(header))}.${base64UrlEncode(JSON.stringify(claim))}`;
  const sigBuffer = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned)
  );

  const jwt = `${unsigned}.${arrayBufferToBase64Url(sigBuffer)}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const json = await tokenRes.json();
  if (!json.access_token) {
    throw new Error(`Google OAuth2 Error: ${JSON.stringify(json)}`);
  }

  return json.access_token;
}

serve(async (req: Request) => {
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

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user }, error: userError } = await userClient.auth.getUser();
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized user session" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Check if caller is admin
    const adminClient = createClient(supabaseUrl, supabaseServiceKey || supabaseAnonKey);
    const { data: adminRole } = await adminClient
      .from("user_roles")
      .select("role")
      .eq("user_id", user.id)
      .eq("role", "admin")
      .maybeSingle();

    if (!adminRole) {
      return new Response(JSON.stringify({ error: "Forbidden: Admin privilege required to broadcast push alerts" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const payload: PushNotificationPayload = await req.json();
    const {
      title,
      body,
      imageUrl,
      targetTopic,
      targetTokens,
      targetSegment,
      actionUrl,
      notificationId,
      data = {},
    } = payload;

    if (!title || !body) {
      return new Response(JSON.stringify({ error: "Title and body are required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const notifId = notificationId || `notif-${Date.now()}`;
    const segment = targetSegment || targetTopic || "all";
    const clickUrl = actionUrl || data.action_url || "/tests";

    // 1. Persist or Upsert record in public.notifications
    await adminClient.from("notifications").upsert(
      {
        id: notifId,
        user_id: "global",
        title,
        message: body,
        type: data.type || "alert",
        target_segment: segment,
        action_url: clickUrl,
        image_url: imageUrl || null,
        is_read: false,
      },
      { onConflict: "id" }
    );

    // 2. Obtain Google OAuth2 Token for FCM v1 API
    const sa = getServiceAccount();
    const accessToken = await getGoogleOAuth2Token(sa);

    const fcmEndpoint = `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`;
    const fcmResults: any[] = [];

    // Notification and data payload for FCM v1
    const notificationPayload = {
      title,
      body,
      ...(imageUrl ? { image: imageUrl } : {}),
    };

    const dataPayload = {
      ...data,
      notification_id: notifId,
      action_url: clickUrl,
      type: data.type || "alert",
    };

    const androidConfig = {
      priority: "high",
      notification: {
        channel_id: "rankearn_broadcasts",
        sound: "default",
        default_vibrate_timings: true,
      },
    };

    const webpushConfig = {
      headers: {
        Urgency: "high",
      },
      notification: {
        title,
        body,
        icon: "/icons/Icon-192.png",
      },
      fcm_options: {
        link: clickUrl,
      },
    };

    if (targetTokens && targetTokens.length > 0) {
      // Direct token dispatch
      for (const token of targetTokens) {
        try {
          const res = await fetch(fcmEndpoint, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${accessToken}`,
            },
            body: JSON.stringify({
              message: {
                token,
                notification: notificationPayload,
                data: dataPayload,
                android: androidConfig,
                webpush: webpushConfig,
              },
            }),
          });
          const resJson = await res.json();
          fcmResults.push({ token, status: res.status, result: resJson });
        } catch (e: any) {
          fcmResults.push({ token, error: e.message });
        }
      }
    } else {
      // Topic broadcast dispatch (defaults to all_users)
      const topicName = (targetTopic || segment || "all_users")
        .toLowerCase()
        .replace(/[^a-zA-Z0-9-_.~%]/g, "_");

      const fcmResponse = await fetch(fcmEndpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            topic: topicName === "all" ? "all_users" : topicName,
            notification: notificationPayload,
            data: dataPayload,
            android: androidConfig,
            webpush: webpushConfig,
          },
        }),
      });

      const fcmJson = await fcmResponse.json();
      fcmResults.push({ topic: topicName, status: fcmResponse.status, result: fcmJson });
    }

    const hasSuccess = fcmResults.some((r) => r.status === 200 || r.result?.name);

    return new Response(
      JSON.stringify({
        success: true,
        notificationId: notifId,
        fcmDispatched: hasSuccess,
        results: fcmResults,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({
        success: false,
        error: err.message || "Internal server error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
