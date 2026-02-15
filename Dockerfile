# Builder image
FROM docker.io/alpine as BUILDER

RUN apk add --no-cache curl jq tar

ARG LITESTREAM_VERSION=v0.5.6

RUN curl -fL \
  https://github.com/benbjohnson/litestream/releases/download/v0.5.6/litestream-0.5.6-linux-x86_64.tar.gz \
  -o litestream.tar.gz \
 && tar xzvf litestream.tar.gz
 

# Main image
FROM docker.io/louislam/uptime-kuma:beta as KUMA

ARG UPTIME_KUMA_PORT=3001
WORKDIR /app
RUN mkdir -p /app/data

COPY --from=BUILDER /litestream /usr/local/bin/litestream
COPY litestream.yml /etc/litestream.yml
COPY run.sh /usr/local/bin/run.sh

EXPOSE ${UPTIME_KUMA_PORT}

CMD [ "/usr/local/bin/run.sh" ]
