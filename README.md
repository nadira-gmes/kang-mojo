# Kang Mojo: deploy guide

A static web app (no framework, no build step beyond one tiny script) that uses Supabase for words, recordings and optional anonymous quiz results. Hosted on Vercel.

## What is where
- `public/index.html`: the app. `public/vendor/`: Lucide icons and the Supabase client, included locally.
- `build.js`: on Vercel, writes `public/config.js` from your environment variables.
- `supabase/01_tables.sql` and `02_storage.sql`: tables, security rules, the starting 10 words, and the recordings bucket.
- `vercel.json`: output folder, microphone permission, basic security headers.

## 1. Supabase (about 10 minutes)
1. Create a project at supabase.com.
2. SQL Editor -> New query -> paste the contents of `supabase/01_tables.sql` -> Run. Then a new query with `supabase/02_storage.sql` -> Run. Paste the file CONTENTS, not the file name. If Supabase shows a yellow warning about "destructive" statements (it is the `drop policy if exists` lines), choose Run this query. If a storage policy line errors, skip it and instead add the policies in Storage -> Policies on the `recordings` bucket: public SELECT, and INSERT / UPDATE / DELETE for the `authenticated` role.
3. Authentication -> Users -> Add user. Create ONE admin with your email and a strong password (tick auto-confirm).
4. Authentication -> Sign In / Providers -> turn OFF "Allow new users to sign up". This is important: the security rules treat any signed-in user as an admin.
5. Project Settings -> API: copy the **Project URL** and the **anon public key**. The anon key is meant to be public. The row-level security rules in the SQL are what protect your data.
   Never put the `service_role` key anywhere in this project.

## 2. Vercel
1. Put this folder in a GitHub repository (or run `vercel` from this folder with the Vercel CLI).
2. Vercel -> Add New Project -> import the repo. Framework preset: **Other**. Leave build settings as they are (vercel.json sets them).
3. Settings -> Environment Variables:
   - `SUPABASE_URL` = your Project URL
   - `SUPABASE_ANON_KEY` = your anon public key
   - `COLLECT_RESULTS` = `false` (set `true` to store anonymous level scores)
   - (nothing needed for the mascot: see "Mascot" below)
4. Deploy. After changing environment variables, redeploy.

## 3. Adding recordings (admin)
1. Open `https://YOUR-SITE.vercel.app/#admin`. A Recordings button appears. Visitors without `#admin` never see it, and even if they did, they cannot sign in or write anything.
2. Sign in with the admin account.
3. For each word (and the greeting reply), Record or Upload audio. It is saved to Supabase Storage and everyone hears it right away.
4. To edit words or Sundanese spellings, use Supabase -> Table Editor -> `words`. The `keys` column lists the spoken phrases that trigger the word. Keep at least 10 words so the levels work.

## 4. Test on a real phone
Use Chrome on Android over the https Vercel address, open the link in Chrome itself (not inside another app's browser), and allow the microphone. iPhone Safari's speech recognition is unreliable; the typed box is the fallback.

## Before sharing with the public
- Mascot: only use artwork you have the rights to. The default is an original placeholder. Do not publish the Mojo Jojo artwork.
- Words: have Sundanese speakers verify every word, and get consent from the people recorded.
- Privacy: voice goes through the browser's speech service (Chrome sends it to Google). If `COLLECT_RESULTS` is true, say so in the privacy note: only level, score and language are stored, with no names or audio.
- For children under 13, check your university's or the school's rules.
- Free Supabase projects pause after a week of no activity, and Vercel's free (Hobby) plan is for non-commercial use.

## Mascot (shows automatically when the site opens)
Put three image files in `public/assets/` with exactly these names:
- `mascot-idle.png` (standing, waiting)
- `mascot-listen.png` (listening)
- `mascot-speak.png` (mouth open, talking)

If they exist, the app uses them on every visit. If not, it shows the placeholder monkey. Transparent PNGs look best. Only publish artwork you have the rights to.
