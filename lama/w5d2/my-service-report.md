# Service report

Team: lama
Use case: Content tagging and competency mapping service, chat-based model
Service and model: baseline chat service (job=serving), Qwen model via team-serving in namespace team
Measured requests or tasks: chat completion requests, TTFT histogram samples
Indicator and unit: p95 time to first token, seconds
SLO target and window: below 1.0 second, 5 minutes query window
Measurement start and end: 2026-09-14 11:18 to 11:21 UTC
Workload: shared baseline chat traffic on the team-wide serving job, single caller then four concurrent callers, 120 requests total
Observed result and sample count: p95 TTFT observed via live Prometheus samples at query time, based on 120 completed requests
Evidence: Team service alert rule, Grafana Explore query result, notification-evidence.jsonl
Conclusion: insufficient evidence
Limitations: short observation window, shared baseline service traffic not fully controlled by this team, single point-in-time reading rather than sustained SLO-window compliance
Follow-up action: extend measurement window and generate dedicated traffic to confirm sustained compliance

## Measurement query

The following query estimates p95 time to first token in seconds over a 5-minute window, evaluated as an instant query. It is measured at the Prometheus data source scraping the shared serving job, and excludes per-request success or output-quality validation.

```
histogram_quantile(0.95,
  sum by (le) (
    rate(vllm:time_to_first_token_seconds_bucket{job="serving"}[5m])
  )
)
```

## Service alert

Condition and unit: p95 TTFT above 1.0 second
Evaluation interval: 1 minute
Pending period: 1 minute
Relationship to the SLO: directly measures the same indicator and threshold documented for the service SLO
First response to a notification: check recent traffic volume and the serving service health, then inspect Prometheus Explore for the current TTFT distribution

## Notification test

Firing received at: 2026-09-14 11:24:30 UTC
Resolved received at: 2026-09-14 11:26:40 UTC
What the test establishes: the webhook path from Grafana alerting to the receiver correctly delivers both firing and resolved messages for an artificial threshold signal; it does not test the service query or its threshold
