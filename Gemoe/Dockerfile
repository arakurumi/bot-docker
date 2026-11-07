FROM arakurumi/myne:alpine AS builder

ENV CC=gcc \
    CXX=g++ \
    PIP_DISABLE_PIP_VERSION_CHECK=1

COPY requirements.txt /

RUN apk add --no-cache --virtual .build-deps build-base curl-dev freetype-dev jpeg-dev libffi-dev libxml2-dev libxslt-dev linux-headers openssl-dev zlib-dev \
    && apk add --no-cache freetype libjpeg-turbo libxml2 libxslt zlib

RUN python -m venv --system-site-packages gemoe

ARG CACHE_BUST=local

RUN --mount=type=cache,target=/root/.cache/pip \
    echo "Cache bust: ${CACHE_BUST}" \
    && /gemoe/bin/pip install --requirement /requirements.txt

RUN python -m venv --system-site-packages librespot

RUN --mount=type=cache,target=/root/.cache/pip \
    echo "Cache bust: ${CACHE_BUST}" \
    && /librespot/bin/pip install librespot

RUN apk del .build-deps \
    && rm -rf /var/cache/apk /tmp/* /root/.cache /Dockerfile /requirements.txt

FROM arakurumi/myne:alpine

COPY --from=builder / /

CMD ["/bin/sh"]
