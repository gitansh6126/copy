# Complete Setup Guide — Vercel + Supabase + Google Cloud

Follow these steps **in order**. Total time: ~30 minutes. You only need the free tiers of all three services.

---

## Phase 1 — Supabase (create project + get keys)

1. Go to https://supabase.com and **Sign in** (Google/GitHub auth).
2. Click **New project**.
3. Fill in:
   - **Organization**: create one if you don't have it (click "New organization").
   - **Project name**: `copy-portal` (or anything).
   - **Database Password**: click "Generate a password" and **save it** (you only see it once).
   - **Region**: pick the closest to your users — for India use **Singapore** (`ap-southeast-1`) or **Mumbai** (`ap-south-1`).
4. Click **Create new project** → wait ~2–3 minutes until the status turns green.
5. When ready, go to **Project Settings → API** (gear icon, left sidebar).
6. Copy two values somewhere safe:
   - **Project URL** — looks like `https://abcdefghijkl.supabase.co`
   - **anon public key** — the long `eyJ...` string (the "JWT Secret" / service_role keys stay secret — never use them here).

> These two values go into `config.js` (step 4, below).

7. Create the table: left sidebar → **SQL Editor** → **New query** → paste the contents of `supabase/schema.sql` → click **Run**.
8. You should see *"Success. No rows returned"*. Verify: **Table Editor** → `snippets` table should exist (empty).

---

## Phase 2 — Google Cloud (create OAuth credentials)

1. Go to https://console.cloud.google.com and sign in.
2. If you have no project: top bar → **Select a project** → **New Project** → name it `copy-portal` → **Create**.
3. Select that project in the top bar (important — everything below happens inside this project).
4. **Dashboard sidebar** → **APIs & Services** → **OAuth consent screen**.
   - User type: choose **External** → **Create**.
   - Fill only the required fields (App name, user support email, developer contact email).
   - **Add the Google user you'll test with** under "Test users" (optional but recommended).
   - Save → no need to set scopes or publish the app.
5. **APIs & Services** → **Credentials** → **+ Create credentials** → **OAuth client ID**.
   - Application type: **Web application**.
   - Name: `copy-portal-web`.
   - **Authorized JavaScript origins** — add BOTH:
     - `https://<your-project-ref>.supabase.co`
     - `http://localhost:3000`
   - **Authorized redirect URIs** — add BOTH:
     - `https://<your-project-ref>.supabase.co/auth/v1/callback`
     - `http://localhost:3000`
   - Click **Create**.
6. A popup shows your **Client ID** and **Client Secret**. Copy both now (you can also view them later from the credentials list).

> `your-project-ref` = the subdomain part of your Supabase Project URL (the `abcdefghijkl` text).

---

## Phase 3 — Supabase (enable Google login)

1. Back in Supabase: **Authentication → Providers**.
2. Find **Google** → toggle **Enable Sign in with Google** **on**.
3. Paste:
   - **Client ID** → from Google Cloud (Phase 2 step 6)
   - **Client Secret** → from Google Cloud (Phase 2 step 6)
   - Optionally enable **Skip non-verified users** if you want anyone with a Google account to sign in.
4. Click **Save**.
5. Go to **Authentication → URL Configuration**:
   - **Site URL**: your Vercel URL, e.g. `https://copy-portal.vercel.app` (paste it here even before Vercel exists — update later).
   - **Redirect URLs** — add BOTH:
     - `http://localhost:3000`
     - `https://copy-portal.vercel.app`
   - Click **Save**.

> You now have two "loop" links:
> Google Cloud redirect → Supabase callback
> Supabase redirect → your app's domain

---

## Phase 4 — Put your keys in `config.js`

Edit `config.js` in this project:

```js
window.SUPABASE_CONFIG = {
  url: "https://abcdefghijkl.supabase.co",   // Supabase Project URL
  anonKey: "eyJhbGciOi...",                  // Supabase anon public key
  redirectTo: "https://copy-portal.vercel.app" // or http://localhost:3000 while testing
};
```

- Save. Do **not** commit the real key to a public repo (it's public anyway — RLS protects data — but avoid leaking to strangers).
- `redirectTo` must match one of the **Redirect URLs** you added in Supabase (step 3.5).

---

## Phase 5 — Vercel (deploy)

You can deploy first, then come back and fix the two URLs if you like — order doesn't matter much.

1. Go to https://vercel.com and **Sign in** with GitHub.
2. Push this folder to GitHub (or upload via the CLI below).
   ```bash
   cd copy
   git init
   git add .
   git commit -m "Copy Portal with Supabase auth"
   git branch -M main
   git remote add origin https://github.com/YOUR_USER/copy-portal.git
   git push -u origin main
   ```
3. **Vercel → Add New → Project** → import the `copy-portal` repo.
4. **Configure project**:
   - Framework preset: **Other** (no build step).
   - Root Directory: pick the folder with `index.html` (if repo root is the folder, leave it as `.`).
   - Build command: **leave empty**.
   - Output directory: **leave empty**.
   - Vercel auto-detects `vercel.json` (static files).
5. Click **Deploy**. Wait ~30 seconds.
6. You get a URL: `https://copy-portal.vercel.app`.
7. **Fix the two redirect URLs now that you know the domain**:
   - Google Cloud → OAuth consent/credentials → replace `http://localhost:3000` entries with the Vercel domain (or keep both).
   - Supabase → Auth → URL Configuration → add `https://copy-portal.vercel.app` to Site URL and Redirect URLs.
8. Also in Vercel: **Project → Settings**, add your custom domain (e.g. `clip.example.in`) if you have one — then add *that* https URL to both redirect lists too.

**Alternative CLI deploy** (no GitHub needed):

```bash
npm i -g vercel
cd copy
vercel --prod
```

Follow the prompts (log in, link directory, root = the `copy` folder). It deploys the static site and prints a URL.

---

## Phase 6 — Test the full flow

1. Open your Vercel URL in a fresh/incognito browser.
2. You should see the **Continue with Google** card.
3. Click it → you leave to Google → pick an account → you land back on your app, logged in.
4. Click **+ New**, create a snippet, refresh the page — it's still there (stored in Supabase, not localStorage).
5. Open in a second browser/incognito → sign in with a *different* Google account → your first account's snippets are invisible (RLS working).
6. Test **Sign out** (logout icon, top right) and the edit/delete/favorite/search/tag/folder features.

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| "redirect_uri_mismatch" from Google | Google Cloud redirect URI doesn't include the exact Supabase callback | Verify `https://<ref>.supabase.co/auth/v1/callback` appears in **Google Cloud → Credentials → OAuth client → Authorized redirect URIs** |
| Land on a blank/`localhost` page after OAuth | `redirectTo` in `config.js` doesn't match a Supabase Redirect URL | Update `config.js` + both `Site URL` and `Redirect URLs` in Supabase |
| "No rows returned" / 401 on app load | `config.js` keys wrong, or `schema.sql` not run | Re-run Phase 1 step 7; check Project URL + anon key in Phase 4 |
| Login button error in console | Google provider disabled in Supabase, or wrong Client ID/Secret | Check **Supabase → Auth → Providers → Google** settings |
| Data missing after browser change | You're signed into a different Google account | Sign out/in with the account that owns the data |
| Stuck on login loop | Site URL in Supabase points to an old domain | Update **Auth → URL Configuration → Site URL** to the current Vercel URL |

## Security notes

- `anonKey` is **public by design** — never use `service_role` key in the frontend (it bypasses RLS).
- All RLS policies in `schema.sql` scope rows to `auth.uid()` — keep them enabled.
- If a test fails, check the browser console (F12) for exact error messages before debugging.