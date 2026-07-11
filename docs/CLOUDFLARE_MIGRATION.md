# Little Bible — Full Migration to Cloudflare

**Status:** Plan (pre-execution)
**Author:** Engineering
**Last updated:** 2026-07-11
**Target account:** `littlebible.org@gmail.com` (Cloudflare)

---

## 1. Objective

Move **every** part of Little Bible off the current Neon + Vercel/Render stack and onto a single, unified **Cloudflare** account:

- **Frontend + backend** (Next.js app) → Cloudflare Workers
- **Database** (PostgreSQL) → Cloudflare D1
- **Domain + DNS** (`littlebible.org`) → Cloudflare DNS + Registrar
- **Secrets / config** → Workers secrets
- **Email deliverability records** (SPF/DKIM/DMARC) → Cloudflare DNS

Goal: one vendor, one dashboard, one bill, one control plane. No production dependency on Neon, Vercel, or Render after cutover.

---

## 2. Current-state inventory

| Component | Today | Notes |
|---|---|---|
| App framework | Next.js 15.5 (App Router, React 19), TypeScript | `next-auth@5 beta`, Tailwind v4 |
| Hosting | Vercel (linked in `.vercel/`); `render.yaml` also present | Region `lhr1` on Vercel |
| Database | Neon PostgreSQL | Prisma 7 + `@prisma/adapter-pg` (pg Pool), `lib/prisma.ts` |
| ORM | Prisma 7, 19 models, 1 enum | Migrations in `prisma/migrations/` |
| Auth (users) | NextAuth v5, Google OAuth, **DB sessions** via `PrismaAdapter` | `auth.ts` |
| Auth (admin) | Custom HMAC token, `node:crypto` | `lib/admin/session.ts`, cookie-gated in `middleware.ts` |
| Content | 5.1 MB static JSON, 149 files in `public/data/` | Read at **build time** via `fs.readFileSync` (`lib/content.ts`, `lib/stories.ts`, `lib/topics.ts`) |
| Audio | Client-side Web Speech API | No server media assets — nothing to migrate |
| Email | ZeptoMail (Zoho) HTTP API via `fetch` | `lib/email.ts` — Workers-compatible as-is |
| Payments | Stripe (USD) + Paystack (NGN) | `app/api/donate/*` |
| Domain | `littlebible.org` | Registrar/DNS = **to be confirmed** (see §11) |
| Repo | `github.com/discipledeckapp/little-bible` | CI/CD currently Vercel Git integration |

### API surface (14 routes) — all need to run on Workers
```
/api/auth/[...nextauth]        /api/family, /family/dashboard, /family/members[/id], /family/progress
/api/progress                  /api/activities/record
/api/donate/stripe             /api/donate/paystack
/api/app-interest              /api/admin/{stats,users,app-interest}
```

---

## 3. Target Cloudflare architecture

| Concern | Cloudflare service | How |
|---|---|---|
| Next.js SSR + API routes | **Workers** via `@opennextjs/cloudflare` (OpenNext) | Runs full App Router incl. server components & route handlers |
| Static assets (`public/`, `.next/static`) | **Workers Static Assets** | Served at edge, bundled by OpenNext |
| Database | **D1** (SQLite) | Prisma via `@prisma/adapter-d1` |
| DB caching/pooling | Not needed | D1 is edge-native; no pooler required |
| Incremental cache / revalidation | **Workers KV** (OpenNext cache) | Only if we use ISR; app is largely SSG |
| Secrets | **Workers secrets** (`wrangler secret put`) | Replaces Vercel/Render env vars |
| DNS | **Cloudflare DNS** | Zone for `littlebible.org` |
| Registrar | **Cloudflare Registrar** | Transfer domain (optional but recommended for single-vendor) |
| Email DNS | **Cloudflare DNS** records | SPF/DKIM/DMARC for ZeptoMail; MX unchanged |
| CI/CD | **Wrangler** via GitHub Actions (or CF Workers Builds) | Replaces Vercel Git integration |

