# Service indicators and proposed targets

Team: Lihyan
Use case: OpenAI-compatible text chat inference service for clients sending interactive chat requests.
Service measured: Qwen/Qwen2.5-1.5B-Instruct-AWQ, /v1/chat/completions, namespace team
Workload: Artificial chat traffic with max_tokens=64; one caller for 60 seconds, 30-second quiet period, then four callers for 60 seconds; 120 total requests.
Measurement period: 2026-09-14 10:43:54 UTC to 2026-09-14 10:46:54 UTC
Instrumentation gaps: No HTTP-status request counter or output-quality validation is currently included in these SLIs. Targets below are provisional and require longer-duration measurement.

## SLI 1

Indicator: p95 time to first token (TTFT) for chat requests
Panel: p95 TTFT
Unit: seconds
Target: p95 TTFT < 0.05 seconds; provisional user-facing SLO
Window: PromQL rate window 5 minutes; proposed SLO evaluation window 30 minutes
Observed: approximately 0.020-0.039 seconds during the artificial lab workload
Evidence: histogram_quantile(0.95, sum by (le) (rate(vllm:time_to_first_token_seconds_bucket{job="serving"}[5m]))), measured after traffic ending 2026-09-14 10:46:54 UTC
Why it fits: TTFT measures how quickly a chat user sees the service begin responding, so it directly represents perceived responsiveness.
Limitations: Measurement covers only a short 120-request lab workload. The histogram percentile is estimated from bucket boundaries and should be retested over longer periods and with realistic production traffic.

## SLI 2

Indicator: completed successful chat requests per minute
Panel: Completed requests/min
Unit: requests/min
Target: >= 20 requests/min during the four-caller lab workload; provisional operating target
Window: PromQL rate window 5 minutes; proposed SLO evaluation window 30 minutes
Observed: approximately 25 requests/min at the peak of the four-caller phase
Evidence: 60 * sum(rate(vllm:request_success_total{job="serving", finished_reason=~"stop|length"}[5m])), measured after traffic ending 2026-09-14 10:46:54 UTC
Why it fits: Completed requests per minute measures the service's ability to finish useful chat requests while multiple users are active.
Limitations: Completion counts stop and length finishes but does not prove output quality or HTTP success status. The observed rate comes from a short artificial workload and needs longer sustained-load testing.
