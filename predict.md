# Predict (by hand) — W4D4

**1. `helm install team ./serving-chart` then `helm install shadow ./serving-chart`: what exists in the cluster that could not exist with plain `kubectl apply` of the same YAML twice?**

Two independent Helm *releases*, each tracked separately with its own release history, revision number, and values — and each release prefixes its object names (`team-serving`, `shadow-serving`), so the two Deployments/Services coexist without colliding. Plain `kubectl apply` of the same manifest twice would just re-apply the *same* object names and overwrite one Deployment in place — it can't produce two coexisting copies, because nothing in raw YAML namespaces the objects per install the way the release name does in the chart's templates.

**2. HPA targets 50% of a 250m CPU request. Load pushes each pod to ~300m. How many replicas does the controller want?**

Target usage = 50% of 250m = 125m per pod.
desiredReplicas = ceil(currentReplicas × currentUsage / targetUsage) = ceil(1 × 300 / 125) = ceil(2.4) = **3 replicas**.

**3. When load stops, do replicas drop immediately? What is the risk if they did?**

No — the HPA waits out a stabilization window (60s in this lab's values, default 300s) before scaling down, even after the metric drops. If it scaled down immediately instead, a brief dip in traffic (or a metrics blip) would trigger a scale-in, and then the very next request burst would hit too few replicas — flapping between scale-out and scale-in, with latency spikes each time capacity gets pulled away too early.
