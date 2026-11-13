// Runs on Vercel at build time: turns environment variables into public/config.js.
// The Supabase anon key is meant to be public. Your data is protected by the row-level security rules in supabase/schema.sql.
const fs = require("fs");
const cfg = {
  SUPABASE_URL: process.env.SUPABASE_URL || "",
  SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY || "",
  COLLECT_RESULTS: String(process.env.COLLECT_RESULTS || "false").toLowerCase() === "true",
  MASCOT: {
    idle: process.env.MASCOT_IDLE || "",
    listen: process.env.MASCOT_LISTEN || "",
    speak: process.env.MASCOT_SPEAK || ""
  }
};
if (!cfg.SUPABASE_URL || !cfg.SUPABASE_ANON_KEY) console.warn("Warning: SUPABASE_URL / SUPABASE_ANON_KEY not set. The app will use its built-in word list and no recordings.");
fs.writeFileSync("public/config.js", "window.APP_CONFIG = " + JSON.stringify(cfg, null, 2) + ";\n");
console.log("Wrote public/config.js");
