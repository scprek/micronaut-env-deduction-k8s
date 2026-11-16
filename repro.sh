#!/usr/bin/env bash
# Prints Micronaut's active environments with KUBERNETES_SERVICE_HOST set and environment deduction disabled.
# Usage: ./repro.sh [micronaut version]   (default 5.2.22; try 4.10.33 to compare)
set -euo pipefail
cd "$(dirname "$0")"
version="${1:-5.2.22}"
./gradlew -q installDist -PmicronautVersion="$version" >/dev/null
app=./build/install/micronaut-env-deduction-k8s/bin/micronaut-env-deduction-k8s

echo "Micronaut $version"
run() {
    printf '%-80s' "$*"
    env -u KUBERNETES_SERVICE_HOST -u MICRONAUT_ENV_DEDUCTION -u JAVA_OPTS "$@" "$app" | sed 's/active environments: //'
}
run
run KUBERNETES_SERVICE_HOST=10.0.0.1
run KUBERNETES_SERVICE_HOST=10.0.0.1 JAVA_OPTS=-Dmicronaut.env.deduction=false
run KUBERNETES_SERVICE_HOST=10.0.0.1 MICRONAUT_ENV_DEDUCTION=false
