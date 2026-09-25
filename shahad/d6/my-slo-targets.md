# Service indicators and proposed targets

Team: shahad
Use case: Baseline chat completion service serving chat requests to users
Service measured: Qwen/Qwen2.5-1.5B-Instruct-AWQ, /v1/chat/completions, namespace shahad
Workload: Chat completion requests with max_tokens=64, using single and four concurrent callers
Measurement period: 2026-09-13 UTC
Instrumentation gaps: HTTP status outcomes are not available from the vLLM request-success metric; longer-term measurement requires additional representative workloads

## SLI 1

Indicator: p95 time to first token (TTFT)
Panel: p95 Time to First Token
Unit: seconds
Target: < 1.0 seconds (provisional user-outcome SLO)
Window: 5 minutes
Observed: 0.039 seconds (39 ms) during active traffic
Evidence: Grafana p95 Time to First Token panel using vllm:time_to_first_token_seconds_bucket; active measurements were approximately 24–39 ms on 2026-09-13 UTC
Why it fits: TTFT directly measures how quickly users begin receiving generated output and therefore reflects perceived responsiveness of the chat service
Limitations: The workload was short and artificial; longer and repeated measurements with representative traffic are required before treating the target as a production SLO

## SLI 2

Indicator: completed requests per minute
Panel: Completed Requests/min
Unit: requests/min
Target: >= 20 requests/min (provisional operating target)
Window: 5 minutes
Observed: 50.5 requests/min peak observed during active traffic
Evidence: Grafana Completed Requests/min panel using 60 * sum(rate(vllm:request_success_total{job="serving", finished_reason=~"stop|length"}[5m])); active traffic reached 50.5 requests/min on 2026-09-13 UTC
Why it fits: Completed request throughput measures the service's ability to process user requests and sustain useful chat workload volume
Limitations: The 5-minute rate is smoothed and falls to zero when traffic stops; the workload was artificial and short, so the target should be retested with longer and more representative traffic
