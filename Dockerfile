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
WORKDIR "${COCONET_HOME}"
COPY ./CoCoNet-model ./
COPY ./entrypoint.sh ./
COPY ./generate_experiment.sh ./

# Define environment variables that control how the CoCoNet model and 
# and NetLogo platform will behave at runtime
ENV COCONET_MODEL="${COCONET_HOME}/CoCoNet V3.0.nlogo" \
    COCONET_OUT_DIR="${COCONET_HOME}/outputs" \
    COCONET_PREFS_DIR="${COCONET_HOME}/.prefs" \
    JAVA_TOOL_OPTIONS="" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    MAX_RAM="8G"

# Ensure all the subdirectories we need exist and that all filesystem 
# permissions are set up to allow any runtime user to execute the model.
RUN mkdir -p "${COCONET_OUT_DIR}" "${COCONET_PREFS_DIR}" && \
    chmod 0777 "${COCONET_OUT_DIR}" && \
    chmod 0777 "${COCONET_PREFS_DIR}" && \
    chmod 0666 ./*.nlogo && \
    chmod 0666 ./*.csv && \
    chmod 0755 "entrypoint.sh" && \
    chmod 0755 "generate_experiment.sh"

# Configure the default entrypoint to launch the CoCoNet model
ENTRYPOINT [ "./entrypoint.sh" ]
CMD []