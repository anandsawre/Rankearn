// Helper: Base64URL encoding
const base64UrlEncode = (str) => {
  return btoa(str).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
};

const arrayBufferToBase64Url = (buffer) => {
  let binary = '';
  const bytes = new Uint8Array(buffer);
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return base64UrlEncode(binary);
};

// Helpers for Firestore REST API serialization & parsing
function fromFirestoreValue(val) {
  if (!val) return null;
  if ('stringValue' in val) return val.stringValue;
  if ('integerValue' in val) return parseInt(val.integerValue, 10);
  if ('doubleValue' in val) return parseFloat(val.doubleValue);
  if ('booleanValue' in val) return val.booleanValue;
  if ('nullValue' in val) return null;
  if ('timestampValue' in val) return val.timestampValue;
  if ('arrayValue' in val) {
    return (val.arrayValue.values || []).map(fromFirestoreValue);
  }
  if ('mapValue' in val) {
    const obj = {};
    const fields = val.mapValue.fields || {};
    for (const [k, v] of Object.entries(fields)) {
      obj[k] = fromFirestoreValue(v);
    }
    return obj;
  }
  return null;
}

function fromFirestoreDoc(doc) {
  if (!doc || !doc.fields) return null;
  const obj = { id: doc.name.split('/').pop() };
  for (const [k, v] of Object.entries(doc.fields)) {
    obj[k] = fromFirestoreValue(v);
  }
  return obj;
}

function toFirestoreValue(val) {
  if (val === null || val === undefined) {
    return { nullValue: null };
  }
  if (typeof val === 'string') {
    if (/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/.test(val)) {
      return { timestampValue: val };
    }
    return { stringValue: val };
  }
  if (typeof val === 'number') {
    if (Number.isInteger(val)) {
      return { integerValue: String(val) };
    }
    return { doubleValue: val };
  }
  if (typeof val === 'boolean') {
    return { booleanValue: val };
  }
  if (Array.isArray(val)) {
    return {
      arrayValue: {
        values: val.map(toFirestoreValue)
      }
    };
  }
  if (typeof val === 'object') {
    const fields = {};
    for (const [k, v] of Object.entries(val)) {
      fields[k] = toFirestoreValue(v);
    }
    return {
      mapValue: { fields }
    };
  }
  return { stringValue: String(val) };
}

function toFirestoreFields(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) {
    fields[k] = toFirestoreValue(v);
  }
  return fields;
}

// Helper: Sign JWT using Web Crypto API
async function signJwt(payload, serviceAccount) {
  const header = { alg: 'RS256', typ: 'JWT' };
  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const signatureInput = `${encodedHeader}.${encodedPayload}`;

  const pemHeader = "-----BEGIN PRIVATE KEY-----";
  const pemFooter = "-----END PRIVATE KEY-----";
  const pemContents = serviceAccount.private_key
    .replace(pemHeader, "")
    .replace(pemFooter, "")
    .replace(/\s/g, "");
  
  const binaryDerString = atob(pemContents);
  const binaryDer = new Uint8Array(binaryDerString.length);
  for (let i = 0; i < binaryDerString.length; i++) {
    binaryDer[i] = binaryDerString.charCodeAt(i);
  }

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryDer.buffer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signatureInput)
  );

  return `${signatureInput}.${arrayBufferToBase64Url(signature)}`;
}

