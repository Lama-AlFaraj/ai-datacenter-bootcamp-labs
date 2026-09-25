# Service report

Team: Lihyan
Use case: OpenAI-compatible interactive text chat inference for clients sending chat requests.
Service and model: Qwen/Qwen2.5-1.5B-Instruct-AWQ on /v1/chat/completions in namespace team.
Measured requests or tasks: 120 artificial chat requests.
Indicator and unit: p95 time to first token (TTFT), seconds.
SLO target and window: p95 TTFT < 0.05 seconds over a proposed 30-minute SLO evaluation window; provisional target.
Measurement start and end: 2026-09-15 13:22:09 UTC to 2026-09-15 13:25:09 UTC.
Workload: One caller for 60 seconds, 30-second quiet period, then four callers for 60 seconds; max_tokens=64.
Observed result and sample count: p95 TTFT approximately 0.03896 seconds during the 120-request artificial workload.
Evidence: Grafana Team service dashboard, Team service alert - Rawan, and notification-evidence.jsonl.
Conclusion: insufficient evidence
Limitations: The workload lasted only about three minutes and cannot establish compliance over the proposed 30-minute SLO window. TTFT measures response start latency but not HTTP success status or model-output quality. Results are based on short artificial traffic and Prometheus histogram estimates.
Follow-up action: Repeat the measurement over a longer representative workload and separately validate HTTP success and model-output quality.

## Measurement query

```promql
histogram_quantile(
  0.95,
  sum by (le) (
    rate(vllm:time_to_first_token_seconds_bucket{job="serving"}[5m])
  )
)

```
The query was evaluated as an instant Prometheus query using a fixed 5-minute rate window after traffic generated from 2026-09-15 13:22:09 UTC to 13:25:09 UTC. It measures p95 time to first token from the vLLM serving metrics. It does not measure HTTP success status, complete response latency, or output quality.

## Service alert

Condition and unit: p95 TTFT is above 0.05 seconds.
Evaluation interval: 1 minute.
Pending period: 1 minute.
Relationship to the SLO: The alert uses the same p95 TTFT indicator and 0.05-second threshold as the provisional user-facing SLO. It warns when response-start latency remains above the target rather than reacting to a single instantaneous reading.
First response to a notification: Check current request traffic and vLLM health, then inspect the TTFT metric and serving logs for latency or resource pressure.

## Notification test

Firing received at: 2026-09-15 13:58:23 UTC.
Resolved received at: 2026-09-15 13:59:03 UTC.
What the test establishes: The artificial Lab notification test successfully delivered both firing and resolved webhook notifications to Lab inbox. It verifies Grafana notification delivery and recovery signaling, not recovery of the model service itself.
