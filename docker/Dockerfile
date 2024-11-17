FROM bash:5.2-alpine3.20
RUN set -eux; \
  apk add --update --no-cache \
  jq \
  git \
  curl \
  openssh-client \
  tree \
  rsync \
  nmap \
  bind-tools \
  ca-certificates; \
  apk --no-cache del; \
  ln /usr/local/bin/bash /bin/bash;
WORKDIR /home/xbash
ENTRYPOINT []
CMD ["bash", "--help"]
