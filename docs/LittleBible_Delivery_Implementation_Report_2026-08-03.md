# Little Bible Delivery Plan — Implementation Report

**Audit date:** 3 August 2026  
**Source plan:** `docs/LittleBible_Delivery_Plan.md`

## Implemented and verified in this pass

- Corrected the non-consumable product identifier to `com.littlebible.unlock`.
- Protected both Parent Hub and the unlock screen against direct-route access with `ParentGateService`.
- Added a reusable five-minute parental authorization window, immediate background expiry, and a one-minute lockout after five failed PIN attempts.
- Queued the platform, transaction ID and store-provided server verification data for server-side entitlement validation.
- Added persistent per-profile settings for autoplay, Quiet Story Mode, music, effects, notifications, reduced motion, Wi-Fi-only downloads and cloud sync.
- Added the required Drift v2→v3 migration and regenerated Drift/Riverpod sources.
- Made story playback respect autoplay, Quiet Story Mode and reduced-motion settings.
- Added a just-in-time cloud-sync disclosure describing uploaded, retained-local and prohibited data.
- Added privacy-minimised backend records for idempotent mobile progress and store entitlements.
- Added D1 migration `0002_mobile_privacy_sync.sql`.
- Added authenticated mobile endpoints:
  - `POST /api/mobile/progress`
  - `GET|PATCH /api/mobile/preferences`
  - `POST /api/mobile/consent`
  - `GET /api/mobile/account/export`
  - `DELETE /api/mobile/account`
  - `GET /api/mobile/manifest`
- Consent withdrawal now deletes previously synced mobile progress and disables future uploads.
- Account deletion uses one shared deletion path, deletes child/progress/session/sync/analytics records transactionally, and sends a confirmation email when configured.
- Added SUPER_ADMIN-only support deletion through `DELETE /api/admin/users`; `ANALYTICS_VIEWER` and other roles cannot call it.
- Added server validation that rejects prohibited child data fields and sync payloads larger than 4 KB.
- Added release-branch GitHub Actions for Flutter analysis/tests, signed iOS IPA/TestFlight upload, signed Android AAB/Play Internal upload, build-number increment and artifact retention.
- Fixed all Flutter analyser findings and the cancellable splash sequence test leak.

## Verification evidence

- `flutter analyze`: **pass, no issues**
- `flutter test`: **pass, 100 tests**
- `npm run build`: **pass, 236 routes/pages generated**
- `/api/mobile/manifest` and all new mobile account/sync routes appear in the production Next.js route manifest.
- Prisma format and client generation: **pass**

## Items that cannot be completed solely from this repository

These remain genuinely external and must not be checked off until evidence exists:

- Creating and approving `com.littlebible.unlock` in App Store Connect and Google Play Console.
- Supplying Apple distribution certificate, provisioning profile, App Store Connect API key, Android upload keystore and Google Play service-account secrets.
- StoreKit 2 and Google Play production receipt validation against live store credentials and registered applications.
- App Store/Play privacy, age-rating, Families, Data Safety and export-compliance declarations.
- TestFlight/Play tester enrolment, required elapsed testing periods, tester counts and feedback.
- Physical-device checks: iPhone SE/Samsung A14 offline regression, VoiceOver/TalkBack, background-task timing, IAP sandbox/license testing, 60 fps and notification taps.
- Child usability/safeguarding studies requiring recruited families, documented consent and human reviewers.
- Store review, staged rollout, crash/ANR observation windows and production promotion.
- Uploading content/audio to a provisioned R2 bucket and publishing a production KV manifest; the repository currently configures D1 and the Next.js cache KV only, with no content R2 binding or bucket ID.
- Transactional email delivery verification without a configured ZeptoMail test token.

## Remaining local engineering scope from later releases

The delivery plan intentionally marks Phase 2/3 games, complete OTA/R2 content ingestion, native background sync, live store receipt validators, publisher licensing/canary APIs, and portions of the multi-role content editor as post-MVP or later-release work. They are not represented as complete here merely because acceptance-criteria checkboxes exist in the master plan. Each should be delivered as a separately testable release slice; store- and human-dependent gates above remain prerequisites for production.
