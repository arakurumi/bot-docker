# Docker-Bot

Docker images for my Telegram bot workloads, published to Docker Hub as `arakurumi/bot`.

![Docker Pulls](https://img.shields.io/docker/pulls/arakurumi/bot)

---

## Overview

Docker-Bot packages two Python environments on top of the prebuilt media toolboxes published as `arakurumi/myne` and `arakurumi/mltb`. Each variant installs its own dependency set into a self-contained virtual environment, so both images share the same base CLI tooling while keeping bot packages isolated from each other.

Two variants are published — `gemoe` and `mltb` — and both are built for `linux/amd64` and `linux/arm64`.

---

## Variants

| Tag                    | Base image             | Virtual environment          | Default shell | Platforms              |
| ---------------------- | ---------------------- | ---------------------------- | ------------- | ---------------------- |
| `arakurumi/bot:gemoe`  | `arakurumi/myne:alpine`  | `/gemoe` and `/librespot`    | `/bin/sh`     | `linux/amd64`, `arm64` |
| `arakurumi/bot:mltb`   | `arakurumi/mltb:latest` | `/mltb`                      | `/bin/sh`     | `linux/amd64`, `arm64` |

---

## Features

- **Two bot environments** — pick the image that matches the bot you are running.
- **Prebuilt base toolboxes** — the base images already ship the media and CLI tooling (FFmpeg, aria2c, rclone, 7-Zip, and similar utilities), so the bot layers only install Python dependencies.
- **Isolated virtual environments** — dependencies live in `/gemoe` and `/mltb` (plus `/librespot` for the Spotify client) instead of the system Python.
- **Multi-architecture** — built natively for `linux/amd64` and `linux/arm64`, then published as a single multi-arch manifest per tag.
- **Cached, daily rebuilds** — GitHub Actions layer caching keeps builds fast, while a daily `CACHE_BUST` build argument re-resolves dependencies once a day.
- **Post-publish verification** — every build checks that the virtual environments exist and that the key packages actually import inside the pushed image.
- **Automatic publishing** — each image is rebuilt on changes to its directory and on a daily schedule.

---

## Included Packages

Package lists live in `Gemoe/requirements.txt` and `MLTB/requirements.txt` and are installed with `pip` into their virtual environments.

### `gemoe`

- **Telegram & runtime** — `kurigram[fast]`, `python-dotenv`, `tenacity`, `psutil`, `aiofiles`, `aioshutil`
- **Download & media** — `yt-dlp[default,curl-cffi]`, `gallery-dl`, `curl-cffi`, `pycurl`, `requests`, `m3u8`, `vcsi`, `subby`, `mal-api`, `langcodes[data]`, `xmltodict`, `temari`, `speedtest-cli`
- **Parsing & crypto** — `bs4`, `lxml`, `Pillow`, `pycryptodome`, `pybase62`, `pywidevine`, `mutagen`, `python-magic`
- **Spotify** — `librespot`, installed into its own `/librespot` environment

### `mltb`

- **Telegram & runtime** — `kurigram[fast]`, `tenacity`, `psutil`, `aiofiles`, `aioshutil`, `urllib3`
- **Download clients** — `aioaria2`, `aioqbt`, `yt-dlp[default]`, `gallery-dl`
- **Web API** — `fastapi`, `uvicorn`, `uvloop`, `aiohttp`, `jinja2`, `anytree`, `natsort`
- **Storage & Google** — `pymongo`, `google-api-python-client`, `google-auth-httplib2`, `google-auth-oauthlib`
- **Parsing & crypto** — `lxml`, `pillow`, `pycryptodome`, `pycurl`, `python-magic`, `requests`, `speedtest-cli`

---

## Requirements

- An OCI-compatible runtime — Docker Engine, Docker Desktop, or Podman.
- BuildKit for local builds; the Dockerfiles use `RUN --mount=type=cache` for pip.
- A `linux/amd64` or `linux/arm64` host.
- Internet access during the build, because `pip` resolves packages from index and VCS sources.

---

## Installation

Pull the image you want to use from Docker Hub:

```sh
docker pull arakurumi/bot:gemoe
```

```sh
docker pull arakurumi/bot:mltb
```

---

## Usage

Start an interactive shell:

```sh
docker run --rm -it arakurumi/bot:gemoe
```

```sh
docker run --rm -it arakurumi/bot:mltb
```

Mount a local working directory:

```sh
docker run --rm -it -v "$PWD:/workspace" -w /workspace arakurumi/bot:gemoe
```

Using Windows PowerShell:

```powershell
docker run --rm -it -v "${PWD}:/workspace" -w /workspace arakurumi/bot:gemoe
```

Run code against the bot environment explicitly, since the dependencies are not installed into the system Python:

```sh
docker run --rm arakurumi/bot:gemoe /gemoe/bin/python -c "import kurigram, yt_dlp; print('ok')"
```

```sh
docker run --rm arakurumi/bot:mltb /mltb/bin/python -c "import kurigram, yt_dlp; print('ok')"
```

> These images expose no ports by default and default to `/bin/sh`; they are intended for interactive use and for running bot code that you mount or copy in.

---

## Building Locally

```sh
docker build -t bot:gemoe ./Gemoe
```

```sh
docker build -t bot:mltb ./MLTB
```

The build resolves dependencies once and caches them. To force a fresh dependency resolve, pass the same build argument the CI uses:

```sh
docker build --build-arg CACHE_BUST="$(date -u +%Y%m%d)" -t bot:gemoe ./Gemoe
```

> **Note:** The first build is slow because several dependencies (`pycurl`, `lxml`, `Pillow`, `pymongo`, `uvloop`, and others) may need to be compiled from source.

---

## How It's Built

Each image directory contains:

- **`Dockerfile`** — a multi-stage build definition:
  - A `builder` stage based on the matching toolbox image, with the temporary `.build-deps` packages needed to compile Python wheels.
  - `requirements.txt` is copied in first, then installed into the virtual environment with a pip cache mount, so source file changes do not re-download packages.
  - `ARG CACHE_BUST` makes the install layer rebuild once a day, keeping the scheduled build fresh without disabling the cache.
  - A `runtime` stage copies only the final filesystem from `builder`, so build tools and caches never reach the published image.
- **`requirements.txt`** — the Python dependency list for that variant.

Each workflow in `.github/workflows/` runs four jobs:

- **`meta`** — resolves the tag (`gemoe` or `mltb`) and the OCI labels once.
- **`build`** — builds `linux/amd64` and `linux/arm64` on native runners (`ubuntu-26.04` and `ubuntu-26.04-arm`), pushes each architecture by digest, and stores the layers in the GitHub Actions cache per architecture.
- **`merge`** — combines the per-architecture digests into one multi-arch manifest for the tag.
- **`verify`** — pulls the published image and checks that the virtual environments exist and that the key dependencies import.

---

## Repository Layout

```text
.
|-- Gemoe/
|   |-- Dockerfile
|   `-- requirements.txt
|-- MLTB/
|   |-- Dockerfile
|   `-- requirements.txt
`-- .github/
    `-- workflows/
        |-- gemoe.yml
        `-- mltb.yml
```

---

## Publishing to Docker Hub

Separate workflows build and push each image to Docker Hub as `arakurumi/bot` with the matching tag:

- `.github/workflows/gemoe.yml` → `arakurumi/bot:gemoe`
- `.github/workflows/mltb.yml` → `arakurumi/bot:mltb`

Both workflows:

- Trigger on pushes to their image directory (`Gemoe/**`, `MLTB/**`), on a daily `cron` schedule, and via manual `workflow_dispatch`.
- Resolve tags and OCI labels once in a `meta` job and reuse them in every build and in the final manifest.
- Build each architecture on a native runner, then merge the per-architecture digests into a single multi-arch manifest.
- Reuse BuildKit's GitHub Actions layer cache per architecture (`scope=<variant>-<arch>`) and invalidate it once a day through the `CACHE_BUST` build arg instead of disabling the cache entirely.
- Cancel superseded runs of the same workflow through `concurrency`.
- Authenticate to Docker Hub with the repository secrets `DOCKER_USERNAME` and `DOCKER_PASSWORD`.

---

## Notes

- Images are built and published for both `linux/amd64` and `linux/arm64`.
- Publishing arm64 builds requires access to GitHub-hosted arm64 runners for the repository; if they are unavailable, drop the `arm64` entry from the build matrix or build that platform under QEMU (much slower for compiled dependencies).
- The `verify` job imports `kurigram`, `yt_dlp`, `gallery_dl`, `pycurl`, `lxml`, `PIL`, `Crypto`, and friends; a failure there means the published image is unusable and should be rebuilt.
- The base images and dependency version ranges are resolved at build time, so image contents can change between builds.
- Build steps require internet access during `docker build`.
- Temporary build tools, package caches, and the copied `Dockerfile`/`requirements.txt` are removed before the runtime stage is assembled.

---

## License

Per the Open Container Initiative labels written by the GitHub Actions workflows, this project is released under the [MIT License](https://opensource.org/license/mit).
