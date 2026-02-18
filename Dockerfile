# Builder image
FROM docker.io/alpine as BUILDER

# Curl & Tar für Litestream + Busybox Download
RUN apk add --no-cache curl jq tar

# 1. Litestream holen
ARG LITESTREAM_VERSION=v0.5.6
RUN curl -fL https://github.com/benbjohnson/litestream/releases/download/v0.5.6/litestream-0.5.6-linux-x86_64.tar.gz \
    -o litestream.tar.gz \
    && tar xzvf litestream.tar.gz

# 2.
RUN curl -fL https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox \
    -o /busybox && chmod +x /busybox


# Main image
FROM docker.io/louislam/uptime-kuma:beta as KUMA

ARG UPTIME_KUMA_PORT=3001
WORKDIR /app
RUN mkdir -p /app/data

# 3. Binaries kopieren
COPY --from=BUILDER /litestream /usr/local/bin/litestream
COPY --from=BUILDER /busybox /usr/local/bin/busybox

# 4. Dummy-File für den Health-Check (ergibt 200 OK)
RUN mkdir -p /health && touch /health/health

COPY litestream.yml /etc/litestream.yml
COPY run.sh /usr/local/bin/run.sh

# Ports: Kuma (3001) + Health (8080)
EXPOSE ${UPTIME_KUMA_PORT} 8080

CMD [ "/usr/local/bin/run.sh" ]

