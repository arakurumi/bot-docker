FROM arakurumi/mltb:latest AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1

COPY requirements.txt /

RUN python -m venv --system-site-packages mltb

ARG CACHE_BUST=local

RUN --mount=type=cache,target=/root/.cache/pip \
    echo "Cache bust: ${CACHE_BUST}" \
    && /mltb/bin/pip install --requirement /requirements.txt

RUN apk del .build-deps \
    && rm -rf /var/cache/apk /tmp/* /root/.cache /Dockerfile /requirements.txt

FROM arakurumi/mltb:latest

COPY --from=builder / /

CMD ["/bin/sh"]
