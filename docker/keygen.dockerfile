FROM debian:bullseye-slim

RUN useradd -m tools

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssl gnupg openssh-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /home/tools

USER tools

CMD ["bash"]
