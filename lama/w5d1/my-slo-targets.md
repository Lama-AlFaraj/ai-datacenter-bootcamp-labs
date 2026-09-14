Team: lama
Use case: Content tagging and competency mapping service, chat-based model
Service measured: Qwen/Qwen2.5-0.5B-Instruct via team-serving in namespace lama, measured through a metrics proxy
Workload: bounded lab traffic via traffic.py, single caller then up to 4 concurrent callers, max_tokens=64
Measurement period: 2026-09-14 08:57 to 08:59 UTC
Instrumentation gaps: the backend does not expose native Prometheus metrics; a sidecar proxy was added to measure request count and latency

## SLI 1

Indicator: p95 latency of chat completion requests
Panel: p95 latency
Unit: seconds
Target: below 30 s
Window: 5 minutes query window
Observed: approximately 27 s under single-caller load
Evidence: Team service dashboard, p95 latency panel
Why it fits: users need a bounded response time for tagging requests
Limitations: short workload window; concurrent load pushes latency well above this target

## SLI 2

Indicator: completed chat completion requests per minute
Panel: Completed requests/min
Unit: requests/min
Target: above 0 requests/min sustained
Window: 5 minutes query window
Observed: approximately 7 successful requests over the measurement period
Evidence: Team service dashboard, Completed requests/min panel
Why it fits: confirms the service processes tagging requests successfully
Limitations: very small sample; does not establish throughput under sustained concurrent load
