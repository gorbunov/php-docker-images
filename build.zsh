#!/usr/bin/env zsh

IMAGES=('cli' 'event' 'fpm' 'cli-xdebug' 'event-xdebug' 'fpm-xdebug' 'cli-composer' 'cli-node' 'event-composer' 'fpm-composer')
VERSIONS=("7.4" "8.2" "8.4" "8.5")
PLATFORMS="linux/amd64,linux/arm64"

NAMESPACE="ogorbunov"
REPO_NAME="php"
BUILDER="phpmultiarch"

TAGBASE="${NAMESPACE}/${REPO_NAME}"

# Multi-platform builds + pushing a manifest list require the docker-container
# driver (the default "docker" driver can't). Create the builder once, then reuse it.
if ! docker buildx inspect "$BUILDER" >/dev/null 2>&1; then
  docker buildx create --name "$BUILDER" --driver docker-container --bootstrap >/dev/null
fi
docker buildx use "$BUILDER"

for VERSION in "${VERSIONS[@]}"; do
  for TAG in "${IMAGES[@]}"; do
    TAG_AS="${TAGBASE}:${VERSION}-${TAG}"
    DOCKERFILE_NAME="./${VERSION}/${TAG}/Dockerfile"
    if [ -f "$DOCKERFILE_NAME" ]; then
      # Builds amd64 + arm64 and pushes a single multi-arch manifest list.
      # --push is required (multi-platform images can't be loaded locally); each
      # base is pushed before its dependents, which buildx then pulls per-platform.
      docker buildx build --platform "$PLATFORMS" -t "$TAG_AS" . -f "$DOCKERFILE_NAME" --push
    fi
  done
done
