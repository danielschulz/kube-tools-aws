# syntax = docker/dockerfile:1.4.3
# enable advanced Dockerfile features, like Build Kit and more modern syntax options
# also see: https://docs.docker.com/develop/develop-images/build_enhancements/

ARG BASE_IMAGE
FROM ${BASE_IMAGE}

LABEL MAINTAINERS="the Kubeflow & RStudio creators, Daniel Schulz"

ARG TARGETPLATFORM="linux/amd64"


# configure build-side user to switch back to later when `root`-side installations and configurations are done
ARG APPS_PATH="/apps"
ARG APPS_CONFIG_PATH="${APPS_PATH}/config"
ARG APPS_SW_PATH="${APPS_PATH}/tools"

ARG APPS_AWS_PATH="${APPS_SW_PATH}/aws"
ARG APPS_AWS_BIN_PATH="${APPS_SW_PATH}/aws-bin"
ARG APPS_HELM_PATH="${APPS_SW_PATH}/helm"
ARG APPS_K8S_PATH="${APPS_SW_PATH}/k8s"


# this user's primary group ID in Linux
ARG NB_GID=100

USER root

# set my time zone to Greenwich/London, UK time as a best practice
ARG TZ='Europe/Berlin'

# tell APT we are not answering CLI questions, please do not wait for my input in the first place
ARG DEBIAN_FRONTEND=noninteractive

# explicitly provide the correct user ID (UID = 1000) for user "jovyan"
ARG NB_UID="${NB_UID}"

# explicitly provide the correct ${HOME} for user "jovyan"
ARG HOME="${HOME}"


# INSTALLATIONS FOR COMPILATION, COLLECTION & COMPOSITION -- ONLY EXISTING IN STAGE 'COMMON_ASSETS'
# enable my user to later issue sudo commands wo/ password
# need to switch to root and install `sed` tool to patch `sudoers`' file to conduct these changes
# update indices
RUN \
    # update package index first
    apt update -qq && \
    # remove GIT from APT repository (PPA) -- will and must be installed from its sources later
    apt remove --purge --auto-remove -y git && \
    # install coreutils, curl & command install to get SHA256 checksums to proof the integrity of all downloads
    # g++ is a compiler framework, which is needed to install (and build wheel) packages using conda and pip --
    # needed for some, installing them for GPE
    # the install will confirm (-y), update this package only (--only-upgrade install) and do it very quietly (-qq) \
    # apt install -qq -y apt-transport-https ca-certificates coreutils curl g++ gnupg lsb-release sed unzip && \
    apt install -qq -y curl unzip && \
    # remove APT's temporary files
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*



# create folder structure and make scripts run-able there by default
RUN mkdir -p ${APPS_CONFIG_PATH} ${APPS_SW_PATH} ${APPS_SW_PATH} \
        ${APPS_AWS_PATH} ${APPS_HELM_PATH} ${APPS_K8S_PATH} && \
    chown 1000:100 / && \
    chown 1000:100 -R ${APPS_PATH} /tmp && \
    chmod 0755 -R ${APPS_PATH} /tmp


# switch back to become the configured user 1000
# is 'jovyan' with id 1000 by default
# this fixed ID 1000 needs to be aligned across our Images for cross-Container file access to work properly
USER ${NB_UID}



WORKDIR /tmp


# AWS CLI & K8S
# install AWS CLI & kubectl
ARG AWS_CLI_VERSION
ARG AWS_CLI_ARCHIVE="https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip"
ARG AWS_CLI_CHECKSUM

# K8s' CLI version matches server's version v1.20.15 perfectly (AWS EKS)
ARG K8S_CLI_VERSION


RUN echo "installing AWS CLI" && \
    cd /tmp && \
    curl --silent "${AWS_CLI_ARCHIVE}" -o "/tmp/awscliv2.zip" && \
    echo "${AWS_CLI_CHECKSUM}  /tmp/awscliv2.zip" | sha256sum --check --status && \
    # extract files really quietly (-qq) and overwrite wo/ asking before (-o)
    unzip -oqq /tmp/awscliv2.zip && \
    /tmp/aws/install --update -i ${APPS_AWS_PATH} -b ${APPS_AWS_BIN_PATH} && \
    echo "installing kubectl" && \
    # export K8S_RELEASE_VERSION=$( curl -sL https://dl.k8s.io/release/stable.txt ) && \
    curl -sL "https://dl.k8s.io/release/v${K8S_CLI_VERSION}/bin/linux/amd64/kubectl" -o /tmp/kubectl && \
    export K8S_CLI_HASH=$( curl -sL "https://dl.k8s.io/v${K8S_CLI_VERSION}/bin/linux/amd64/kubectl.sha256" ) && \
    echo -e "K8s' CLI's cryptographic HASH after downloading is: \t$( sha256sum --tag /tmp/kubectl )" && \
    echo -e "K8s' CLI's cryptographic HASH is expected to be: \t${K8S_CLI_HASH}\n" && \
    echo "${K8S_CLI_HASH}  /tmp/kubectl" | sha256sum --check --status && \
    install -o $( id -u ) -g $( id -g ) -m 0755 /tmp/kubectl ${APPS_K8S_PATH}/kubectl && \
    rm -rf /tmp/awscliv2.zip /tmp/kubectl /tmp/kubectl.sha256


# HELM
# the version of Helm to apply in Jarvis' IDEs
ARG HELM_VERSION
# the URI to download Helm's binary from the original sources
ARG HELM_DOWNLOAD_URI="https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
# the SHA checksum to verify, it is safe to install this Helm binary
ARG HELM_DOWNLOAD_CHECKSUM

# download and install Docker CLI tools to ${HOME}/docker (/home/jovyan/docker)
# add them later to the system's PATH for user jovyan as well
RUN \
    # install Helm
    curl -sL ${HELM_DOWNLOAD_URI} -o /tmp/helm.tar.gz && \
    echo "${HELM_DOWNLOAD_CHECKSUM}  /tmp/helm.tar.gz" | sha256sum --check --status && \
    tar -xf /tmp/helm.tar.gz linux-amd64/helm && \
    rm -rf /tmp/helm.tar.gz && \
    mv -v /tmp/linux-amd64/helm "${APPS_HELM_PATH}" && \
    chown "${NB_UID}:${NB_GID}" "${APPS_HELM_PATH}/helm" && \
    chmod 755 "${APPS_HELM_PATH}/helm"


# configure security settings: token, password, http(s) origins
ENV APPS_CONFIG_PATH="${APPS_CONFIG_PATH}" \
    APPS_DOCKER_PATH="${APPS_DOCKER_PATH}" \
    APPS_HELM_PATH="${APPS_HELM_PATH}" \
    APPS_PATH="${APPS_PATH}" \
    APPS_PYTHON_VENVS_PATH="${APPS_PYTHON_VENVS_PATH}" \
    APPS_SW_PATH="${APPS_SW_PATH}" \
    AWS_PAGER="" \
    EDITOR="${EDITOR}" \
    LANG="${LANG}" \
    TZ="${TZ}"


# tell the container, to accept SIGTERM as a signal to gracefully stop the container
STOPSIGNAL SIGTERM

CMD ["bash"]
