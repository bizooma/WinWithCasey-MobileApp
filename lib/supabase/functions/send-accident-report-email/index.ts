// supabase/functions/send-accident-report-email/index.ts

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

type Payload = {
  to?: string;
  subject?: string;
  text?: string;
  // Optional structured data (not used directly for email formatting yet)
  report?: Record<string, unknown>;
};

function jsonResponse(status: number, body: Record<string, unknown>) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", ...CORS_HEADERS },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return jsonResponse(405, { error: "Method not allowed" });

  const resendApiKey = Deno.env.get("RESEND_API_KEY");
  if (!resendApiKey) {
    return jsonResponse(500, {
      error: "Missing RESEND_API_KEY secret. Add it in the Supabase module > Secrets.",
    });
  }

  let payload: Payload;
  try {
    payload = (await req.json()) as Payload;
  } catch {
    return jsonResponse(400, { error: "Invalid JSON body" });
  }

  const to = (payload.to ?? "joe@bizooma.com").trim();
  const subject = (payload.subject ?? "Accident Report Submitted").trim();
  const text = (payload.text ?? "An accident report was submitted from the app.").toString();

  // Resend allows sending from onboarding@resend.dev for testing.
  const from = "ImpactGuide <onboarding@resend.dev>";

  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ from, to, subject, text }),
    });

    const resText = await res.text();
    if (!res.ok) {
      return jsonResponse(502, {
        error: "Email provider error",
        provider_status: res.status,
        provider_body: resText,
      });
    }

    // Resend returns JSON; keep it as a string to avoid parse failures.
    return jsonResponse(200, { ok: true, provider_body: resText });
  } catch (e) {
    return jsonResponse(500, { error: `Failed to send email: ${String(e)}` });
  }
});
