# Rankearn Cloudflare Worker

This worker acts as a secure proxy for the Gemini API and handles secondary integrations with Supabase (file uploads and profile management).

## Deployment Steps

1.  **Install Wrangler**:
    ```bash
    npm install -g wrangler
    ```

2.  **Login to Cloudflare**:
    ```bash
    wrangler login
    ```

3.  **Deploy the Worker**:
    ```bash
    wrangler deploy worker/cloudflare_worker.js --name rankearn-worker
    ```

4.  **Set Environment Variables**:
    Go to the Cloudflare Worker dashboard (Settings -> Variables) and add the following:
    -   `GEMINI_API_KEY`: Your Google AI Studio API Key.
    -   `SUPABASE_URL`: Your Supabase Project URL.
    -   `SUPABASE_SERVICE_ROLE_KEY`: Your Supabase Service Role Key (for secure backend operations).
    -   `SUPABASE_BUCKET`: (Optional) Default is `avatars`.
    -   `SUPABASE_QUIZ_BUCKET`: (Optional) Default is `quiz-images`.

## Configuration in Admin Panel

Once deployed, copy your worker URL (e.g., `https://rankearn-worker.yourname.workers.dev`) and paste it into the **Settings** tab of the Rankearn Admin Panel.
