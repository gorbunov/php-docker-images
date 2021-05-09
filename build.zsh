#!/usr/bin/env zsh

IMAGES=('cli' 'event' 'fpm' 'cli-xdebug' 'event-xdebug' 'fpm-xdebug' 'cli-composer' 'cli-node' 'event-composer' 'fpm-composer')
#IMAGES=('cli' 'fpm' 'cli-composer' 'cli-node')
#IMAGES=('fpm')
NAMESPACE="ogorbunov"
REPO_NAME="php"
VERSIONS=("7.4" "8.0")
#VERSIONS=("8.0")

TAGBASE="${NAMESPACE}/${REPO_NAME}"

for VERSION in "${VERSIONS[@]}"; do
  for TAG in "${IMAGES[@]}"; do
    TAG_AS="${TAGBASE}:${VERSION}-${TAG}"
    DOCKERFILE_NAME="./${VERSION}/${TAG}/Dockerfile"
    if [ -f "$DOCKERFILE_NAME" ]; then
      docker build -t "$TAG_AS" . -f "$DOCKERFILE_NAME" && docker image push "$TAG_AS"
    fi
  done
done
