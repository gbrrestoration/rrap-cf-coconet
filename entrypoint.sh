#!/bin/bash
set -e

if [ -z "$COCONET_HOME" ]; then
    echo "!! ERROR !!: COCONET_HOME environment variable is not set. Please set it. This is where the model dir (CoCoNet-model) and outputs etc will be inside of."; exit 1
fi

export COCONET_MODEL_DIR="${COCONET_HOME}/CoCoNet-model"

if [ ! -f "${COCONET_MODEL_DIR}/CoCoNet V3.0.nlogo"  ]; then
    echo "!! ERROR !!: CoCoNet model not found at:  ${COCONET_MODEL_DIR}/CoCoNet V3.0.nlogo. Program will cannot run! Ensure the model is mounted inside COCONET_HOME = ${COCONET_HOME} with name CoCoNet-model"; exit 1
fi

export COCONET_OUT_DIR="${COCONET_MODEL_DIR}/${MODEL_OUTPUT_DIR}"
echo "OUTPUT DIRECTORY: ${COCONET_OUT_DIR}"
export COCONET_MODEL="${COCONET_MODEL_DIR}/CoCoNet V3.0.nlogo"
export COCONET_PREFS_DIR="${COCONET_MODEL_DIR}/.prefs"
export COCONET_PARAMS_DIR="${COCONET_MODEL_DIR}/parameters"

echo "Starting CoCoNet entrypoint..."

export JAVA_TOOL_OPTIONS=""
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"
export MAX_RAM="8G"
export JAVA_TOOL_OPTIONS="-Djava.awt.headless=true \
-Xmx${MAX_RAM} \
-Djava.library.path=${NETLOGO_HOME}/lib \
-Djava.util.prefs.systemRoot=${COCONET_PREFS_DIR} \
-Dfile.encoding=UTF-8 \
${JAVA_TOOL_OPTIONS:-}"

maybe_upload_output_to_s3() {
    local local_output_dir="$1"
    local raw bucket prefix key

    raw="${S3_OUTPUT_PATH:-${RRAP_CF_S3_OUTPUT_PATH:-}}"
    if [ -z "$raw" ]; then
        bucket="${S3_OUTPUT_BUCKET:-${RRAP_CF_S3_BUCKET_NAME:-${S3_BUCKET_NAME:-}}}"
        prefix="${S3_OUTPUT_PREFIX:-${RRAP_CF_S3_OUTPUT_PREFIX:-CoCoNet-NL-outputs}}"
        if [ -n "$bucket" ]; then
            raw="s3://${bucket}/${prefix}"
        fi
    fi

    if [ -z "$raw" ]; then
        echo "Not uploading CoCoNet output to S3 because no S3_OUTPUT_PATH or S3_OUTPUT_BUCKET environment variable was set. If you want to upload to S3, set one of those environment variables to a valid S3 URI." >&2
        return 0
    fi

    case "$raw" in
        s3://*) ;;
        *)
            echo "!! ERROR !!: S3_OUTPUT_PATH must be a directory URI like s3://bucket/prefix (got ${raw})" >&2
            return 1
            ;;
    esac

    raw="${raw#s3://}"
    bucket="${raw%%/*}"
    prefix=""
    if [ "$raw" != "$bucket" ]; then
        prefix="${raw#*/}"
        while [ -n "$prefix" ] && [ "${prefix%/}" != "$prefix" ]; do
            prefix="${prefix%/}"
        done
    fi

    if [ -z "$bucket" ]; then
        echo "!! ERROR !!: S3_OUTPUT_PATH must include a bucket name (got ${S3_OUTPUT_PATH:-${RRAP_CF_S3_OUTPUT_PATH:-}})" >&2
        return 1
    fi

    if [ ! -d "$local_output_dir" ]; then
        echo "!! ERROR !!: Cannot upload missing output directory: ${local_output_dir}" >&2
        return 1
    fi

    if ! command -v aws >/dev/null 2>&1; then
        echo "!! ERROR !!: aws CLI is required to upload to S3, but it was not found in the image" >&2
        return 1
    fi

    key="s3://${bucket}"
    if [ -n "$prefix" ]; then
        key="${key}/${prefix}"
    fi
    # key="${key}/$(basename "$local_output_dir")"

    aws s3 cp "${local_output_dir}/" "${key}/" --recursive
    echo "Uploaded CoCoNet output directory ${local_output_dir} to ${key}/"
}

# Check if directory COCONET_OUT_DIR exists, if not, create it. If yes, clear its contents and issue a warning
if [ -d "${COCONET_OUT_DIR}" ]; then
    echo "!! WARNING !!: Output directory ${COCONET_OUT_DIR} already exists. Clearing its contents. If you have important data there, its too late I'm afraid."
    # rm -rf "${COCONET_OUT_DIR:?}"/*  # temp disable clearing
else
    mkdir -p "${COCONET_OUT_DIR}"
fi


chmod -R ugo+rwX "${COCONET_HOME}"

# Generate experiment XML and parameter CSV from environment variables
# /generate_experiment.sh parameters
/generate_experiment.sh "${COCONET_PARAMS_DIR}"
SETUP_FILE="${COCONET_PARAMS_DIR}/generated_experiment.xml"
PARAMS_FILE="${COCONET_PARAMS_DIR}/generated_parameters.csv"

echo "Setup file: ${SETUP_FILE}"
echo "Planned ensemble runs: ${ENSEMBLE_RUNS:-unknown}"

echo "Launching CoCoNet in NetLogo headless mode..."
echo "RUNTIME ENVIRONMENT VARIABLES:"
env
echo ""
#! For some reasons displaying these prevents the following echo commands from displaying in logs.
# echo "GENERATED PARAMETERS CSV FOR RUN:"
# cat "${PARAMS_FILE}"
# echo ""
# echo "GENERATED SETUP_FILE XML FOR RUN:"
# cat "${SETUP_FILE}"
# echo ""


# "${NETLOGO_HOME}/netlogo-headless.sh" --setup-file "${SETUP_FILE}" --model "${COCONET_MODEL}" #  --threads ${THREADS:-1}
echo "CoCoNet model run is commented out for testing. Skipping NetLogo execution."
NETLOGO_EXIT_CODE=0


touch "${COCONET_OUT_DIR}/output121.csv"

if [ "$NETLOGO_EXIT_CODE" -eq 0 ]; then
    echo "CoCoNet run completed successfully. Exit code: ${NETLOGO_EXIT_CODE}. Attempting to upload output to S3 if configured..."
    maybe_upload_output_to_s3 "${COCONET_OUT_DIR}"
else
    echo "!! ERROR !!: CoCoNet run failed with exit code ${NETLOGO_EXIT_CODE}. Not uploading output to S3."
fi

echo "Fin."
exit "$NETLOGO_EXIT_CODE"