# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A collection of Dockerfiles that build a matrix of PHP base images published to Docker Hub as `ogorbunov/php:<version>-<variant>`. There is no application code — the "source" is Dockerfiles, shared config files, and a build script.

## Build & publish

`build.zsh` builds and pushes the whole matrix:

```zsh
./build.zsh
```

It iterates `VERSIONS` × `IMAGES` (defined at the top of the script) and runs `docker buildx build --platform linux/amd64,linux/arm64 --pull --no-cache -t ogorbunov/php:<version>-<variant> . -f ./<version>/<variant>/Dockerfile --push` for each — building **amd64 + arm64** and pushing one multi-arch manifest list per tag. `--pull --no-cache` is deliberate: the bases (`php:<v>-*`) and all PECL/apt/Composer installs float, so a refresh after PHP security releases must bypass the BuildKit layer cache to actually pick up new versions. Note:

- **Build context is always the repo root** (`.`), so every `COPY` path is relative to the repo root (e.g. `./configs/...`, `./scripts/...`), not to the Dockerfile's directory.
- A Dockerfile is only built if it exists; missing variant/version combinations are skipped silently.
- `VERSIONS` is the active publish set and the supported version trees: `7.4 8.2 8.4 8.5`. A version directory not listed here simply isn't built.
- Each image is pushed immediately after build so later images in the loop can pull it. Multi-platform builds run on a `docker-container` builder (the script bootstraps one named `phpmultiarch`) and **cannot be loaded into the local image store**, so dependents resolve their `FROM ogorbunov/php:<v>-<base>` from the registry — which is why the push-before-dependents ordering matters. Prerequisites: `docker login` to the `ogorbunov` namespace, and cross-arch emulation (OrbStack ships it; on plain Docker run `docker run --privileged --rm tonistiigi/binfmt --install all` once). For a quick local test of one image, `docker buildx build --platform linux/amd64 --load -t test . -f ./<v>/<variant>/Dockerfile` builds a single arch you can run under emulation.

To build a single image manually, run the same command the script would, from the repo root:

```zsh
docker build -t ogorbunov/php:8.4-cli . -f ./8.4/cli/Dockerfile
```

## Image architecture

Each version directory (`8.5/`, `8.4/`, …) holds one Dockerfile per variant. Variants form a **dependency chain via `FROM`**, so build order matters (the `IMAGES` array in `build.zsh` is already ordered correctly):

- `cli` — base, `FROM php:<v>-cli-<debian>`. Installs apt libs, builds core extensions (gd, gmp, intl, pdo_mysql, bcmath, opcache, zip), and PECL extensions (redis, igbinary, memcached, ds). Strips binaries to shrink layers.
- `fpm` — base, `FROM php:<v>-fpm-<debian>`. Same extension set as `cli`, plus `COPY`s the FPM pool config and an xdebug ini, and exposes 9000/9003. (7.4 has no `configs/7.4`, so its `fpm` skips those `COPY`s.)
- `event` — `FROM ogorbunov/php:<v>-cli`. Adds sockets, pcntl, and the `event` PECL extension.
- `cli-xdebug` / `fpm-xdebug` / `event-xdebug` — add Xdebug on top of the corresponding base (`event-xdebug` builds on `cli-xdebug`).
- `cli-composer` / `fpm-composer` / `event-composer` — add Composer (via `scripts/composer-install.sh`) and the Docker CE CLI on top of the corresponding base. The Docker CLI comes from Docker's apt repo via the **signed-keyring** method (`/etc/apt/keyrings/docker.asc` + `signed-by=`), not `apt-key` — `apt-key` was removed in Debian 12, so the keyring method is required on bookworm.
- `cli-node` — `FROM ogorbunov/php:<v>-cli-composer`, adds Node.js via NodeSource: `setup_20.x` on 7.4, `setup_22.x` on 8.2, `setup_24.x` on 8.4/8.5.

So a dependent variant pulls `ogorbunov/php:<v>-<base>`, which means the base must be built/pushed first.

**Base OS per version:** 7.4 → `bullseye` (Debian 11); 8.2 & 8.4 → `bookworm` (Debian 12); 8.5 → `trixie` (Debian 13). Only `cli`/`fpm` carry a `php:*` base; all other variants inherit the OS transitively. The 7.4–8.4 `event` images pin a libevent runtime package (`libevent-2.1-7`), which is why 8.2/8.4 stay on bookworm — Debian 13 renames it to `libevent-2.1-7t64`. 8.5's `event` images instead install only `libevent-dev` and let apt pull the right runtime transitively, so they're OS-agnostic.

