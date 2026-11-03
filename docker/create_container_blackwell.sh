#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Override any of these at invocation time, for example:
# LOCAL_DATA_FOLDER=/mnt/d/datasets ./create_container_blackwell.sh
LOCAL_DATA_FOLDER="${LOCAL_DATA_FOLDER:-$HOME/dynosam_pkg/data}"
LOCAL_RESULTS_FOLDER="${LOCAL_RESULTS_FOLDER:-$HOME/dynosam_pkg/results}"
LOCAL_DYNO_SAM_FOLDER="${LOCAL_DYNO_SAM_FOLDER:-$HOME/dynosam_pkg/DynoSAM}"
LOCAL_THIRD_PARTY_DYNO_SAM_FOLDER="${LOCAL_THIRD_PARTY_DYNO_SAM_FOLDER:-$HOME/dynosam_pkg/extras}"

# The data, results, and extras mount points must exist before Docker starts.
mkdir -p "$LOCAL_DATA_FOLDER" \
    "$LOCAL_RESULTS_FOLDER" \
    "$LOCAL_THIRD_PARTY_DYNO_SAM_FOLDER"

exec bash "$SCRIPT_DIR/create_container_base.sh" \
    acfr_rpg/dyno_sam_blackwell \
    dyno_sam_blackwell \
    "$LOCAL_DATA_FOLDER" \
    "$LOCAL_RESULTS_FOLDER" \
    "$LOCAL_DYNO_SAM_FOLDER" \
    "$LOCAL_THIRD_PARTY_DYNO_SAM_FOLDER"
