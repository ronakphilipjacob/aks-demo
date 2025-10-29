#!/bin/bash
set -e

PROM_URL="http://4.239.201.178"
OUTPUT_FILE="./daily_aks_report_$(date +%F).txt"

urlencode() {
  python3 -c "import urllib.parse; print(urllib.parse.quote('''$1'''))"
}

CPU_QUERY='avg(rate(container_cpu_usage_seconds_total{namespace!=""}[5m])) * 100'
MEM_QUERY='avg(container_memory_usage_bytes{namespace!=""}) / (1024*1024*1024)'
POD_QUERY='count(kube_pod_info)'

cpu_q=$(urlencode "$CPU_QUERY")
mem_q=$(urlencode "$MEM_QUERY")
pod_q=$(urlencode "$POD_QUERY")

get_metric() {
  query="$1"
  result=$(curl -s "$PROM_URL/api/v1/query?query=$query")
  if ! echo "$result" | jq -e '.status=="success"' > /dev/null 2>&1; then
    echo "Error: Invalid Prometheus response."
    echo "$result"
    exit 1
  fi
  echo "$result" | jq -r '.data.result[0].value[1]'
}

cpu_usage=$(get_metric "$cpu_q" | awk '{printf "%.2f", $1}')
mem_usage=$(get_metric "$mem_q" | awk '{printf "%.2f", $1}')
pod_count=$(get_metric "$pod_q")

#Report
cat <<EOF > "$OUTPUT_FILE"
==============================
AKS Daily Performance Report
Date: $(date)
==============================

Prometheus Endpoint: $PROM_URL

Avg CPU Usage (%): $cpu_usage
Avg Memory Usage (GB): $mem_usage
Active Pods: $pod_count

==============================
EOF

echo "Report generated at: $OUTPUT_FILE"