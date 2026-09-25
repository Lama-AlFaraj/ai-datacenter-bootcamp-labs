# Integration note: Lihyan (v1, go-live)

- **base_url** (client form, ends in `/v1`):
  `https://t12.aidc.nadir.sh/v1`

- **service root**:
  `https://t12.aidc.nadir.sh`

- **model id:** `Qwen/Qwen2.5-1.5B-Instruct-AWQ`

- **auth:** bearer key, handed over by DM to the paired team's on-call; never stored in this file

- **modalities:** text in, text out, tool calls per the OpenAI schema. Week-2 modality agreement was not available at the time of writing.

- **example call:**
  `curl -s https://t12.aidc.nadir.sh/v1/models -H "Authorization: Bearer REDACTED"`

- **SLOs we publish:** availability best-effort during the course window · TTFT p95 to be confirmed from the team's measured benchmark · error rate target to be confirmed from the team's measured benchmark

- **limits, declared honestly:** max_tokens clamp 256 · concurrency knee to be confirmed from the team's Week-3 benchmark · service is backed by one shared GPU engine

- **on-call:** Rawan Bu Khowah · team Lihyan channel · response as soon as possible during the course window
