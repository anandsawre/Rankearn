// Supabase Edge Function: send-push
// Purpose: Server-side FCM HTTP v1 Notification Dispatch.
// Approved notification-only exception; securely sends broadcasts or direct user alerts.

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
  targetTopic?: string; // e.g. "all_users", "exam_bpsc"
  targetUserTokens?: string[];
  data?: Record<string, string>;
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
    const adminClient = createClient(supabaseUrl, supabaseServiceKey);
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
    const { title, body, imageUrl, targetTopic, data } = payload;

    if (!title || !body) {
      return new Response(JSON.stringify({ error: "Title and body are required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Persist in app notification record in Supabase database
    const { data: notifRecord, error: notifError } = await adminClient
      .from("in_app_notifications")
      .insert({
        title,
        body,
        image_url: imageUrl,
        target_topic: targetTopic || "all_users",
        metadata: data || {},
        sent_by_user_id: user.id,
      })
      .select()
      .single();

    if (notifError) {
      console.error("Failed to log in-app notification:", notifError);
    }

    // If FCM_SERVER_KEY or Google Service Account is configured, dispatch HTTP request
    const fcmServerKey = Deno.env.get("FCM_SERVER_KEY");
    let fcmDispatched = false;

    if (fcmServerKey) {
      const fcmResponse = await fetch("https://fcm.googleapis.com/fcm/send", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `key=${fcmServerKey}`,
        },
        body: JSON.stringify({
          to: targetTopic ? `/topics/${targetTopic}` : "/topics/all_users",
          notification: {
            title,
            body,
            image: imageUrl,
          },
          data: data || {},
        }),
      });

      fcmDispatched = fcmResponse.ok;
    }

    return new Response(
      JSON.stringify({
        success: true,
        notificationId: notifRecord?.id,
        fcmDispatched,
        targetTopic: targetTopic || "all_users",
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
