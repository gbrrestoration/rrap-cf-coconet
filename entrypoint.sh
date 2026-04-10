#!/bin/bash

export JAVA_TOOL_OPTIONS="-Djava.awt.headless=true \
-Xmx${MAX_RAM} \
-Djava.library.path=${NETLOGO_HOME}/lib \
-Djava.util.prefs.systemRoot=${COCONET_PREFS_DIR} \
-Dfile.encoding=UTF-8 \
${JAVA_TOOL_OPTIONS:-}"

# Generate experiment XML and parameter CSV from environment variables
./generate_experiment.sh parameters
SETUP_FILE="parameters/generated_experiment.xml"

echo "Setup file: ${SETUP_FILE}"
echo "Planned ensemble runs: ${ENSEMBLE_RUNS:-unknown}"

echo "Launching CoCoNet in NetLogo headless mode..."
exec "${NETLOGO_HOME}/netlogo-headless.sh" --setup-file "${SETUP_FILE}" --model "${COCONET_MODEL}"