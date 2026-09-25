# Service report

Team:Lihyan
Use case: Baseline chat completion service serving chat requests to users
Service and model: Qwen/Qwen2.5-1.5B-Instruct-AWQ, /v1/chat/completions
Measured requests or tasks: 120 chat completion requests
Indicator and unit: p95 time to first token (TTFT), seconds
SLO target and window: < 1.0 second over a 5-minute window
Measurement start and end: 2026-09-13T12:47:53+00:00 to 2026-09-13T12:50:53+00:00
Workload: Artificial chat traffic with max_tokens=64, using one caller followed by four concurrent callers
Observed result and sample count: 0.039 seconds (39 ms) p95 TTFT; 120 requests generated
Evidence: Grafana p95 Time to First Token panel and traffic.py output
Conclusion: MET — observed p95 TTFT was below the provisional 1.0-second SLO target during the measured workload
Limitations: The workload was short and artificial, so it does not establish compliance over a longer SLO window. Output quality and HTTP status outcomes were not measured.
Follow-up action: Repeat the measurement with longer and more representative traffic before treating this target as a production SLO.

## Measurement query
histogram_quantile(0.95, sum by (le) (rate(vllm:time_to_first_token_seconds_bucket{job="serving"}[5m])))
Evaluation: 5-minute rate window; evaluated during active traffic on 2026-09-13 UTC. The measurement is taken from the vLLM TTFT histogram for the serving job and excludes periods without usable observations.

## Service alert

Condition and unit: p95 TTFT is above 1.0 second (seconds)
Evaluation interval: 1 minute
Pending period: 1 minute
Relationship to the SLO: The alert fires when the measured p95 TTFT exceeds the provisional 1.0-second SLO target, providing an operational warning that user-perceived responsiveness may be degraded.
First response to a notification: Check the service traffic, Grafana TTFT measurement, and vLLM serving health.


## Notification test
Firing received at: 2026-09-14T08:58:30+00:00
Resolved received at: 2026-09-14T08:59:20+00:00
What the test establishes: The Grafana webhook contact point successfully delivered both firing and resolved notifications for the artificial Lab notification test. This verifies notification delivery and recovery handling, not model-service recovery.
