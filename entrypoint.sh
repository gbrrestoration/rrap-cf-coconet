#!/bin/bash
set -e

# error for not providing OUTPUTS_DIR or COCONET_MODEL_DIR environment variables
if [ -z "$OUTPUTS_DIR" ]; then
    echo "!! ERROR !!: OUTPUTS_DIR environment variable is not set. Please set it to the name of the output directory (relative to COCONET_HOME: ${COCONET_HOME}) where CoCoNet will write its outputs. E.g., 'outputs' if it is at ${COCONET_HOME}/outputs"; exit 1
fi


if [ ! -d $COCONET_HOME/$COCONET_MODEL_DIR/$OUTPUTS_DIR ]; then
    echo "!! ERROR !!: Output directory mount is required but not found at: COCONET_HOME/COCONET_MODEL_DIR/OUTPUTS_DIR = $COCONET_HOME/$COCONET_MODEL_DIR/$OUTPUTS_DIR. Program will likely FAIL! Customise this path with the OUTPUTS_DIR environment variable."; exit 1
fi

if [ ! -d $COCONET_HOME/$COCONET_MODEL_DIR  ]; then
    echo "!! ERROR !!: CoCoNet model mount is required but not found at: COCONET_HOME/COCONET_MODEL_DIR = $COCONET_HOME/$COCONET_MODEL_DIR. Program will likely FAIL! Customise this path with the COCONET_MODEL_DIR environment variable."; exit 1
fi

export JAVA_TOOL_OPTIONS="-Djava.awt.headless=true \
-Xmx${MAX_RAM} \
-Djava.library.path=${NETLOGO_HOME}/lib \
-Djava.util.prefs.systemRoot=${COCONET_PREFS_DIR} \
-Dfile.encoding=UTF-8 \
${JAVA_TOOL_OPTIONS:-}"

# RUN mkdir -p "${COCONET_OUT_DIR}" "${COCONET_PREFS_DIR}" && \
#     chmod 0777 "${COCONET_OUT_DIR}" && \
#     chmod 0777 "${COCONET_PREFS_DIR}" && \
#     chmod 0666 ./*.nlogo && \
#     chmod 0666 ./*.csv && \
#     chmod 0755 "entrypoint.sh" && \
#     chmod 0755 "generate_experiment.sh"
chmod -R ugo+rwX "${COCONET_HOME}"/*

# Generate experiment XML and parameter CSV from environment variables
./generate_experiment.sh parameters
SETUP_FILE="parameters/generated_experiment.xml"

echo "Setup file: ${SETUP_FILE}"
echo "Planned ensemble runs: ${ENSEMBLE_RUNS:-unknown}"

echo "Launching CoCoNet in NetLogo headless mode..."
exec "${NETLOGO_HOME}/netlogo-headless.sh" --setup-file "${SETUP_FILE}" --model "${COCONET_MODEL}" #  --threads ${THREADS:-1} 