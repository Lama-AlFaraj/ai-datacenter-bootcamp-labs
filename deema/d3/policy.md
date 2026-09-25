Serving is guaranteed first, dashboard is allowed to burst, and batch throttles first when CPU is contested.

serving:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 1
    memory: 512Mi

batch:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi

dashboard:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi

Batch is the loser because the measured serving p95 was 5ms with an unlimited neighbour versus 3ms when the neighbour was limited to 500m, showing that CPU contention can hurt serving latency.
