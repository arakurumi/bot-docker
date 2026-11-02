#!/bin/sh
export CC=clang
apk add --no-cache --virtual .build-deps build-base clang curl-dev
pip install --break-system-packages --no-cache-dir pycurl TgCrypto
apk del .build-deps
