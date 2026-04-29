#!/bin/bash
set -e

if [ -z "$COCONET_HOME" ]; then
    echo "!! ERROR !!: COCONET_HOME environment variable is not set. Please set it. This is where the model dir (CoCoNet-model) and outputs etc will be inside of."; exit 1
fi

export COCONET_MODEL_DIR="CoCoNet-model"

if [ ! -f $COCONET_HOME/$COCONET_MODEL_DIR/"CoCoNet V3.0.nlogo"  ]; then
    echo "!! ERROR !!: CoCoNet model not found at:  ${COCONET_HOME}/${COCONET_MODEL_DIR}/CoCoNet V3.0.nlogo. Program will cannot run! Ensure the model is mounted inside COCONET_HOME = ${COCONET_HOME} with name CoCoNet-model"; exit 1
fi

export COCONET_OUT_DIR="${COCONET_HOME}/${COCONET_MODEL_DIR}/outputs"
export COCONET_MODEL="${COCONET_HOME}/${COCONET_MODEL_DIR}/CoCoNet V3.0.nlogo"
export COCONET_PREFS_DIR="${COCONET_HOME}/${COCONET_MODEL_DIR}/.prefs"
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

# Check if directory COCONET_OUT_DIR exists, if not, create it. If yes, clear its contents and issue a warning
if [ -d "${COCONET_OUT_DIR}" ]; then
    echo "!! WARNING !!: Output directory ${COCONET_OUT_DIR} already exists. Clearing its contents. If you have important data there, its too late I'm afraid."
    rm -rf "${COCONET_OUT_DIR:?}"/*
else
    mkdir -p "${COCONET_OUT_DIR}"
fi


chmod -R ugo+rwX "${COCONET_HOME}"

# Generate experiment XML and parameter CSV from environment variables
/generate_experiment.sh parameters
SETUP_FILE="parameters/generated_experiment.xml"
PARAMS_FILE="parameters/generated_parameters.csv"

echo "Setup file: ${SETUP_FILE}"
echo "Planned ensemble runs: ${ENSEMBLE_RUNS:-unknown}"

echo "Launching CoCoNet in NetLogo headless mode..."
echo "RUNTIME ENVIRONMENT VARIABLES:"
env
echo ""
echo "GENERATED PARAMETERS CSV FOR RUN:"
cat "${PARAMS_FILE}"

exec "${NETLOGO_HOME}/netlogo-headless.sh" --setup-file "${SETUP_FILE}" --model "${COCONET_MODEL}" #  --threads ${THREADS:-1} 