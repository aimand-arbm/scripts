#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <bucket> <origin> [method] [headers] [key]
  Sends a CORS preflight (OPTIONS) to the bucket's regional endpoint, like a browser would.
  method defaults to PUT, headers to content-type, key to test.txt.
  Region is auto-detected (no AWS credentials needed); override with \$AWS_REGION.
  Exits 0 if the preflight is allowed, 1 otherwise.
EOF
}

case "${1:-}" in -h|--help) usage; exit 0 ;; esac
[ $# -ge 2 ] || { usage >&2; exit 2; }

bucket="$1" origin="$2" method="${3:-PUT}" headers="${4:-content-type}" key="${5:-test.txt}"

# S3 returns x-amz-bucket-region even on 403, so no credentials are needed.
region="${AWS_REGION:-$(curl -sSI --max-time 10 "https://$bucket.s3.amazonaws.com" \
  | tr -d '\r' | awk -F': ' 'tolower($1)=="x-amz-bucket-region"{print $2}')}"
[ -n "$region" ] || { echo "could not detect region; set AWS_REGION" >&2; exit 1; }

url="https://$bucket.s3.$region.amazonaws.com/$key"
# echo "OPTIONS $url (Origin: $origin, Method: $method, Headers: $headers)" >&2

resp="$(curl -sS -i --max-time 15 -X OPTIONS "$url" \
  -H "Origin: $origin" \
  -H "Access-Control-Request-Method: $method" \
  -H "Access-Control-Request-Headers: $headers")"
echo "$resp"

if grep -qi '^access-control-allow-origin:' <<<"$resp"; then
  echo "CORS preflight allowed" >&2
else
  echo "CORS preflight NOT allowed" >&2
  exit 1
fi
