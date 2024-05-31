FROM dockerhub.timeweb.cloud/bash:5.2.26-alpine3.20

RUN set -eux; \
  apk add --update --no-cache \
  jq \
  git \
  curl \
  openssh-client \
  tree \
  rsync; \
  apk --no-cache del; \
  addgroup -S xbash; \
  adduser -S xbash -G xbash -h /home/xbash -s /bin/bash; \
  ln /usr/local/bin/bash /bin/bash;

WORKDIR /home/xbash
ENTRYPOINT []
CMD ["bash", "--help"]
