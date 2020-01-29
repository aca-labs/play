FROM crystallang/crystal:0.32.1

RUN apt-get update
RUN apt-get install --no-install-recommends -y \
    iputils-ping \
    curl \
    vim \
    httpie

RUN curl -o watchexec.deb -L https://github.com/watchexec/watchexec/releases/download/1.10.3/watchexec-1.10.3-x86_64-unknown-linux-gnu.deb \
    && dpkg -i watchexec.deb && rm watchexec.deb

# Install the latest version of LibSSH2 - required for core/driver
RUN curl -sLO https://launchpad.net/ubuntu/+source/libgpg-error/1.32-1/+build/15118612/+files/libgpg-error0_1.32-1_amd64.deb && dpkg -i libgpg-error0_1.32-1_amd64.deb
RUN curl -sLO https://launchpad.net/ubuntu/+source/libgcrypt20/1.8.3-1ubuntu1/+build/15106861/+files/libgcrypt20_1.8.3-1ubuntu1_amd64.deb && dpkg -i libgcrypt20_1.8.3-1ubuntu1_amd64.deb
RUN curl -sLO https://launchpad.net/ubuntu/+source/libssh2/1.8.0-2/+build/15151524/+files/libssh2-1_1.8.0-2_amd64.deb && dpkg -i libssh2-1_1.8.0-2_amd64.deb
RUN curl -sLO https://launchpad.net/ubuntu/+source/libgpg-error/1.32-1/+build/15118612/+files/libgpg-error-dev_1.32-1_amd64.deb && dpkg -i libgpg-error-dev_1.32-1_amd64.deb
RUN curl -sLO https://launchpad.net/ubuntu/+source/libgcrypt20/1.8.3-1ubuntu1/+build/15106861/+files/libgcrypt20-dev_1.8.3-1ubuntu1_amd64.deb && dpkg -i libgcrypt20-dev_1.8.3-1ubuntu1_amd64.deb
RUN curl -sLO https://launchpad.net/ubuntu/+source/libssh2/1.8.0-2/+build/15151524/+files/libssh2-1-dev_1.8.0-2_amd64.deb && dpkg -i libssh2-1-dev_1.8.0-2_amd64.deb
RUN rm -rf ./*.deb

COPY . /play
WORKDIR /play
RUN rm -r lib bin
RUN shards install

# Expose a range of ports to 'play' on
EXPOSE 4040-4060
CMD ["crystal", "play", "-v", "-b", "0.0.0.0", "-p", "4040"]