> **Why Workers + OpenNext, not Cloudflare Pages:** Pages' Next.js support lags on App Router SSR. OpenNext's Cloudflare adapter is the current, actively-maintained path for full Next.js 15 App Router on Cloudflare and is what CF's own docs point to.

---

## 4. Key decisions & trade-offs

### 4.1 Database: D1 (chosen) vs Hyperdrive + external Postgres

Cloudflare has **no first-party managed Postgres**. "Database on Cloudflare" therefore means one of:

- **D1 (SQLite) — CHOSEN.** Truly on Cloudflare, no external dependency, no egress cost, edge-native. **Cost:** requires a real Postgres→SQLite schema + data migration (see §6). The dataset is small (user/family/progress rows + analytics), well within D1's 10 GB limit.
- **Hyperdrive + Neon/other Postgres (fallback).** Keeps Prisma/Postgres unchanged, but the **database still lives off Cloudflare** — this does *not* satisfy the "everything on Cloudflare" goal. Documented only as a rollback/de-risking option if the SQLite migration proves too costly.

**Decision: D1.** The schema migration is bounded and the data volume is tiny.

### 4.2 Schema changes required for SQLite/D1

Prisma on SQLite does **not** support several Postgres features currently in `schema.prisma`. These must be refactored:

| Current (Postgres) | Location | Change for D1 |
|---|---|---|
| `enum AdminRole { ... }` | `User.role` | Convert to `String` + app-level validation |
| `String[]` scalar lists | `UserProgress.completedChapters`, `FamilyMember.faithGoals`, `MemberProgress.completedChapters` | Convert to JSON-encoded `String` (pattern already used by `*Json` fields) |
| `Json?` | `AnalyticsEvent.props`, `AdminAuditLog.details` | Convert to `String?` holding JSON |
| `@db.Text` | multiple | Remove (no-op in SQLite) |

Everything else (`cuid()`, `@default(now())`, `@updatedAt`, `DateTime`, relations, `@@unique`) ports cleanly.

### 4.3 Hosting: Workers via OpenNext — compatibility checklist

