FROM crystallang/crystal:0.32.1-alpine

RUN apk update
RUN apk add \
    curl \
    vim \
    httpie \
    libssh2 \
    libssh2-dev

# TODO:: remove this once watchexec is in the main repository
RUN apk add watchexec --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

COPY . /play
WORKDIR /play
RUN rm -rf lib bin
RUN shards install

# Expose a range of ports to 'play' on
EXPOSE 4040-4060
CMD ["crystal", "play", "-v", "-b", "0.0.0.0", "-p", "4040"]
