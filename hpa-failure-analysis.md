# HPA Failure Analysis — W4D4

## Where today's scaler fails on the real engine

The CPU-based HPA works today because the echo backend is genuinely CPU-bound — it spends CPU per token, so CPU% tracks load. The team's real engine (vLLM) is GPU-bound instead: its CPU idles near single digits even while the GPU and its request queue are saturated. Confirmed this directly — pointed 32 concurrent callers at the team's `vllm` deployment for 90 seconds and watched `kubectl top pod`: CPU sat at ~15m against a 4-CPU request (well under 1%), the whole time the queue was filling. A CPU-percent HPA reading that number would hold at one replica through what is, from the caller's side, an outage: requests queueing or timing out with no scale-out ever triggered.

## The signal I'd deploy instead

In-flight/queued requests on the engine — vLLM exposes this as `vllm_num_requests_waiting` (Prometheus metric via `/metrics`). This is the right signal for this workload because it measures backpressure directly at the point where GPU-bound serving actually saturates: when the queue starts growing, the engine is behind, regardless of what CPU is doing. In-flight request count (concurrent requests being served) is a reasonable alternative but is noisier at low concurrency; queue depth only moves once the engine can't keep up, which is exactly the "start scaling now" signal.

## Target number and what I'd watch to tune it

Starting target: **~5 waiting requests per replica** (i.e., scale so that average queue depth per pod stays near 5) — a small buffer that tolerates brief bursts without holding excess idle GPU capacity, since GPU replicas are the expensive resource here. To tune it, I'd watch:
- `/health` (or the real endpoint) p95 latency during a load ramp, alongside the queue-depth curve — if p95 blows up well before queue depth crosses the target, the target is set too high and needs to come down.
- How often the HPA is actually triggering scale-out — if it never fires under real traffic, the target is too high; if it thrashes on small bursts, it's too low or the stabilization window is too short.
