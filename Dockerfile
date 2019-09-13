FROM crystallang/crystal:0.30.1

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl iputils-ping curl nodejs npm vim

# Fix debian/ubuntu node naming goof
RUN ln -s $(which nodejs) /usr/bin/node
# Nodemon for super easy spec running
RUN npm install --global nodemon

# Expose a range of ports to 'play' on
EXPOSE 4040-4060
CMD ["crystal", "play", "-v", "-b", "0.0.0.0", "-p", "4040"]
