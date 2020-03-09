FROM crystallang/crystal:0.33.0-alpine

WORKDIR /play

RUN apk add \
    curl \
    gdb \
    httpie \
    libssh2 \
    libssh2-dev \
    vim

# TODO: remove this once watchexec is in the main repository
RUN apk add watchexec --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

COPY shard.yml shard.yml
COPY shard.lock shard.lock

RUN shards install

COPY README.md README.md
COPY sam.cr sam.cr

# Expose a range of ports to launch `crystal play` on
EXPOSE 4040-4060
CMD ["crystal", "play", "-v", "-b", "0.0.0.0", "-p", "4040"]
