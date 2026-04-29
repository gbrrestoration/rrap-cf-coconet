# Headless only run of the CoCoNet V3 model
# Based off previous work done by Sharon Tickell: https://github.com/gbrrestoration/CoCoNet-model/tree/TRG-30_containerisation

FROM eclipse-temurin:17-jdk-jammy

# Ensure the OS is up to date and clean
RUN apt-get update && apt-get dist-upgrade -y \
    && apt-get install -y awscli \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install NetLogo
ENV NETLOGO_VERSION="6.4.0"
ENV NETLOGO_HOME="/opt/netlogo"
RUN mkdir -p "${NETLOGO_HOME}"
RUN wget -O - "https://downloads.netlogo.org/${NETLOGO_VERSION}/NetLogo-${NETLOGO_VERSION}-64.tgz" | tar -xz -C "${NETLOGO_HOME}" --strip-components=1
LABEL org.netlogo.downloads.version=${NETLOGO_VERSION}

COPY --chmod=755 ./entrypoint.sh "/entrypoint.sh"

COPY --chmod=755 ./generate_experiment.sh "/generate_experiment.sh"

# Configure the default entrypoint to launch the CoCoNet model
ENTRYPOINT [ "/entrypoint.sh" ]
CMD []