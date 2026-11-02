#!/bin/sh
export CC=clang
apk add --no-cache --virtual .build-deps build-base clang
pip install --break-system-packages --no-cache-dir TgCrypto
apk del .build-deps
