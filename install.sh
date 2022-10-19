#!/bin/sh

set -e

apk add --update curl make openssl groff wget


# AWS CLI & K8S
# install AWS CLI & kubectl
AWS_CLI_VERSION="2.8.2"
AWS_CLI_ARCHIVE="https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip"
AWS_CLI_CHECKSUM=ca0e766fe70b14c1f7e2817836acf03e4a3e6391b7ed6a464282c5b174580b9a

# K8s' CLI version matches server's version v1.20.15 perfectly (AWS EKS)
K8S_CLI_VERSION="1.22.10"

echo "installing AWS CLI"
cd /tmp
curl --silent "${AWS_CLI_ARCHIVE}" -o "./awscliv2.zip"
echo "${AWS_CLI_CHECKSUM}  ./awscliv2.zip" | sha256sum -c -s

# configure build-side user to switch back to later when `root`-side installations and configurations are done
APPS_PATH="/apps"
APPS_SW_PATH="${APPS_PATH}/tools"
APPS_AWS_PATH="${APPS_SW_PATH}/aws"
APPS_AWS_BIN_PATH="${APPS_SW_PATH}/aws-bin"

# extract files really quietly (-qq) and overwrite wo/ asking before (-o)
unzip -oqq ./awscliv2.zip
rm -f ./awscliv2.zip
mkdir -p "${APPS_AWS_PATH}" "${APPS_AWS_BIN_PATH}"
./aws/install --update -i "${APPS_AWS_PATH}" -b "${APPS_AWS_BIN_PATH}"

echo "installing kubectl"

curl -sLO "https://dl.k8s.io/release/v${K8S_CLI_VERSION}/bin/linux/amd64/kubectl"
curl -sLO "https://dl.k8s.io/v${K8S_CLI_VERSION}/bin/linux/amd64/kubectl.sha256"
echo "$(<kubectl.sha256) kubectl" | sha256sum -c -s
install -o $( id -u ) -g $( id -g ) -m 0755 /tmp/kubectl ${APPS_K8S_PATH}/kubectl
rm -rf /tmp/awscliv2.zip /tmp/kubectl /tmp/kubectl.sha256


kubectl version --client


# HELM
# the version of Helm to apply in Jarvis' IDEs
HELM_VERSION=3.10.0
# the URI to download Helm's binary from the original sources
HELM_DOWNLOAD_URI="https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
# the SHA checksum to verify, it is safe to install this Helm binary
HELM_DOWNLOAD_CHECKSUM=bf56beb418bb529b5e0d6d43d56654c5a03f89c98400b409d1013a33d9586474

# install Helm
curl -sL "${HELM_DOWNLOAD_URI}" -o /tmp/helm.tar.gz
echo "${HELM_DOWNLOAD_CHECKSUM}  /tmp/helm.tar.gz" | sha256sum -c -s
tar -xf /tmp/helm.tar.gz linux-amd64/helm
mv -v /tmp/linux-amd64/helm ${APPS_HELM_PATH}
chown "${NB_UID}:${NB_GID}" ${APPS_HELM_PATH}/helm
chmod 755 "${APPS_HELM_PATH}/helm"


# cleanup
rm /var/cache/apk/*
rm -rf /tmp/*
