# W4D4 Incident Notes — team-serving OOM / memory growth

## Symptom
`bash verify.sh` initially failed with `kubectl top has no metrics`. Root cause turned out to be upstream of metrics: `team-serving` was in `CrashLoopBackOff`.

## Root cause
`kubectl describe pod <pod>` showed:
```
Last State:   Terminated
Reason:       OOMKilled
Exit Code:    137
```
Readiness probes were failing with `connection refused` because the container was being OOMKilled before it ever opened port 8000.

The chart's default `resources.limits.memory: 512Mi` was not enough. Raising it (1Gi, then 2Gi) delayed but did not fix the crash. `kubectl top pods` over time showed memory climbing continuously even at near-zero CPU (idle):

| Pod | Age | Memory |
|---|---|---|
| team-serving-7d958959f5-5vfh9 | 145m | 2818Mi |
| team-serving-7d958959f5-sg42m | 90m | 2697Mi |
| team-serving-846c65959f-hnfmm (newer) | 30m | 1584Mi (still rising) |

Memory correlates with pod age / cumulative requests served, not current load — consistent with a **memory leak in the `lamaalfarraj/aidc-serving:cpu-v1` image's echo backend**, not a one-time sizing issue. Because the Deployment's rolling-update strategy uses `maxUnavailable: 0`, old (leaking) pods from prior ReplicaSets were kept alive waiting for new pods to become Ready, and the new pods kept OOMing before reaching Ready — a stuck loop across several `helm upgrade` revisions.

## Mitigation used to complete today's lab
Temporarily raised the memory limit high enough (4Gi) to get a pod stable for the few minutes verify.sh needs:
```
helm upgrade team ./serving-chart \
  --set image=lamaalfarraj/aidc-serving:cpu-v1 \
  --set hpa.enabled=true \
  --set hpa.targetCPUPercent=50 \
  --set hpa.maxReplicas=2 \
  --set resources.requests.memory=1Gi \
  --set resources.limits.memory=4Gi
```

## Result
```
load running; waiting for the HPA to move (up to 3 minutes)
scale event observed: desired replicas 1 -> 2
GREEN CHECK: PASS
```

## Follow-up (not fixed, just worked around)
This is a workaround, not a fix — memory will likely keep climbing and eventually OOM again at 4Gi too if the pod stays up long enough. The image itself needs investigation for what's accumulating in memory per request (e.g., unbounded request/response logging or history retained in the echo backend).
