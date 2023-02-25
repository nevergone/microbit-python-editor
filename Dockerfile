ARG EDITOR_VERSION=3.0.17

# build components
FROM alpine:3.16 as build

ARG EDITOR_VERSION

RUN apk update \
    && apk upgrade \
    && apk --no-cache add \
         eudev-dev \
         gcc \
         linux-headers \
         make \
         musl-dev \
         npm \
         python3 \
         wget \
    ## download and extract python editor (https://unix.stackexchange.com/a/11019): https://github.com/microbit-foundation/python-editor-v3/
    && wget https://github.com/microbit-foundation/python-editor-v3/archive/refs/tags/v$EDITOR_VERSION.tar.gz \
    && mkdir python-editor \
    && tar xf v$EDITOR_VERSION.tar.gz -C python-editor --strip-components 1 \
    && rm v$EDITOR_VERSION.tar.gz \
    ## build editor
    && cd python-editor \
    && sed -i 's@\$npm_package_version@$EDITOR_VERSION@g' .env \
    && sed -i 's@\$npm_package_name@microbit-python-editor@g' .env \
    && npm install \
    && npm run build

# create destination image
FROM nginx:1.23-alpine

ARG EDITOR_VERSION

ENV EDITOR_VERSION=$EDITOR_VERSION

LABEL maintainer="Kurucz István <never@nevergone.hu>"
LABEL vendor="nevergone"

COPY --from=build /python-editor/build /usr/share/nginx/html
