# Security & Privacy Checklist (HIPAA / FERPA)

This app handles data from minors in a research context. Review before any
real-participant deployment.

## Data minimization (built in)

- [x] **No child names stored** — participant IDs only (`P001`…).
- [x] **No PII sent to the LLM** — AI-Spark requests contain only the prompt,
      idea list, accepted/rejected suggestions, phase, and time remaining.
      Verified by `test/ai_spark_test.dart`.
- [x] **Condition hidden from the child** — no AI/control/experiment wording in
      any child-facing screen.
- [x] **Offline-first** — all data is written to local encrypted storage first.

## Encryption at rest

- [x] Local database uses SQLCipher (`sqflite_sqlcipher`).
- [ ] **Action required before production:** replace the development passphrase
      in `lib/main.dart` with a device-held key from platform secure storage
      (iOS Keychain / Android Keystore). The current placeholder is clearly
      marked `SECURITY (MVP)`. Do **not** ship the placeholder.
- [ ] Enable full-disk encryption / MDM on the research tablets.

## Cloud sync (Firebase)

- Project: `studio-577683141-7bdbd` (shared project; Spark data is isolated in
  the `participants` / `sessions` Firestore collections).
- [x] **Firestore-only** on the free plan — session data syncs; drawing images
      are NOT uploaded (Cloud Storage needs Blaze). PNGs stay local and reach
      the researcher via the local export.
- [x] Security rules deployed (`firestore.rules`): all access requires an
      authenticated user; unauthenticated access is denied.
- [x] App authenticates via **anonymous auth** before syncing.
- [ ] **Console action required:** enable the Anonymous sign-in provider
      (Authentication → Sign-in method). Until then, sync skips with
      "Not signed in" (no crash; data stays queued locally).
- [ ] Tighten rules with a custom `role` claim once staff accounts are
      provisioned (rules already have a `isStaff()` seam).
- [ ] Sync is **Wi-Fi-gated** and **opt-out** (facilitator toggle on the
      export screen).

## Encryption in transit

- [x] LLM calls use HTTPS (`https://api.openai.com`).
- [x] Firebase traffic is TLS; Firestore encrypts at rest.
- [ ] Client-side encryption of payloads before upload is a planned hardening
      step (currently relying on Firebase at-rest + rules).

## Secret management

- [x] OpenAI API key is **not hardcoded** — supplied via
      `--dart-define=OPENAI_API_KEY`. Absent key → AI-Spark degrades gracefully.
- [ ] Store the key in your CI/build secrets, not in source control.
- [ ] Rotate the key if a tablet is lost or the key may be exposed.

## Audit & integrity

- [x] All facilitator overrides (early advance, end-early) are logged with
      timestamps (`override_events`).
- [x] Exports carry per-file + overall SHA-256 checksums (`manifest.json`).

## Rater blinding

- [x] Blind export strips condition and participant id; drawings are renamed to
      opaque codes.
- [ ] **Withhold `blind_key.csv`** from raters until rating is complete.

## Operational

- [ ] Keep the ID↔child roster on secure, access-controlled storage separate
      from the tablets.
- [ ] Define data retention & destruction per your IRB protocol.
- [ ] Confirm IRB approval covers AI processing of (de-identified) creative
      content via a third-party API, or switch to a self-hosted model.
