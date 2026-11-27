# Supabase Auth setup for Viril

The Flutter client uses the Supabase project configured in `lib/core/services/supabase_service.dart`.

## Email and password

1. Open the Supabase project.
2. Go to Authentication → Providers → Email.
3. Keep Email enabled.
4. For production, keep email confirmation enabled and configure the email templates/sender.
5. In Authentication → URL Configuration, add the app's deployed web origin to Redirect URLs.

The web app passes its current origin as the email confirmation redirect, so the same build can work on a Vercel preview and on the production domain once those origins are allow-listed.

## Google sign-in

1. Create or select a project in Google Cloud Console.
2. Configure Google Auth Platform / OAuth consent screen and create an OAuth client.
3. In Supabase, open Authentication → Sign In / Providers → Google and enable Google.
4. Paste the Google OAuth client ID and client secret into the Google provider settings and save.
5. In Google Cloud Console, add this exact Supabase callback URL to the OAuth client's Authorized redirect URIs:

   `https://pjewrbblgnchzlznlpld.supabase.co/auth/v1/callback`

6. In Supabase Authentication → URL Configuration, add:
   - `https://*.vercel.app/**` for Vercel preview and deployment URLs.
   - `https://viril-up.github.io/Viril-top/**` if GitHub Pages is still used.
   - `io.supabase.viril://login-callback/` for the Android callback configured by the validation workflow.
   - The final production domain once it is selected.

Do not put the Google client secret in the Flutter repository. It belongs only in the Supabase Google provider configuration.

## Important

- The publishable key in the Flutter app is intended for client-side use; never add a Supabase service-role key to the app.
- Google sign-in will show an error until Google OAuth credentials are configured in Supabase.
- The current PR prepares sign-in and registration. It does not yet synchronize local Viril profile/progress data or replace the demo chat; those are subsequent stages.
