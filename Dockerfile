# Headless only run of the CoCoNet V3 model
# Based off previous work done by Sharon Tickell: https://github.com/gbrrestoration/CoCoNet-model/tree/TRG-30_containerisation

FROM eclipse-temurin:17-jdk-jammy

# Ensure the OS is up to date and clean
RUN apt-get update && apt-get dist-upgrade -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install NetLogo
ENV NETLOGO_VERSION="6.4.0"
ENV NETLOGO_HOME="/opt/netlogo"
RUN mkdir -p "${NETLOGO_HOME}"
RUN wget -O - "https://downloads.netlogo.org/${NETLOGO_VERSION}/NetLogo-${NETLOGO_VERSION}-64.tgz" | tar -xz -C "${NETLOGO_HOME}" --strip-components=1
LABEL org.netlogo.downloads.version=${NETLOGO_VERSION}

# Install the CoCoNet data files and model code
ENV COCONET_HOME="/opt/CoCoNet"
ENV COCONET_MODEL_DIR="CoCoNet-model"
WORKDIR "${COCONET_HOME}"
# COPY ./CoCoNet-model "${COCONET_HOME}/"
COPY --chmod=755 ./entrypoint.sh "${COCONET_HOME}/"

COPY --chmod=755 ./generate_experiment.sh "${COCONET_HOME}/"

# Define environment variables that control how the CoCoNet model and 
# and NetLogo platform will behave at runtime
ENV COCONET_MODEL="${COCONET_HOME}/${COCONET_MODEL_DIR}/CoCoNet V3.0.nlogo" \
    COCONET_OUT_DIR="${COCONET_HOME}/${COCONET_MODEL_DIR}/outputs" \
    COCONET_PREFS_DIR="${COCONET_HOME}/${COCONET_MODEL_DIR}/.prefs" \
    JAVA_TOOL_OPTIONS="" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    MAX_RAM="8G"

# Configure the default entrypoint to launch the CoCoNet model
ENTRYPOINT [ "./entrypoint.sh" ]
CMD []