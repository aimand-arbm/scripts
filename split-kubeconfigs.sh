#!/usr/bin/env bash
# Usage: split-kubeconfig.sh [kubeconfig]   (defaults to $KUBECONFIG or ~/.kube/config)
set -euo pipefail
export KUBECONFIG="${1:-${KUBECONFIG:-$HOME/.kube/config}}"

sep=""
kubectl config get-contexts -o name | while IFS= read -r ctx; do
  printf '%s' "$sep"; sep=$'---\n'
  kubectl config view --minify --flatten --context="$ctx"
done