// Helper: Get Google OAuth 2.0 Access Token
async function getAccessToken(serviceAccount) {
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: serviceAccount.client_email,
    scope: [
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/datastore',
      'https://www.googleapis.com/auth/cloud-platform'
    ].join(' '),
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now
  };

  const assertion = await signJwt(payload, serviceAccount);

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${assertion}`
  });

  const data = await response.json();
  if (!response.ok) throw new Error(`OAuth Error: ${JSON.stringify(data)}`);
  return data.access_token;
}

// Helper: Fetch tokens from Firestore REST API
async function fetchTokens(projectId, accessToken, target) {
  const baseUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
  let tokenData = []; // Store as { token, userId }

  if (target === 'global') {
    const queryUrl = `${baseUrl}:runQuery`;
    const queryBody = {
      structuredQuery: {
        from: [{ collectionId: 'users' }],
        orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }],
        select: { fields: [{ fieldPath: 'fcmTokens' }] },
        limit: 100 
      }
    };

    const response = await fetch(queryUrl, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(queryBody)
    });

    const results = await response.json();
    if (response.ok && Array.isArray(results)) {
      results.forEach(res => {
        const userId = res.document?.name?.split('/').pop();
        const fields = res.document?.fields;
        if (userId && fields && fields.fcmTokens && fields.fcmTokens.arrayValue && fields.fcmTokens.arrayValue.values) {
          fields.fcmTokens.arrayValue.values.forEach(v => {
            if (v.stringValue) tokenData.push({ token: v.stringValue, userId });
          });
        }
      });
    }
  } else if (target === 'admin') {
    const queryUrl = `${baseUrl}:runQuery`;
    const queryBody = {
      structuredQuery: {
        from: [{ collectionId: 'users' }],
        where: {
          fieldFilter: { field: { fieldPath: 'role' }, op: 'EQUAL', value: { stringValue: 'admin' } }
        },
        select: { fields: [{ fieldPath: 'fcmTokens' }] }
      }
    };

    const response = await fetch(queryUrl, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
      body: JSON.stringify(queryBody)
    });

    const results = await response.json();
    if (response.ok && Array.isArray(results)) {
      results.forEach(res => {
        const userId = res.document?.name?.split('/').pop();
        const fields = res.document?.fields;
        if (userId && fields && fields.fcmTokens && fields.fcmTokens.arrayValue && fields.fcmTokens.arrayValue.values) {
          fields.fcmTokens.arrayValue.values.forEach(v => {
            if (v.stringValue) tokenData.push({ token: v.stringValue, userId });
          });
        }
      });
    }
  } else {
    // Target is a specific User ID
    const docUrl = `${baseUrl}/users/${target}`;
    const response = await fetch(docUrl, {
      headers: { 'Authorization': `Bearer ${accessToken}` }
    });
    const data = await response.json();
    if (response.ok && data.fields && data.fields.fcmTokens && data.fields.fcmTokens.arrayValue && data.fields.fcmTokens.arrayValue.values) {
      data.fields.fcmTokens.arrayValue.values.forEach(v => {
        if (v.stringValue) tokenData.push({ token: v.stringValue, userId: target });
      });
    }
  }

  // Remove exact duplicates
  const unique = [];
  const map = new Map();
  for (const item of tokenData) {
    if (!map.has(item.token)) {
      map.set(item.token, true);
      unique.push(item);
    }
  }
  return unique;
}

// Helper: Remove dead token from Firestore
async function removeTokenFromUser(projectId, accessToken, userId, token) {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${userId}:patch?updateMask.fieldPaths=fcmTokens`;
  
  // First, we need to get the current tokens to filter out the dead one
  // (REST API doesn't have a direct arrayRemove without knowing the full array or using a complex transform)
  const getUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${userId}`;
  const getRes = await fetch(getUrl, {
    headers: { 'Authorization': `Bearer ${accessToken}` }
  });
  
  if (!getRes.ok) return;
  const data = await getRes.json();
  
  if (!data.fields || !data.fields.fcmTokens || !data.fields.fcmTokens.arrayValue || !data.fields.fcmTokens.arrayValue.values) return;
  
  const currentTokens = data.fields.fcmTokens.arrayValue.values
    .map(v => v.stringValue)
    .filter(v => v && v !== token);
    
  const patchBody = {
    fields: {
      fcmTokens: {
        arrayValue: {
          values: currentTokens.map(t => ({ stringValue: t }))
        }
      }
    }
  };

  await fetch(url, {
    method: 'PATCH',
    headers: { 'Authorization': `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(patchBody)
  });
  console.log(`[Cleanup] Removed dead token for user ${userId}`);
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const sanitizePathSegment = (value) =>
      (value || "untitled")
        .toString()
        .trim()
        .toLowerCase()
        .replace(/[^a-z0-9-_]+/g, "-")
        .replace(/^-+|-+$/g, "")
        .slice(0, 80) || "untitled";

    const decodeBase64Image = (image) => {
      const base64Data = image.split(',')[1] || image;
      const binaryString = atob(base64Data);
      const len = binaryString.length;
      const bytes = new Uint8Array(len);
      for (let i = 0; i < len; i++) {
        bytes[i] = binaryString.charCodeAt(i);
      }
      return bytes;
    };

    const uploadToSupabaseStorage = async ({ supabaseUrl, supabaseKey, bucket, objectPath, bytes }) => {
      const uploadUrl = `${supabaseUrl}/storage/v1/object/${bucket}/${objectPath}`;
      const uploadResponse = await fetch(uploadUrl, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${supabaseKey}`,
          "Content-Type": "image/png",
          "x-upsert": "true"
        },
        body: bytes
      });

      if (!uploadResponse.ok) {
        const errText = await uploadResponse.text();
        throw new Error(`Supabase Upload Failed: ${errText}`);
      }

      return `${supabaseUrl}/storage/v1/object/public/${bucket}/${objectPath}`;
    };

    // Consistently handle CORS headers
    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization, x-goog-api-key",
      "Access-Control-Max-Age": "86400",
    };

    // Handle CORS preflight requests
    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          ...corsHeaders,
          "Access-Control-Allow-Headers": request.headers.get("Access-Control-Request-Headers") || corsHeaders["Access-Control-Allow-Headers"],
        },
      });
    }

    // --- FEATURE: Supabase Profile Upload ---
    if (request.method === "POST" && url.pathname === "/upload-avatar") {
      try {
        const body = await request.json();
        const { userId, image } = body; // image is base64 string

        if (!userId || !image) {
          return new Response("Missing userId or image", { status: 400, headers: corsHeaders });
        }

        const supabaseUrl = env.SUPABASE_URL;
        const supabaseKey = env.SUPABASE_SERVICE_ROLE_KEY;
        const bucket = env.SUPABASE_BUCKET || 'avatars';

        if (!supabaseUrl || !supabaseKey) {
          return new Response("Server Misconfigured (Missing Supabase Creds)", { status: 500, headers: corsHeaders });
        }

        const bytes = decodeBase64Image(image);
        const publicUrl = await uploadToSupabaseStorage({
          supabaseUrl,
          supabaseKey,
          bucket,
          objectPath: `${sanitizePathSegment(userId)}.png`,
          bytes,
        });

        return new Response(JSON.stringify({ url: publicUrl }), {
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          }
        });

      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }
    }

    // --- FEATURE: Supabase Quiz Image Upload ---
    if (request.method === "POST" && url.pathname === "/upload-quiz-image") {
      try {
        const body = await request.json();
        const { quizTitle, image, questionKey } = body;

        if (!quizTitle || !image) {
          return new Response("Missing quizTitle or image", { status: 400, headers: corsHeaders });
        }

        const supabaseUrl = env.SUPABASE_URL;
        const supabaseKey = env.SUPABASE_SERVICE_ROLE_KEY;
        const bucket = env.SUPABASE_QUIZ_BUCKET || 'quiz-images';

        if (!supabaseUrl || !supabaseKey) {
          return new Response("Server Misconfigured (Missing Supabase Creds)", { status: 500, headers: corsHeaders });
        }

        const bytes = decodeBase64Image(image);
        const quizFolder = sanitizePathSegment(quizTitle);
        const fileBase = sanitizePathSegment(questionKey || `question-${Date.now()}`);
        const objectPath = `${quizFolder}/${fileBase}.png`;

        const publicUrl = await uploadToSupabaseStorage({
          supabaseUrl,
          supabaseKey,
          bucket,
          objectPath,
          bytes,
        });

        return new Response(JSON.stringify({ url: publicUrl, bucket, objectPath }), {
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          }
        });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }
    }

    // --- FEATURE: Supabase Profile Management ---
    // GET /profile?uid=...
    if (request.method === "GET" && url.pathname === "/profile") {
      const uid = url.searchParams.get("uid");
      if (!uid) return new Response("Missing UID", { status: 400, headers: corsHeaders });

      const supabaseUrl = env.SUPABASE_URL;
      const supabaseKey = env.SUPABASE_SERVICE_ROLE_KEY;

      if (!supabaseUrl || !supabaseKey) {
        return new Response("Server Misconfigured", { status: 500, headers: corsHeaders });
      }

      const queryUrl = `${supabaseUrl}/rest/v1/users?uid=eq.${uid}&select=*`;
      try {
        const response = await fetch(queryUrl, {
          headers: {
            "apikey": supabaseKey,
            "Authorization": `Bearer ${supabaseKey}`
          }
        });

        if (!response.ok) {
          return new Response(await response.text(), { status: response.status, headers: corsHeaders });
        }

        const data = await response.json();
        const profile = data.length > 0 ? data[0] : null;
        return new Response(JSON.stringify(profile), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });

      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
      }
    }

    // POST /profile (Upsert)
    if (request.method === "POST" && url.pathname === "/profile") {
      try {
        const body = await request.json();
        const { uid, email, ...updates } = body;

        if (!uid) return new Response("Missing UID", { status: 400, headers: corsHeaders });

        const supabaseUrl = env.SUPABASE_URL;
        const supabaseKey = env.SUPABASE_SERVICE_ROLE_KEY;

        if (!supabaseUrl || !supabaseKey) {
          return new Response("Server Misconfigured", { status: 500, headers: corsHeaders });
        }

        const upsertUrl = `${supabaseUrl}/rest/v1/users`;
        // Ensure UID is part of the payload
        const payload = { uid, email, ...updates };

        const response = await fetch(upsertUrl, {
          method: "POST",
          headers: {
            "apikey": supabaseKey,
            "Authorization": `Bearer ${supabaseKey}`,
            "Content-Type": "application/json",
            "Prefer": "return=representation,resolution=merge-duplicates"
          },
          body: JSON.stringify(payload)
        });

        if (!response.ok) {
          return new Response(await response.text(), { status: response.status, headers: corsHeaders });
        }

        const data = await response.json();
        return new Response(JSON.stringify(data[0]), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });

      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
      }
    }

    // POST /upload-notification-image
    if (request.method === "POST" && url.pathname === "/upload-notification-image") {
      try {
        const body = await request.json();
        const { image, fileName } = body; 

        if (!image) return new Response("Missing image data", { status: 400, headers: corsHeaders });

        const supabaseUrl = env.SUPABASE_URL;
        const supabaseKey = env.SUPABASE_SERVICE_ROLE_KEY;
        const bucket = env.SUPABASE_NOTIFICATION_BUCKET || 'notification-images';

        if (!supabaseUrl || !supabaseKey) {
          return new Response("Server Misconfigured (Missing Supabase Creds)", { status: 500, headers: corsHeaders });
        }

        const bytes = decodeBase64Image(image);
        const name = fileName || `notif-${Date.now()}.png`;
        
        const publicUrl = await uploadToSupabaseStorage({
          supabaseUrl,
          supabaseKey,
          bucket,
          objectPath: name,
          bytes,
        });

        return new Response(JSON.stringify({ url: publicUrl }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });

      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } });
      }
    }

    // --- FEATURE: FCM Topic Subscription ---
    if (request.method === "POST" && url.pathname === "/subscribe-topic") {
      try {
        const body = await request.json();
        const { token, topic } = body;

        if (!token || !topic) {
          return new Response("Missing token or topic", { status: 400, headers: corsHeaders });
        }

        const serviceAccount = JSON.parse(env.SERVICE_KEY);
        const accessToken = await getAccessToken(serviceAccount);
        
        // Use batchAdd for better OAuth2 compatibility
        const iidUrl = `https://iid.googleapis.com/iid/v1:batchAdd`;
        const iidBody = {
          to: `/topics/${topic}`,
          registration_tokens: [token]
        };

        const response = await fetch(iidUrl, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
            'access_token_auth': 'true'
          },
          body: JSON.stringify(iidBody)
        });

        const resultData = await response.json();
        if (!response.ok) {
          return new Response(JSON.stringify({ error: resultData }), { status: response.status, headers: corsHeaders });
        }

        return new Response(JSON.stringify({ success: true, results: resultData }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });

      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // --- FEATURE: FCM Push Notification ---
    if (request.method === "POST" && url.pathname === "/send-push") {
      try {
        const body = await request.json();
        let { tokens, target, title, message, image: bodyImage, data: extraData } = body;
        
        const image = bodyImage || extraData?.image || extraData?.imageUrl || "";

        if (!env.SERVICE_KEY) {
          return new Response("Server Misconfigured (Missing SERVICE_KEY)", { status: 500, headers: corsHeaders });
        }

        const serviceAccount = JSON.parse(env.SERVICE_KEY);
        const accessToken = await getAccessToken(serviceAccount);
        const projectId = serviceAccount.project_id;

        // --- NEW TOPIC LOGIC ---
        // If target is 'global' or 'admin', we use topics for better scalability
        if (target === 'global' || target === 'admin') {
          const topicName = target === 'global' ? 'all_users' : 'admins';
          const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
          
          const stringifiedExtraData = extraData ? Object.fromEntries(Object.entries(extraData).map(([k, v]) => [k, String(v)])) : {};

          const fcmMessage = {
            message: {
              topic: topicName,
              notification: {
                title: String(title || "New Notification"),
                body: String(message || ""),
                ...(image ? { image: String(image) } : {})
              },
              android: {
                notification: {
                  channel_id: "high_priority",
                  ...(image ? { image: String(image) } : {}),
                  sound: "default",
                  visibility: "public"
                }
              },
              data: {
                ...stringifiedExtraData,
                title: String(title || "New Notification"),
                body: String(message || ""),
                ...(image ? { image: String(image) } : {})
              },
              webpush: {
                fcm_options: {
                  link: extraData?.actionUrl ? String(extraData.actionUrl) : "/"
                }
              }
            }
          };

          const response = await fetch(fcmUrl, {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
            body: JSON.stringify(fcmMessage)
          });

          const resultData = await response.json();
          return new Response(JSON.stringify({ success: response.ok, topic: topicName, result: resultData }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" }
          });
        }

        // --- LEGACY INDIVIDUAL TOKEN LOGIC (For specific users) ---
        if (!tokens || !Array.isArray(tokens) || tokens.length === 0) {
          if (!target) return new Response("Missing tokens or target", { status: 400, headers: corsHeaders });
          tokens = await fetchTokens(projectId, accessToken, target);
        }

        if (tokens.length === 0) {
          return new Response(JSON.stringify({ success: true, message: "No tokens found" }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" }
          });
        }

        // Limit to 45 for individual sends
        const maxTokens = tokens.slice(0, 45);

        const results = await Promise.all(maxTokens.map(async ({ token, userId }) => {
          const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
          const stringifiedExtraData = extraData ? Object.fromEntries(Object.entries(extraData).map(([k, v]) => [k, String(v)])) : {};

          const fcmMessage = {
            message: {
              token,
              notification: {
                title: String(title || "New Notification"),
                body: String(message || ""),
                ...(image ? { image: String(image) } : {})
              },
              android: {
                notification: {
                  channel_id: "high_priority",
                  ...(image ? { image: String(image) } : {}),
                  sound: "default",
                  visibility: "public"
                }
              },
              data: {
                ...stringifiedExtraData,
                title: String(title || "New Notification"),
                body: String(message || ""),
                ...(image ? { image: String(image) } : {})
              },
              webpush: {
                fcm_options: {
                  link: extraData?.actionUrl ? String(extraData.actionUrl) : "/"
                }
              }
            }
          };

          const response = await fetch(fcmUrl, {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
            body: JSON.stringify(fcmMessage)
          });

          const resData = await response.json();
          
          // AUTO-CLEANUP LOGIC: Remove dead tokens (404/410)
          if (response.status === 404 || response.status === 410) {
            // We don't await this to keep the response fast
            removeTokenFromUser(projectId, accessToken, userId, token).catch(console.error);
          }

          return { token, userId, ok: response.ok, status: response.status, error: !response.ok ? resData : null };

        }));

        return new Response(JSON.stringify({ results, limited: tokens.length > 45 }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });

      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), { status: 500, headers: corsHeaders });
      }
    }

    // --- FEATURE: Server-side Quiz Submission and Verification ---
    if (request.method === "POST" && url.pathname === "/submit-test") {
      try {
        const body = await request.json();
        const { userId, testId, answers, startTime, endTime, timeTaken } = body;

        if (!userId || !testId || !answers || !startTime || !endTime) {
          return new Response("Missing required fields", { status: 400, headers: corsHeaders });
        }

        if (!env.SERVICE_KEY) {
          return new Response("Server Misconfigured (Missing SERVICE_KEY)", { status: 500, headers: corsHeaders });
        }

        const serviceAccount = JSON.parse(env.SERVICE_KEY);
        const accessToken = await getAccessToken(serviceAccount);
        const projectId = serviceAccount.project_id;
        const baseUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;

        // 1. Fetch the Test metadata
        const testRes = await fetch(`${baseUrl}/tests/${testId}`, {
          headers: { 'Authorization': `Bearer ${accessToken}` }
        });

        if (!testRes.ok) {
          return new Response("Test not found", { status: 404, headers: corsHeaders });
        }

        const testDataRaw = await testRes.json();
        const testDoc = fromFirestoreDoc(testDataRaw);

        if (!testDoc) {
          return new Response("Invalid test data", { status: 500, headers: corsHeaders });
        }

        // Check publishing status
        if (testDoc.status === 'unpublished') {
          return new Response("This test is not published yet.", { status: 400, headers: corsHeaders });
        }

        // Tournament timing validation
        const now = new Date();
        if (testDoc.isTournament) {
          if (testDoc.scheduledStartTime && now < new Date(testDoc.scheduledStartTime)) {
            return new Response("Contest has not started yet!", { status: 400, headers: corsHeaders });
          }
          if (testDoc.scheduledEndTime && now > new Date(testDoc.scheduledEndTime)) {
            return new Response("Contest has already ended!", { status: 400, headers: corsHeaders });
          }

          // Check if user already submitted this tournament test
          const queryUrl = `${baseUrl}:runQuery`;
          const queryBody = {
            structuredQuery: {
              from: [{ collectionId: 'attempts' }],
              where: {
                compositeFilter: {
                  op: 'AND',
                  filters: [
                    { fieldFilter: { field: { fieldPath: 'userId' }, op: 'EQUAL', value: { stringValue: userId } } },
                    { fieldFilter: { field: { fieldPath: 'testId' }, op: 'EQUAL', value: { stringValue: testId } } }
                  ]
                }
              },
              limit: 1
            }
          };

          const queryRes = await fetch(queryUrl, {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${accessToken}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify(queryBody)
          });

          if (queryRes.ok) {
            const queryResults = await queryRes.json();
            if (Array.isArray(queryResults) && queryResults.length > 0 && queryResults[0].document) {
              const existingAttemptId = queryResults[0].document.name.split('/').pop();
              return new Response(JSON.stringify({
                success: true,
                alreadySubmitted: true,
                attemptId: existingAttemptId
              }), {
                headers: { ...corsHeaders, "Content-Type": "application/json" }
              });
            }
          }
        }

        // 2. Fetch all questions from subcollection
        const questionsUrl = `${baseUrl}/tests/${testId}/questions?pageSize=300`;
        const qRes = await fetch(questionsUrl, {
          headers: { 'Authorization': `Bearer ${accessToken}` }
        });

        if (!qRes.ok) {
          return new Response("Failed to load questions", { status: 500, headers: corsHeaders });
        }

        const qData = await qRes.json();
        const questions = (qData.documents || []).map(fromFirestoreDoc);

        if (questions.length === 0) {
          return new Response("No questions found for this test", { status: 400, headers: corsHeaders });
        }

        // 3. Compute score metrics
        let correct = 0;
        let wrong = 0;
        const negativeMarking = parseFloat(testDoc.negativeMarking) || 0;

        questions.forEach((question) => {
          const selectedOption = answers[question.id];

          if (selectedOption === undefined || selectedOption === null) {
            return;
          }

          if (Number(selectedOption) === Number(question.correctAnswer)) {
            correct += 1;
          } else {
            wrong += 1;
          }
        });

        const skipped = questions.length - (correct + wrong);
        const score = correct - wrong * negativeMarking;
        const accuracy = (correct + wrong) > 0 ? (correct / (correct + wrong)) * 100 : 0;

        // 4. Construct Attempt object
        const attemptObj = {
          userId,
          testId,
          answers,
          startTime,
          endTime,
          timeTaken: Math.max(0, parseInt(timeTaken, 10) || 0),
          score: Number(score.toFixed(2)),
          accuracy: Number(accuracy.toFixed(2))
        };

        // Write attempt document
        const writeRes = await fetch(`${baseUrl}/attempts`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            fields: toFirestoreFields(attemptObj)
          })
        });

        if (!writeRes.ok) {
          const errText = await writeRes.text();
          return new Response(`Failed to save attempt in database: ${errText}`, { status: 500, headers: corsHeaders });
        }

        const createdAttemptRaw = await writeRes.json();
        const attemptId = createdAttemptRaw.name.split('/').pop();

        // 5. Update user leaderboard eligibility for tournaments
        if (testDoc.isTournament) {
          const userPatchUrl = `${baseUrl}/users/${userId}?updateMask.fieldPaths=isLeaderboardEligible`;
          await fetch(userPatchUrl, {
            method: 'PATCH',
            headers: {
              'Authorization': `Bearer ${accessToken}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              fields: {
                isLeaderboardEligible: { booleanValue: true }
              }
            })
          });
        }

        return new Response(JSON.stringify({
          success: true,
          attemptId
        }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });

      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }
    }

    // --- FEATURE: Secure Bot Battle Submission ---
    if (request.method === "POST" && url.pathname === "/submit-bot-battle") {
      try {
        const body = await request.json();
        const { userId, entryFee, userAnswers, userTimes, botCorrectCount, botScore, questionIds, opponentName } = body;

        if (!userId || entryFee === undefined || !userAnswers || !userTimes || botCorrectCount === undefined || botScore === undefined || !questionIds) {
          return new Response("Missing required fields", { status: 400, headers: corsHeaders });
        }

        if (!env.SERVICE_KEY) {
          return new Response("Server Misconfigured (Missing SERVICE_KEY)", { status: 500, headers: corsHeaders });
        }

        const serviceAccount = JSON.parse(env.SERVICE_KEY);
        const accessToken = await getAccessToken(serviceAccount);
        const projectId = serviceAccount.project_id;
        const baseUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;

        // 1. Fetch battle configuration
        const configRes = await fetch(`${baseUrl}/configs/battle_settings`, {
          headers: { 'Authorization': `Bearer ${accessToken}` }
        });
        
        let totalQuestions = 5;
        let timePerQuestion = 10;
        let botAccuracy = 0.65;
        let prizeMultiplier = 1.8;
        let entryStakes = [10, 50, 100];

        if (configRes.ok) {
          const configRaw = await configRes.json();
          const configDoc = fromFirestoreDoc(configRaw);
          if (configDoc) {
            totalQuestions = Math.max(1, configDoc.totalQuestions || 5);
            timePerQuestion = Math.max(5, configDoc.timePerQuestion || 10);
            botAccuracy = Math.min(1, Math.max(0, configDoc.botAccuracy || 0.65));
            prizeMultiplier = configDoc.prizeMultiplier || 1.8;
            entryStakes = configDoc.entryStakes || [10, 50, 100];
          }
        }

        // 2. Validate entry fee
        const parsedEntryFee = Number(entryFee);
        if (!entryStakes.includes(parsedEntryFee)) {
          return new Response("Invalid entry fee", { status: 400, headers: corsHeaders });
        }

        // 3. Fallback answers map
        const FALLBACK_ANSWERS = {
          '1': 3, '2': 1, '3': 1, '4': 2, '5': 1, '6': 0, '7': 2, '8': 1, '9': 2, '10': 3,
          '11': 2, '12': 2, '13': 1, '14': 1, '15': 2, '16': 0, '17': 1, '18': 0, '19': 0, '20': 1,
          '21': 2, '22': 1, '23': 1, '24': 1, '25': 2
        };

        const getCorrectAnswer = async (qId) => {
          if (FALLBACK_ANSWERS[qId] !== undefined) {
            return FALLBACK_ANSWERS[qId];
          }
          const qRes = await fetch(`${baseUrl}/battle_questions/${qId}`, {
            headers: { 'Authorization': `Bearer ${accessToken}` }
          });
          if (qRes.ok) {
            const qDoc = await qRes.json();
            const data = fromFirestoreDoc(qDoc);
            if (data && data.correctAnswer !== undefined) {
              return Number(data.correctAnswer);
            }
          }
          return null;
        };

        // 4. Calculate User Score securely
        let calculatedUserScore = 0;
        for (const qId of questionIds) {
          const correctAnswer = await getCorrectAnswer(qId);
          if (correctAnswer === null) {
            calculatedUserScore = Math.max(0, calculatedUserScore - 25);
            continue;
          }

          const userAns = userAnswers[qId];
          const timeLeft = Number(userTimes[qId] || 0);

          if (userAns !== undefined && userAns !== null && Number(userAns) === Number(correctAnswer)) {
            const speedBonus = Math.floor((timeLeft / timePerQuestion) * 50);
            calculatedUserScore += 100 + speedBonus;
          } else {
            calculatedUserScore = Math.max(0, calculatedUserScore - 25);
          }
        }

        // 5. Verify Bot Performance (and override if anomalous)
        let verifiedBotScore = Number(botScore);
        let verifiedBotCorrectCount = Number(botCorrectCount);

        const maxBotScore = verifiedBotCorrectCount * 120;
        const minBotScore = Math.max(0, verifiedBotCorrectCount * 100 - (totalQuestions - verifiedBotCorrectCount) * 25);

        if (
          verifiedBotCorrectCount < 1 || 
          verifiedBotScore > maxBotScore || 
          verifiedBotScore < minBotScore
        ) {
          // Re-simulate bot performance securely
          verifiedBotScore = 0;
          verifiedBotCorrectCount = 0;
          for (let i = 0; i < totalQuestions; i++) {
            const isCorrect = Math.random() < botAccuracy;
            if (isCorrect) {
              verifiedBotCorrectCount++;
              verifiedBotScore += 100 + Math.floor(Math.random() * 20);
            } else {
              verifiedBotScore = Math.max(0, verifiedBotScore - 25);
            }
          }
        }

        // 6. Determine Match Outcome
        let matchResult = 'draw';
        if (calculatedUserScore > verifiedBotScore) {
          matchResult = 'win';
        } else if (calculatedUserScore < verifiedBotScore) {
          matchResult = 'loss';
        }

        // 7. Perform Payout / Refund transactions if win or draw
        let winAmount = 0;
        let finalCoins = null;

        if (matchResult === 'win' || matchResult === 'draw') {
          // Fetch user document to get current balance
          const userRes = await fetch(`${baseUrl}/users/${userId}`, {
            headers: { 'Authorization': `Bearer ${accessToken}` }
          });
          if (!userRes.ok) {
            return new Response("User profile not found", { status: 404, headers: corsHeaders });
          }
          const userRaw = await userRes.json();
          const userDoc = fromFirestoreDoc(userRaw);
          const currentCoins = Number(userDoc.coins || 0);

          if (matchResult === 'win') {
            winAmount = Math.floor(parsedEntryFee * prizeMultiplier);
          } else {
            winAmount = parsedEntryFee; // Refund entry fee
          }

          finalCoins = currentCoins + winAmount;

          // Update user's coins
          const userPatchUrl = `${baseUrl}/users/${userId}?updateMask.fieldPaths=coins`;
          const patchRes = await fetch(userPatchUrl, {
            method: 'PATCH',
            headers: {
              'Authorization': `Bearer ${accessToken}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              fields: {
                coins: { integerValue: String(finalCoins) }
              }
            })
          });

          if (!patchRes.ok) {
            const errText = await patchRes.text();
            throw new Error(`Failed to update user coins: ${errText}`);
          }

          // Create transaction log
          const transObj = {
            userId,
            amount: winAmount,
            type: 'earn',
            category: matchResult === 'win' ? 'battle_win' : 'battle_refund',
            testTitle: matchResult === 'win' ? `Won 1v1 Battle vs ${opponentName || 'Opponent'}` : '1v1 Battle Refund',
            currentBalance: finalCoins,
            timestamp: new Date().toISOString()
          };

          const transRes = await fetch(`${baseUrl}/transactions`, {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${accessToken}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              fields: toFirestoreFields(transObj)
            })
          });

          if (!transRes.ok) {
            console.error("Failed to write transaction record:", await transRes.text());
          }
        }

        return new Response(JSON.stringify({
          success: true,
          matchResult,
          winAmount,
          userScore: calculatedUserScore,
          botScore: verifiedBotScore,
          finalCoins
        }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });

      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }
    }

    // --- DEFAULT: Gemini Proxy ---
    if (request.method === "POST" && (url.pathname === "/" || url.pathname === "/gemini")) {
      try {
        const body = await request.json();
        const model = body.model || "gemini-1.5-flash";

        const apiKey = env.GEMINI_API_KEY || request.headers.get("x-goog-api-key");

        if (!apiKey) {
          return new Response("Missing API Key", { status: 401, headers: corsHeaders });
        }

        const upstreamUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;

        const upstreamBody = {
          contents: body.contents,
          generationConfig: body.generationConfig,
          systemInstruction: body.systemInstruction,
          safetySettings: body.safetySettings,
          tools: body.tools,
          toolConfig: body.toolConfig
        };

        const response = await fetch(upstreamUrl, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(upstreamBody),
        });

        const responseData = await response.json();

        return new Response(JSON.stringify(responseData), {
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        });
      } catch (err) {
        return new Response(JSON.stringify({ error: err.message }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" }
        });
      }
    }

    return new Response("Not Found", { status: 404, headers: corsHeaders });
  },
};
