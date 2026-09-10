# Predict (by hand) — before running anything

Not graded for accuracy, but must be filled in BEFORE Steps 1-4.

1. Node has ___ CPUs (`kubectl describe node`, Capacity). A pod requesting 64
   CPUs: (apply error / crashes / something else) → ________________________

2. Teammate's pod already holds the one GPU. You request `nvidia.com/gpu: 1`.
   Same question — will the error message name the GPU? → __________________

3. Neighbour burns all CPU, no limit. Your /health latency:
   (unchanged / somewhat worse / catastrophically worse) → __________________
   Neighbour gets `cpu: 500m` limit. What changes? → __________________
