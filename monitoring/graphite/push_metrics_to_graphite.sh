#!/bin/bash
# push_metrics_to_graphite.sh
#
# Polls the nginx /nginx_status endpoint (enabled in nginx.conf via stub_status)
# and basic host metrics, then feeds them into Graphite/Carbon using the
# plaintext protocol on port 2003.
#
# Run this on a machine that can reach both the website and the Graphite server,
# e.g. as a cron job every minute, or as a sidecar/CronJob in Kubernetes.
#
# Usage: ./push_metrics_to_graphite.sh <graphite_host> <website_url>
# Example: ./push_metrics_to_graphite.sh 127.0.0.1 http://<NODE_IP>:30080

GRAPHITE_HOST="${1:-127.0.0.1}"
GRAPHITE_PORT=2003
WEBSITE_URL="${2:-http://localhost:30080}"
METRIC_PREFIX="abc_website"

TIMESTAMP=$(date +%s)

# --- Nginx connection metrics (from stub_status) ---
STATUS_OUTPUT=$(curl -s "${WEBSITE_URL}/nginx_status")
ACTIVE_CONN=$(echo "$STATUS_OUTPUT" | awk '/Active connections/ {print $3}')
REQUESTS=$(echo "$STATUS_OUTPUT" | awk 'NR==3 {print $3}')

# --- Availability check (1 = up, 0 = down) ---
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${WEBSITE_URL}/healthz")
if [ "$HTTP_CODE" == "200" ]; then AVAILABILITY=1; else AVAILABILITY=0; fi

# --- Basic host resource metrics ---
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
MEM_USAGE=$(free | awk '/Mem/ {printf "%.2f", $3/$2 * 100}')

# --- Send metrics to Graphite (Carbon plaintext protocol: <path> <value> <timestamp>) ---
{
  echo "${METRIC_PREFIX}.nginx.active_connections ${ACTIVE_CONN:-0} ${TIMESTAMP}"
  echo "${METRIC_PREFIX}.nginx.requests_total ${REQUESTS:-0} ${TIMESTAMP}"
  echo "${METRIC_PREFIX}.availability ${AVAILABILITY} ${TIMESTAMP}"
  echo "${METRIC_PREFIX}.host.cpu_usage_percent ${CPU_USAGE:-0} ${TIMESTAMP}"
  echo "${METRIC_PREFIX}.host.mem_usage_percent ${MEM_USAGE:-0} ${TIMESTAMP}"
} | nc -q1 "${GRAPHITE_HOST}" "${GRAPHITE_PORT}"

echo "Pushed metrics to Graphite at ${GRAPHITE_HOST}:${GRAPHITE_PORT} (timestamp ${TIMESTAMP})"
