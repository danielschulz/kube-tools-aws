FROM alpine:3.16.2

# set some defaults
ENV AWS_DEFAULT_REGION "eu-central-1"

RUN apk --no-cache upgrade \
    && apk add --update bash ca-certificates git python3 jq

# https://github.com/sgerrand/alpine-pkg-glibc/releases
ENV GLIBC_VER=2.35-r0

ARG ALPINE_GLIC_URIL_STEM="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}"

COPY ./install.sh /root/install.sh

# install glibc compatibility for alpine and aws-cli v2
# https://github.com/aws/aws-cli/issues/4685#issuecomment-615872019
RUN apk update \
    && apk --no-cache add \
        binutils \
        curl \
        outils-sha256 \
    && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && curl -sLO "${ALPINE_GLIC_URIL_STEM}/glibc-${GLIBC_VER}.apk" \
    && curl -sLO "${ALPINE_GLIC_URIL_STEM}/glibc-bin-${GLIBC_VER}.apk" \
    && apk add --no-cache --force-overwrite \
        "glibc-${GLIBC_VER}.apk" "glibc-bin-${GLIBC_VER}.apk" \
    && chmod u+x /root/install.sh \
    && /root/install.sh \
    && apk --no-cache del \
        binutils \
        curl \
    && rm "glibc-${GLIBC_VER}.apk" "glibc-bin-${GLIBC_VER}.apk" \
    && rm -rf /var/cache/apk/*


CMD bash
