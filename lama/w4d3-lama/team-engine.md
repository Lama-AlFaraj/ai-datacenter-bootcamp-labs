# Step 6 — team's engine on the real card (once per team, ~40 min)

Only ONE teammate runs these commands. Everyone else reads along — two people
applying this is one engine and one Pending pod.

```bash
# 1. Create / switch to the shared team namespace
kubectl create namespace team                                  # once per pod, by anyone
kubectl config set-context --current --namespace=team

# 2. Make sure nobody is still holding the card from Step 3
kubectl get pods -A | grep -E 'wants-a-gpu|gpu-check'
# if anything shows up: kubectl delete pod <name> -n <namespace>

# 3. Create the API key secret (manifest reads it by reference)
kubectl create secret generic serving-keys \
  --from-literal=api-key=$(python3 -c "import secrets; print(secrets.token_hex(16))")
# >>> COPY the key you just generated somewhere safe — you'll need it below <<<
# (to see it again later: kubectl get secret serving-keys -o jsonpath='{.data.api-key}' | base64 -d)

# 4. Apply the engine
kubectl apply -f vllm-gpu.yaml
kubectl get pods -w                    # watch: ContainerCreating -> Running -> 1/1
kubectl logs deploy/vllm | tail -20
```

`vllm-gpu.yaml` already has the exact PINS canon flags (`--dtype half`,
`--max-model-len 4096`, `--gpu-memory-utilization 0.85`, `--tool-call-parser
hermes`) and `Qwen/Qwen2.5-1.5B-Instruct-AWQ`, which is already cached on the
pod (~2 min to Ready). If your team's `model-lock.md` pins a **different**
model id, edit the `--model=` (and drop `--quantization=awq` if you locked the
fp16/"pocket" build instead) before applying.

## Sanity checks (do these — they're what verify.sh also checks)

```bash
# QoS must be Guaranteed (GPU alone buys no QoS class — only cpu+memory do)
kubectl get pod -l app=vllm -o jsonpath='{.items[0].status.qosClass}'

# Service must be named team-serving, NOT vllm (Docker-link env var kills vLLM
# if a Service called `vllm` exists in this namespace — VLLM_PORT collision)
kubectl get svc -n team
```

## Verify the path end-to-end

```bash
kubectl port-forward deploy/vllm 8021:8000 &     # pick a free port at your table
curl -s -o /dev/null -w '%{http_code}\n' localhost:8021/health          # expect 200
curl -s -o /dev/null -w '%{http_code}\n' localhost:8021/v1/models       # expect 401
curl -s -H "Authorization: Bearer <your key>" localhost:8021/v1/models  # expect your model id
kill %1
```

**Leave the engine running** — do not delete it. It's ClusterIP today;
Thursday's go-live turns it into the public endpoint with one patch, using the
same `serving-keys` secret you just made.

Switch back to your own namespace before Step 7:

```bash
kubectl config set-context --current --namespace=$ME
```
