// Netlify Edge Function - Human Verification Gateway
// Validates Cloudflare Turnstile tokens and escalates to hCaptcha if suspicious

import type { Context } from "@netlify/edge-functions";

const TURNSTILE_SECRET = Deno.env.get("TURNSTILE_SECRET");
const SESSION_COOKIE = "verified_session";
const TRUST_COOKIE = "trust_level";
const SESSION_DURATION = 3600; // 1 hour

// Suspicious patterns
const SUSPICIOUS_USER_AGENTS = [
  "bot", "crawler", "spider", "headless", "phantom", "selenium"
];

export default async (request: Request, context: Context) => {
  const url = new URL(request.url);
  
  // Allow verification pages and assets
  if (url.pathname.startsWith("/verification/") || 
      url.pathname.startsWith("/gate") ||
      url.pathname.startsWith("/captcha") ||
      url.pathname.startsWith("/.netlify/")) {
    return;
  }
  
  // Check for verification token
  const cookies = request.headers.get("cookie") || "";
  const sessionToken = getCookie(cookies, SESSION_COOKIE);
  const trustLevel = getCookie(cookies, TRUST_COOKIE);
  
  if (sessionToken && isValidSession(sessionToken)) {
    // Valid session - allow through
    return;
  }
  
  // Check if suspicious
  const userAgent = request.headers.get("user-agent") || "";
  const isSuspicious = checkSuspicious(userAgent, request);
  
  if (isSuspicious && trustLevel !== "high") {
    // Redirect to hCaptcha
    return Response.redirect(`${url.origin}/captcha?return=${encodeURIComponent(url.pathname)}`, 302);
  }
  
  // Redirect to Turnstile gate
  return Response.redirect(`${url.origin}/gate?return=${encodeURIComponent(url.pathname)}`, 302);
};

// Helper functions
function getCookie(cookieHeader: string, name: string): string | null {
  const match = cookieHeader.match(new RegExp(`${name}=([^;]+)`));
  return match ? match[1] : null;
}

function isValidSession(token: string): boolean {
  try {
    // Decode and validate session token
    const [timestamp, signature] = token.split(".");
    const tokenTime = parseInt(timestamp);
    const currentTime = Math.floor(Date.now() / 1000);
    
    // Check if expired
    if (currentTime - tokenTime > SESSION_DURATION) {
      return false;
    }
    
    // Validate signature (simplified - use proper JWT in production)
    return signature.length > 10;
  } catch {
    return false;
  }
}

function checkSuspicious(userAgent: string, request: Request): boolean {
  // Check user agent
  const ua = userAgent.toLowerCase();
  for (const pattern of SUSPICIOUS_USER_AGENTS) {
    if (ua.includes(pattern)) {
      return true;
    }
  }
  
  // Check for missing headers
  const hasReferer = request.headers.has("referer");
  const hasAccept = request.headers.has("accept");
  const hasAcceptLanguage = request.headers.has("accept-language");
  
  if (!hasAccept || !hasAcceptLanguage) {
    return true;
  }
  
  return false;
}