### Shared files (referenced from Dockerfiles)

- `scripts/composer-install.sh` — checksum-verified Composer install, used by all `*-composer` images.
- `scripts/pickle-install.sh` — installs the `pickle` PECL helper (not currently wired into any Dockerfile).
- `configs/<version>/php-fpm.d/www.conf` — FPM pool config copied into `fpm` images.
- `configs/<version>/xdebug/zz-xdebug-docker.ini` — Xdebug config (`client_host=host.docker.internal`, `mode=debug`) copied into `fpm` images.

## Adding a new PHP version

New version directories are created by copying the previous version's directory and config folder, then updating version references. **The copy leaves stale references to the old version that must be corrected** — this is the main gotcha in this repo. After copying, in the new `<version>/` tree update:

1. The `FROM php:<v>-...-<debian>` lines in `cli`/`fpm` (pick the newest Debian that PHP version's official image supports).
2. Every `FROM ogorbunov/php:<v>-...` line in the dependent variants.
3. The `COPY ./configs/<v>/...` paths in `fpm` (and create the matching `configs/<version>/` files).
4. Add the new version to `VERSIONS` in `build.zsh`.

Watch for leftover references to the source version (a wrong `FROM ogorbunov/php:<old>-...` or `COPY ./configs/<old>/...`). Check every kept version for cross-version mismatches with:

```zsh
for v in 7.4 8.2 8.4 8.5; do grep -H "ogorbunov/php\|./configs/" $v/*/Dockerfile | grep -v ":.*$v\b\|/$v/"; done
```

## Build gotchas (learned the hard way)

- **memcached on bookworm (8.2/8.4)** needs both `libssl-dev` and `libsasl2-dev` in the `cli`/`fpm` apt list. Bookworm ships the libmemcached **1.1.4** "awesomized" fork (bullseye had 1.0.18), whose detection probe in `php-memcached`'s `configure` pulls in OpenSSL. Without `libssl-dev` it fails with a *misleading* `configure: error: memcached support requires libmemcached` — the real missing piece is the OpenSSL headers. `libsasl2-dev` is needed for the default `--enable-memcached-sasl`.
- **7.4 is EOL (Nov 2022)** — `pecl install` grabs latest releases, several of which dropped 7.4 support, so extensions are version-pinned in the 7.4 Dockerfiles: `ds-1.4.0` (latest `ds` needs PHP ≥8.2) and `xdebug-3.1.6` (latest needs PHP ≥8.0). If a 7.4 build starts failing with `requires PHP (version >= …)`, pin that extension to its last 7.4-compatible release.
- **Bullseye (7.4) apt repos live on `archive.debian.org`** — Debian 11 LTS ended 2026-08-31 and `deb.debian.org` 404s on `bullseye-security` packages (the Release file still answers, so `apt-get update` succeeds and the failure only shows at download time). The 7.4 `cli`/`fpm` Dockerfiles rewrite `/etc/apt/sources.list` to the archive before any apt call; dependent 7.4 images inherit it. The archive Release files carry no `Valid-Until`, so no `Check-Valid-Until=false` is needed. No further Debian security updates arrive for 7.4 images.
- **`memcached` is a PECL extension, not bundled** — install it with `pecl install memcached`, never `docker-php-ext-install memcached` (there is no `ext/memcached` in php-src).
- **`event` images**: build sockets/pcntl and `pecl install event` in a single RUN with `docker-php-source extract` so `event`'s configure can find `php_sockets.h`. The 7.4–8.4 trees pin a Debian-specific libevent runtime package (`libevent-2.1-7` on bullseye/bookworm; buster's `2.1-6` no longer exists, trixie's is `2.1-7t64`). **8.5 installs only `libevent-dev`** and lets apt pull the matching runtime — version-agnostic, so it survives a Debian bump. Prefer this approach for new versions.
- **OPcache is built-in on PHP 8.5** (statically compiled — `php -m` shows `Zend OPcache`, there is no `opcache.so`). `docker-php-ext-install opcache` builds nothing → `cp: cannot stat 'modules/*'`, which aborts the whole combined extension RUN; `docker-php-ext-enable opcache` errors with `'opcache' does not exist`. So 8.5's `cli`/`fpm` omit `opcache` from the install/enable lists (it's already active). 8.4 and earlier ship it as a shared module, so they keep it. When adding a new version, check whether OPcache is built-in (`docker run --rm php:<v>-cli-<os> php -m | grep -i opcache` with no `opcache.so` on disk).
