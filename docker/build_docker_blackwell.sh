#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

exec bash "$SCRIPT_DIR/build_docker_base.sh" \
    Dockerfile.blackwell acfr_rpg/dyno_sam_blackwell