- `nodejs_compat` flag **on** (needed for `node:crypto` in `lib/admin/session.ts` and `pg` removal).
- `fs.readFileSync` for content (`lib/content.ts` et al.) runs at **build time** because all four content routes use `generateStaticParams`. **Action:** set `export const dynamicParams = false` on `[book]`, `[book]/[chapter]`, `stories/[id]`, `topics/[slug]` so unknown slugs 404 instead of attempting a runtime `fs` read on the Worker (where the file tree isn't available). Confirm a full SSG build produces every expected page.
- NextAuth **DB sessions** work on Workers with the Prisma D1 adapter; no code change beyond the adapter swap.
- ZeptoMail email is plain `fetch` — no change.
- Stripe/Paystack SDK calls are `fetch`-based — verify the Stripe SDK's runtime (may need the `stripe` client configured for `fetch`/Workers, or call the REST API directly).

---

## 5. Risks & mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Postgres→SQLite data migration errors | User progress/family data loss | Dry-run migration to a staging D1, row-count + spot-check parity before cutover; keep Neon read-only as fallback for 2 weeks |
| Runtime `fs` read on Worker for an un-prerendered slug | 500 on edge | `dynamicParams = false` + full SSG verification (§4.3) |
| Stripe SDK not Workers-compatible | Donations break | Test in `wrangler dev`; fall back to direct REST calls if SDK misbehaves |
| Google OAuth redirect URIs | Login breaks post-cutover | Add Workers preview + prod callback URLs in Google Cloud Console **before** cutover |
| DNS cutover downtime | Site unreachable | Low-TTL pre-stage; parallel-run new stack on a preview hostname and validate before flipping the apex |
| Admin session secret / NextAuth secret mismatch | All sessions invalidated | Migrate secrets verbatim; expect (and communicate) a one-time re-login |
| Prisma migration history (Postgres) incompatible with D1 | Migrate fails | Start a fresh D1 migration baseline; don't reuse the Postgres migration SQL |

---

## 6. Migration workstreams (phased)

Each phase is independently verifiable. Nothing in production changes until Phase 6 (DNS cutover).

### Phase 0 — Access & foundation *(blocked on you: token — see §12)*
1. Receive Cloudflare API token for `littlebible.org@gmail.com`.
2. `wrangler login` / configure token; confirm account access.
3. Create `wrangler.jsonc`, add `@opennextjs/cloudflare`, `@prisma/adapter-d1`.
4. Create empty **D1** database (`little-bible-db`) and **KV** namespace (OpenNext cache).

### Phase 1 — App runs on Workers (no prod traffic)
1. Add OpenNext config (`open-next.config.ts`), build scripts, `nodejs_compat`.
2. Add `dynamicParams = false` to content routes; verify full SSG build.
3. `wrangler dev` locally → smoke-test all pages + API routes against a **staging** D1.
4. Deploy to a `*.workers.dev` / preview subdomain.

### Phase 2 — Database migration to D1
1. Refactor `schema.prisma` for SQLite (§4.2); generate a fresh D1 migration baseline.
2. Swap `lib/prisma.ts` to `@prisma/adapter-d1` (D1 binding).
3. Update app code touching the changed fields (enum → string, arrays/JSON → parse/stringify).
4. **Data migration:** export Neon → transform (arrays/enums/JSON → SQLite encoding) → import to D1. Validate row counts + spot-check per table.

### Phase 3 — Secrets & integrations
1. `wrangler secret put` for every key in §10.
2. Register Workers prod + preview URLs as Google OAuth redirect URIs.
3. Re-point Stripe & Paystack webhooks (if any) to the Workers domain.
4. Verify ZeptoMail sends from the Worker.

### Phase 4 — DNS zone onboarding (no cutover yet)
1. Add `littlebible.org` as a zone in the Cloudflare account.
2. Recreate **all** existing DNS records (A/AAAA/CNAME/MX/TXT — ZeptoMail SPF/DKIM, DMARC, any verification TXT).
3. Do **not** change nameservers yet — just stage the zone.

### Phase 5 — Full staging validation on a real hostname
1. Bind a `staging.littlebible.org` (or preview) hostname to the Worker.
2. Run the §9 validation checklist end-to-end (auth, family, progress, donations, admin, email).

### Phase 6 — Production cutover
1. Lower current DNS TTLs 24–48h ahead.
2. Point the apex/`www` route to the Worker (Custom Domain in Workers).
3. Switch nameservers to Cloudflare (if not already) — activates the zone.
4. Monitor: errors, auth success, donation success, email delivery.
5. Set Neon to read-only; keep Vercel/Render deploys paused but intact for rollback.

### Phase 7 — Domain registrar transfer *(optional, single-vendor goal)*
1. Unlock domain at current registrar, get auth/EPP code.
2. Transfer `littlebible.org` to **Cloudflare Registrar**.

### Phase 8 — Decommission (after 2-week soak)
1. Delete Vercel project + Render service.
2. Delete/downgrade Neon.
3. Remove `vercel.json`, `render.yaml`, `.vercel/` from repo.
4. Update CI/CD to Wrangler-based deploy.

---

## 7. CI/CD after migration

Replace Vercel's Git integration with a GitHub Action running `wrangler deploy` (via OpenNext build) on push to `main`, or use **Cloudflare Workers Builds** (native Git connect). Preview deployments per-PR via Workers preview URLs.

---

## 8. New/changed files (anticipated)

```
wrangler.jsonc                 # Workers + D1 + KV bindings, nodejs_compat, routes
open-next.config.ts            # OpenNext Cloudflare adapter config
lib/prisma.ts                  # @prisma/adapter-d1 instead of adapter-pg
prisma/schema.prisma           # SQLite provider + §4.2 schema changes
app/[book]/**, stories, topics # dynamicParams = false
package.json                   # scripts: build:cf, deploy, cf-typegen; new deps
.github/workflows/deploy.yml   # wrangler deploy (replaces Vercel)
docs/CLOUDFLARE_MIGRATION.md   # this doc
# removed after Phase 8: vercel.json, render.yaml, .vercel/
```

---

## 9. Post-migration validation checklist

- [ ] All static pages render (home, library, `/[book]/[chapter]`, stories, topics, journeys)
- [ ] Unknown slug returns 404 (not 500) — confirms `dynamicParams=false`
- [ ] Google sign-in → session persists (DB session in D1)
- [ ] Welcome email sends on new user (ZeptoMail)
- [ ] Progress sync (`/api/progress`) reads/writes D1
- [ ] Family create / members / dashboard / progress all work
- [ ] Activity + memory-verse records persist
- [ ] Stripe donation completes (test mode)
- [ ] Paystack donation completes (test mode)
- [ ] Admin login (HMAC cookie) + `/admin/*` gated correctly
- [ ] Admin stats/users/app-interest endpoints return data from D1
- [ ] Data parity: row counts per table match Neon export
- [ ] TTS (Web Speech) unaffected (client-side)
- [ ] Email DNS: SPF/DKIM/DMARC pass (mail-tester)
- [ ] Lighthouse/perf no regression at edge

---

## 10. Secrets / env mapping (Vercel/Render → Workers)

Migrate each as a Workers secret (`wrangler secret put NAME`). `NEXT_PUBLIC_*` become build-time vars.

| Key | Type | Change |
|---|---|---|
| `NEXTAUTH_SECRET` | secret | verbatim |
| `NEXTAUTH_URL` | var | → `https://littlebible.org` |
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | secret | verbatim (add new redirect URIs) |
| `DATABASE_URL` / `DIRECT_URL` | — | **removed** (replaced by D1 binding) |
| `STRIPE_SECRET_KEY` / `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` | secret / var | verbatim |
| `PAYSTACK_SECRET_KEY` / `NEXT_PUBLIC_PAYSTACK_PUBLIC_KEY` | secret / var | verbatim |
| `ZEPTOMAIL_TOKEN` / `ZEPTOMAIL_FROM_EMAIL` / `ZEPTOMAIL_FROM_NAME` | secret / var | verbatim |
| `NEXT_PUBLIC_APP_URL` | var | → `https://littlebible.org` |
| `ADMIN_EMAIL` / `ADMIN_PASSWORD` / `ADMIN_SESSION_SECRET` | secret | verbatim |
| D1 binding (`DB`) | binding | **new** — in `wrangler.jsonc` |
| KV binding (cache) | binding | **new** — OpenNext incremental cache |

---

## 11. Open questions (need answers before / during execution)

1. **Where is `littlebible.org` registered today**, and where are its nameservers? (Determines Phase 4/6/7 steps.)
2. **Are there live Stripe/Paystack webhooks** pointed at the current domain that need re-registration?
3. **Current DNS records** — do we have a full export? (Need MX + any verification TXT beyond ZeptoMail.)
4. Confirm production is on **Vercel** (per `.vercel/`) — is Render actually in use, or is `render.yaml` dead config?
5. Any **cron jobs / scheduled tasks** (e.g., app-interest notifications)? None found in code — confirm.
6. Acceptable **cutover window** and who approves the DNS flip.

---

## 12. What I need from you to start

To execute Phase 0 I need a **Cloudflare API token** scoped to the `littlebible.org@gmail.com` account with:

- **Account** → Workers Scripts (Edit), Workers KV Storage (Edit), D1 (Edit), Account Settings (Read), Cloudflare Pages (Edit — optional)
- **Zone** → DNS (Edit), Zone (Read/Edit), SSL and Certificates (Edit) for `littlebible.org`

Create it at **dash.cloudflare.com → My Profile → API Tokens → Create Token** (the "Edit Cloudflare Workers" template plus DNS/D1 permissions is closest). Paste the token when ready and I'll begin with Phase 0–1 (stand up the Worker + D1, zero production impact).

> Note: I'll treat the token as a secret — it goes into local Wrangler config only, never committed. You can revoke it after migration.
