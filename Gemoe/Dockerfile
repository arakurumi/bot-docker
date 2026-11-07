FROM arakurumi/myne:alpine AS builder

COPY . /

ENV CC=gcc CXX=g++

RUN apk add --no-cache --virtual .build-deps build-base curl-dev freetype-dev jpeg-dev libffi-dev libxml2-dev libxslt-dev linux-headers openssl-dev zlib-dev \
    && apk add --no-cache freetype libjpeg-turbo libxml2 libxslt zlib

RUN python -m venv --system-site-packages gemoe

RUN /gemoe/bin/pip install --no-cache-dir --requirement requirements.txt

RUN python -m venv --system-site-packages librespot

RUN /librespot/bin/pip install --no-cache-dir librespot

RUN apk del .build-deps && rm -rf /var/cache/apk /tmp/* /root/.cache

FROM arakurumi/myne:alpine

COPY --from=builder / /

CMD ["/bin/sh"]
