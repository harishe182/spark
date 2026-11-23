# Researcher Guide — Exports & Analysis

## Running an export

Open the app → participant list → **download** icon → **Export Data**:

- **Full export** — everything needed for analysis.
- **Blind rater export** — drawings only, de-identified, for TTCT/blind rating.

Each export writes a timestamped folder under the app documents directory and
reports the **file count** and an integrity **checksum**.

## Full export contents

```
export_<timestamp>/
  data.json       # full structured records (see below)
  summary.csv     # one analysis row per session
  images/         # every drawing artifact (final, snapshots, pre/post)
  manifest.json   # per-file checksums + a single export checksum
```

### `summary.csv` columns

One row per session. Key fields:

| Column | Meaning |
|--------|---------|
| `participant_id`, `condition`, `mode`, `week_number` | identifiers |
| `idea_count`, `child_idea_count` | idea fluency, child-authored count |
| `accepted_suggestion_count` | accepted Spark hints in the list (reliance) |
| `spark_shown_count`, `spark_accepted_count`, `spark_rejected_count` | Spark interaction |
| `spark_acceptance_rate` | accepted / shown (blank if none shown) |
| `selected_idea_source` | source of the idea chosen for the drawing |
| `*_seconds` | time spent in each phase |
| `ownership_rating`, `creativity_rating`, `hint_helpfulness_rating` | reflection |
| `facilitator_override_count` | manual phase advances |

### `data.json`

Per participant + per session: the session record, all phases, ideas (with
source), every Spark event (shown/accepted/rejected, timestamps), artifacts,
reflection, facilitator notes, and override events. Use this for anything the
CSV summary doesn't pre-compute (e.g. Spark event timing, idea text for
similarity analysis).

## Blind rater export

```
blind_<timestamp>/
  images/            # renamed A0001.png, A0002.png … (NO condition/id)
  blind_manifest.json # blind_code → artifact_type + image (rater-safe)
  blind_key.csv       # blind_code → participant_id, condition, session  ← RESEARCHER ONLY
```

Give raters **only** `images/` + `blind_manifest.json`. **Withhold
`blind_key.csv`** until after rating to preserve blinding, then join on
`blind_code` to un-blind.

## Suggested analyses (supported by the export)

- **Idea generation (H1):** `idea_count`, `child_idea_count` by condition/week.
- **Drawing creativity (H2):** TTCT/blind ratings of final drawings (blind export).
- **Convergence/similarity (H3):** embed `idea_text` (from `data.json`) and
  final drawings; compare within-condition similarity.
- **Ownership (H4):** `ownership_rating` vs `spark_acceptance_rate`.
- **Independent transfer (H5/H6):** pre-test → post-test change (blind-rated
  drawings), by condition.
- **Reliance:** `accepted_suggestion_count`, `spark_acceptance_rate`, and
  whether `selected_idea_source` is a Spark source.

## Integrity

Every export's `manifest.json` lists a SHA-256 per file plus one overall
checksum. Re-hash on receipt to confirm nothing was altered in transit.
