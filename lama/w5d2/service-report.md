curl -s -u admin:$GRAFANA_PASSWORD http://localhost:3000/api/prometheus/grafana/api/v1/rules | python3 -c "
import json,sys
d=json.load(sys.stdin)
for g in d['data']['groups']:
    for r in g['rules']:
        print(r['name'], '| state:', r.get('state'), '| health:', r.get('health'))
"
kill %1# Service report

Team:
Use case:
Service and model:
Measured requests or tasks:
Indicator and unit:
SLO target and window:
Measurement start and end:
Workload:
Observed result and sample count:
Evidence:
Conclusion:
Limitations:
Follow-up action:

## Measurement query

Paste the expression used to produce the reported value. Give its evaluation
time or range. Explain where the measurement is taken and what it excludes.

## Service alert

Condition and unit:
Evaluation interval:
Pending period:
Relationship to the SLO:
First response to a notification:

## Notification test

Firing received at:
Resolved received at:
What the test establishes:
