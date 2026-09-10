# Step 5 — the policy your numbers justify

## Scenario
One node, 4 CPUs, three tenants:
- **serving** — your endpoint, p95 SLO, bursty
- **batch** — an embedding backfill, no deadline today
- **dashboard** — tiny, spiky on refresh

## 1. Policy sentence
<!-- One sentence, in words: who is guaranteed, who bursts, who throttles first. -->
TODO

## 2. resources: block per tenant

```yaml
# serving
resources:
  requests:
    cpu: TODO
    memory: TODO
  limits:
    cpu: TODO
    memory: TODO
```

```yaml
# batch
resources:
  requests:
    cpu: TODO
    memory: TODO
  limits:
    cpu: TODO
    memory: TODO
```

```yaml
# dashboard
resources:
  requests:
    cpu: TODO
    memory: TODO
  limits:
    cpu: TODO
    memory: TODO
```

## 3. Defence (one line, cite your two p95s)
<!-- e.g. "batch throttles first because with no cpu limit the serving p95
went from Xms to Yms under a noisy neighbour, and capping the neighbour at
500m brought it back to Zms — batch has no deadline today, serving does." -->
- Unlimited-neighbour p95: **TODO ms** (from Step 4, Run A)
- Limited-neighbour (cpu: 500m) p95: **TODO ms** (from Step 4, Run B)
- Defence: TODO

## Sanity check against the scenario
- [ ] serving's requests cover the burst actually measured
- [ ] batch's limit binds while its request stays low (first to throttle)
- [ ] `kubectl describe pod` QoS class per tenant matches the sentence above:
      serving = ______, batch = ______, dashboard = ______
