FROM arakurumi/mltb:latest AS builder

COPY . /

ENV CC=clang

RUN apk add --no-cache --virtual .build-deps build-base clang curl-dev

RUN python -m venv --system-site-packages mltb

RUN /mltb/bin/pip install --no-cache-dir --requirement requirements.txt

RUN apk del .build-deps && rm -rf /var/cache/apk /tmp/* /root/.cache

FROM arakurumi/mltb:latest

COPY --from=builder / /

CMD ["/bin/sh"]
