# 🛡️ The 5-Pass Vibe-Coding Pre-Launch Security Defense

When building applications rapidly using AI builders (Lovable, Bolt, Cursor, Replit, v0, Antigravity), code often functions smoothly on the surface while harboring critical vulnerabilities in authorization, data exposure, and frontend leaks.

This defense framework synthesizes the methodology of **Gitleaks**, **Bearer**, **ECC Production Audit**, **Trail of Bits**, and **ECC Security Review** into a 5-pass pre-launch security inspection.

---

## 🔒 Pass 1: Secret Leak & Client Exposure Shield (Based on Gitleaks)
*Goal: Zero secrets, API keys, or credentials exposed publicly or bundled into client code.*

1. **Complete Secret Relocation**:
   - Every API key, password, private token, database URL, and webhook secret must reside in environment variables.
   - Zero hardcoded secrets anywhere in source code, utility files, config objects, or comments.
2. **Strict Frontend Prefix Quarantine**:
   - In Next.js (`NEXT_PUBLIC_`), Create React App (`REACT_APP_`), and Vite (`VITE_`), any variable with these prefixes is bundled into client-side JavaScript and visible to anyone inspecting page source.
   - Only public-safe identifiers (e.g. public client IDs) may carry these prefixes. Never prefix private secrets, service role keys, or database URIs with public prefixes.
3. **Database & Backend Key Separation**:
   - **Supabase**: The `anon` key is public ONLY IF **Row Level Security (RLS)** is enabled on every table. The `service_role` key must **NEVER** touch client-side code.
   - **Stripe**: Only the publishable key (`pk_...`) goes to the client. The secret key (`sk_...`) remains strictly server-side.
   - **Database URLs**: MongoDB, PostgreSQL, and Redis connection strings must remain server-side.
4. **Log Sanitization**:
   - Ensure `console.log`, print statements, and error handlers never print environment objects (`process.env`) or credential strings.
5. **Git History Hygiene**:
   - If a secret was previously committed, it remains in the `.git` history even if deleted in a later commit. Rotate compromised credentials immediately.

---

## 👤 Pass 2: Personal Data Flow & PII Audit (Based on Bearer)
*Goal: Prevent user personal data (emails, phones, passwords, tokens) from leaking into logs, browser storage, or third-party SDKs.*

1. **Map Data Collection**:
   - Identify every input point collecting PII: emails, phone numbers, passwords, real names, addresses, dates of birth, IP addresses, and device fingerprints.
2. **Log Redaction**:
   - Ensure no logger outputs user PII. Replace sensitive fields with `[REDACTED]` or eliminate the log call.
3. **Third-Party SDK Hygiene**:
   - Audit analytics, crash reporters (Sentry), and AI API calls. Verify that telemetry payloads strip user passwords, auth headers, and sensitive form inputs.
4. **Cryptographic Password Storage**:
   - Passwords must be hashed using `argon2`, `bcrypt`, or `scrypt`.
   - Never use MD5 or plain SHA256. Plaintext passwords must never be stored, logged, or returned in API responses.
5. **Browser Storage Policy**:
   - Never store sensitive user PII, session tokens, or JWTs in `localStorage` or `sessionStorage` (they are vulnerable to cross-site scripting / XSS).
   - Use `httpOnly`, `secure`, and `sameSite=Lax|Strict` cookies for session management.
6. **Field-Level Response Filtering**:
   - API endpoints must never return raw database models directly. Filter out password hashes, internal foreign keys, reset tokens, and neighboring user data.

---

## 🚀 Pass 3: Pre-Deploy Production Audit (Based on ECC Production Audit)
*Goal: Ensure baseline operational hardening, security headers, rate limiting, and debug removal before going live.*

1. **Startup Environment Validation**:
   - The application must validate required environment variables at boot (e.g. using Zod or startup assertions) and fail immediately if critical secrets are missing.
2. **Debug Debris Removal**:
   - Remove debugging `console.log` statements, commented-out test blocks, and placeholder security comments (`TODO: fix auth`).
   - Eliminate test-only backdoor routes (e.g. `/test`, `/debug`, `/admin-backdoor`, `/seed-data`).
   - Debug mode must default to `OFF` (`NODE_ENV=production`).
3. **Generic Error Responses**:
   - Error responses returned to clients must never contain stack traces, database query dumps, internal file paths, or server framework versions.
   - Return a clean error code, user-friendly message, and unique correlation ID for server log lookup.
4. **Security Headers**:
   - Enforce standard HTTP security headers on all responses:
     - `X-Content-Type-Options: nosniff`
     - `X-Frame-Options: DENY`
     - `Strict-Transport-Security: max-age=31536000; includeSubDomains`
     - `Content-Security-Policy`
     - In Express apps, invoke `helmet()`.
5. **Rate Limiting on Authentication**:
   - Protect all authentication endpoints (`/login`, `/signup`, `/forgot-password`, `/otp`) with rate limiters.
   - Baseline: Maximum 5 attempts per minute per IP on login; 3 per hour on password resets.
6. **CORS Isolation**:
   - Prohibit wildcard CORS (`Access-Control-Allow-Origin: *`) on authenticated API endpoints. Restrict allowed origins strictly to your production domain.

---

## 🧩 Pass 4: Business Logic & Auth Defense (Based on Trail of Bits)
*Goal: Eliminate Broken Object-Level Authorization (IDOR), payment manipulation, and injection flaws.*

1. **IDOR & Ownership Verification**:
   - Never trust a `userId`, `orderId`, or `documentId` passed in the request body or URL query.
   - Always verify that the authenticated session user actually owns the requested resource before returning or mutating data.
2. **Sovereign Payment Logic**:
   - Never trust client-side price, quantity, or discount calculations. The server must independently look up product prices in the database and calculate totals.
   - Verify cryptographic webhook signatures from payment gateways (Stripe, Razorpay) before provisioning paid entitlements.
3. **Input Sanitization & Parameterization**:
   - Enforce parameterized SQL queries or ORM sanitization. Zero string-concatenated SQL queries.
   - Sanitize all user inputs before rendering into HTML to prevent Stored and Reflected XSS.
4. **Secure File Uploads**:
   - Validate file MIME types and magic bytes on the server.
   - Enforce file size limits and randomize uploaded filenames.
   - Never serve user-uploaded files from the primary domain with executable permissions.

---

## 🥷 Pass 5: Attacker's Perspective Review (Based on ECC Security Review)
*Goal: Proactively probe and stress-test the application the way a malicious actor would.*

1. **Privilege Escalation**:
   - If the application has roles (`user`, `admin`, `moderator`), verify role checks occur on the server side for every route, rather than merely hiding UI navigation links.
   - Test if modifying a role claim in a client-controlled token grants unauthorized access.
2. **Resource Exhaustion & Feature Abuse**:
   - Test what happens during rapid-fire requests: mass account registration, spam messaging, file upload flooding, or referral code reuse.
3. **Exposed Administrative Surfaces**:
   - Verify that `.env`, `.git`, database administrative panels, and internal Swagger/OpenAPI documentation are not exposed at public endpoints.
4. **Business Logic Exploitation**:
   - Test edge cases: negative payment values, infinite discount code stacking, free trial looping, and self-referral loops.
