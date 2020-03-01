# Container image that runs your code
FROM docker:19.03.6

RUN apk update \
  && apk upgrade \
  && apk add --no-cache git \
  && apk add bash

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
COPY GenericDockerfileForGo /GenericDockerfileForGo

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]