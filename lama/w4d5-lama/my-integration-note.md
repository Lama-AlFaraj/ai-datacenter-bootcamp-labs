# Integration note: t12 (v1, go-live)

Copy this file, fill every angle bracket, and hand it to your paired Agentic AI
team. It is Part A of the cross-cohort runbook
(`../../../week-06-capstone/cross-cohort-runbook.md`); the full operating rules
for the window live there.

- **base_url** (client form, ends in `/v1` - paste into an OpenAI client):
  `https://t12.aidc.nadir.sh/v1`
- **service root** (no `/v1` - the runbook's triage curls and `verify.sh`
  build paths from this): `https://t12.aidc.nadir.sh`
- **model id:** `Qwen/Qwen2.5-1.5B-Instruct-AWQ`
- **auth:** bearer key, handed over in person to the paired team's on-call
- **modalities:** text in, text out, tool calls per the OpenAI schema.
- **example call:** the exact curl from the green check, with the key
  redacted:
- **SLOs we publish:** availability 99% over the window · TTFT p95 < 500 ms
  (tier 1) · error rate < 1%
- **limits, declared honestly:** max_tokens clamp 512 · concurrency knee ~4
  (from wk-3 bench) · single GPU pod, no autoscaling
- **on-call:** t12 team · Slack #t12-oncall · response within 15 minutes during the window
