# Push to GitHub for team review

Run this INSIDE `~/aidc/lamaalfarraj/d3` on the team pod, after Steps 1-5 are
done (policy.md filled in with real numbers) and Step 7's `verify.sh` prints
`GREEN CHECK: PASS`.

```bash
cd ~/aidc/lamaalfarraj/d3

# 1. Make sure you're on your own branch, not main
git status
git checkout -b w4d3-lamaalfarraj      # skip if you already have a branch

# 2. Stage exactly this lab's artifacts
git add impossible-cpu.yaml wants-a-gpu.yaml \
        burner-unlimited.yaml burner-limited.yaml \
        vllm-gpu.yaml verify.sh \
        resources-patch.yaml policy.md predictions.md run-lab.sh team-engine.md
# (add your actual deployment.yaml too, wherever it lives, e.g.:)
git add ../d2-self-healing/deployment.yaml

git status   # double-check nothing extra (secrets, .env, etc.) is staged

# 3. Commit
git commit -m "W4D3: GPU scheduling ledger — requests/limits, overdraft, noisy-neighbour, policy"

# 4. Push
git push -u origin w4d3-lamaalfarraj
```

## Open the PR for team review

If you have the GitHub CLI (`gh`) on the pod:

```bash
gh pr create \
  --title "W4D3: GPU scheduling as accounting" \
  --body "Steps 1-5 done. verify.sh: GREEN CHECK: PASS. p95 numbers and policy in policy.md." \
  --base main \
  --head w4d3-lamaalfarraj
```

If `gh` isn't installed, just push (step 4 above) and open the PR from the
GitHub web UI — GitHub will show a "Compare & pull request" banner for the
branch you just pushed. Tag your teammates as reviewers there.

**Do NOT commit:** the API key you generated for `serving-keys` in Step 6, or
any `kubeconfig` file. Those stay off the repo.
