window.SUPABASE_CONFIG = {
  // Get these from Supabase Dashboard -> Project Settings -> API
  // URL:        https://<project-ref>.supabase.co
  // anon key:   the public "anon" API key (safe to expose in a static site, RLS protects the data)
  url: "https://hqoxfgauqvmpxsnbvlbu.supabase.co",
  anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhxb3hmZ2F1cXZtcHhzbmJ2bGJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk5NTIwMTcsImV4cCI6MjEwNTUyODAxN30.GxrJQYSSqn3Aabqs5O9I8ZypMzdfHLzX90CCCS8FHsM",

  // The URL Google redirects back to after sign-in.
  // For local dev:   http://localhost:3000
  // For production:  https://your-app.vercel.app/  (must be added as an authorized redirect in
  //     Supabase Dashboard -> Authentication -> URL Configuration)
  redirectTo: window.location.origin
};