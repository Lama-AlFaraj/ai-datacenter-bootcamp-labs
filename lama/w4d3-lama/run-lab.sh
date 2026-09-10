#!/usr/bin/env bash
# W4D3 guided runbook — run this ON THE TEAM POD, in your own namespace ($ME).
# It does NOT run Step 5 (writing policy.md) or Step 6 (team engine — that's a
# once-per-team, coordinated step, not a solo script). Run section by section;
# it pauses (press Enter) wherever the lab needs you to look at output or wait
# for a teammate before continuing.
set -u
pause() { read -rp "   -> $1 [Enter to continue] "; }
hr() { echo "----------------------------------------------------------------"; }

echo "Namespace check:"
kubectl config view --minify | grep namespace:
pause "Confirm this is YOUR namespace ($ME), not team"

hr
echo "STEP 1 — give the serving deployment a ledger entry"
echo "Open your Sunday deployment.yaml (probably ../d2-self-healing/deployment.yaml)"
echo "and add this under the serving container's spec (see resources-patch.yaml"
echo "in this folder for the exact block to paste in):"
cat resources-patch.yaml
echo
read -rp "Path to your deployment.yaml (e.g. ../d2-self-healing/deployment.yaml): " DEPLOY_FILE
pause "Paste the resources: block into that file's serving container now, save it"
kubectl apply -f "$DEPLOY_FILE"
kubectl rollout status deployment/serving
kubectl describe node | grep -A8 'Allocated resources'

hr
echo "STEP 2 — overdraw the ledger"
kubectl apply -f impossible-cpu.yaml
sleep 2
kubectl get pod impossible-cpu
kubectl describe pod impossible-cpu | tail -5
kubectl delete -f impossible-cpu.yaml

hr
echo "STEP 3 — request the card twice (needs a teammate, same file, own namespaces)"
echo "You run this; ask your teammate to run the same wants-a-gpu.yaml in THEIR"
echo "namespace at the same time (or right after)."
kubectl apply -f wants-a-gpu.yaml
kubectl get pod wants-a-gpu
pause "Once your teammate has applied theirs too and you've both checked status (Running vs Pending), continue"
kubectl describe pod wants-a-gpu | tail -5
echo "Now delete YOURS if you were the Running one, and watch your teammate's flip to Running:"
pause "Coordinate the delete with your teammate, then continue"
kubectl delete -f wants-a-gpu.yaml
echo "Make sure NEITHER of you left a wants-a-gpu pod running (it blocks Step 6 later)."
kubectl get pods -A | grep -i wants-a-gpu || echo "clean — none left running"

hr
echo "STEP 4 — the noisy neighbour, measured"
echo "Run this ONE STUDENT AT A TIME per pod (28 cores) — coordinate with your table."
pause "Confirm you're the only one running Step 4 on this pod right now"

echo "--- Run A: unlimited burner ---"
kubectl apply -f burner-unlimited.yaml
kubectl get pods -l app=burner-unlimited
pause "Wait until all burner-unlimited pods show Running, then continue"
kubectl run latency-probe --image=lamaalfarraj/aidc-serving:cpu-v1 --restart=Never --command -- \
  python -c '
import time, urllib.request
lat = []
fails = 0
end = time.time() + 30
while time.time() < end:
    t0 = time.time()
    try:
        urllib.request.urlopen("http://serving:8000/health", timeout=5).read()
        lat.append(time.time() - t0)
    except Exception:
        lat.append(5.0)
        fails += 1
    time.sleep(0.05)
lat.sort()
if lat:
    print(f"LATENCY n={len(lat)} fails={fails} p50={lat[len(lat)//2]*1000:.0f}ms p95={lat[int(len(lat)*0.95)]*1000:.0f}ms")
else:
    print(f"LATENCY n=0 fails={fails} (nothing answered at all)")
'
pause "Wait for latency-probe to show Completed"
kubectl logs latency-probe
echo ">>> WRITE DOWN this p95 (unlimited neighbour) — you need it for policy.md"
kubectl delete pod latency-probe
kubectl delete -f burner-unlimited.yaml

echo "--- Run B: limited burner (cpu: 500m) ---"
kubectl apply -f burner-limited.yaml
kubectl get pods -l app=burner-limited
pause "Wait until all burner-limited pods show Running, then continue"
kubectl run latency-probe --image=lamaalfarraj/aidc-serving:cpu-v1 --restart=Never --command -- \
  python -c '
import time, urllib.request
lat = []
fails = 0
end = time.time() + 30
while time.time() < end:
    t0 = time.time()
    try:
        urllib.request.urlopen("http://serving:8000/health", timeout=5).read()
        lat.append(time.time() - t0)
    except Exception:
        lat.append(5.0)
        fails += 1
    time.sleep(0.05)
lat.sort()
if lat:
    print(f"LATENCY n={len(lat)} fails={fails} p50={lat[len(lat)//2]*1000:.0f}ms p95={lat[int(len(lat)*0.95)]*1000:.0f}ms")
else:
    print(f"LATENCY n=0 fails={fails} (nothing answered at all)")
'
pause "Wait for latency-probe to show Completed"
kubectl logs latency-probe
echo ">>> WRITE DOWN this p95 (limited neighbour) — you need it for policy.md"
kubectl delete pod latency-probe
kubectl delete -f burner-limited.yaml

hr
echo "STEP 5 reminder — now open policy.md in this folder and fill in your two"
echo "real p95 numbers, then write the policy sentence + resources blocks + defence."
echo "(Not scripted — this is judgement, not a command.)"

hr
echo "STEP 6 reminder — this is a ONCE-PER-TEAM step, not solo. See team-engine.md"
echo "in this folder for the exact commands. Nominate one teammate to run it while"
echo "the rest of you read along."

hr
echo "STEP 7 — green check (run this back in YOUR namespace)"
kubectl config set-context --current --namespace="$ME"
bash verify.sh
