#!/usr/bin/env bash
# Usage: merge-kubeconfigs.sh [dir]   (defaults to $KUBECONFIG_DIR or ~/.kube/config.d)
set -euo pipefail
dir="${1:-${KUBECONFIG_DIR:-$HOME/.kube/config.d}}"
[ -d "$dir" ] || { echo "not a directory: $dir" >&2; exit 1; }

files=()
for f in "$dir"/*; do [ -f "$f" ] && files+=("$f"); done
[ ${#files[@]} -gt 0 ] || { echo "no files in $dir" >&2; exit 1; }

KUBECONFIG="$(IFS=:; echo "${files[*]}")" kubectl config view --flatten
