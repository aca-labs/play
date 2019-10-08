FROM crystallang/crystal:0.31.1

RUN apt-get update && apt-get install --no-install-recommends -y iputils-ping curl vim

RUN curl -o watchexec.deb -L https://github.com/watchexec/watchexec/releases/download/1.10.3/watchexec-1.10.3-x86_64-unknown-linux-gnu.deb \
    && dpkg -i watchexec.deb && rm watchexec.deb

# Expose a range of ports to 'play' on
EXPOSE 4040-4060
CMD ["crystal", "play", "-v", "-b", "0.0.0.0", "-p", "4040"]
