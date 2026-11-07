**Docker-Bot**

Ready-to-run Docker images for my Telegram bot workloads. Each variant layers a self-contained Python environment on top of a prebuilt media toolbox, so you get FFmpeg, aria2c, rclone, 7-Zip and friends together with the bot dependencies — without installing anything on the host.

## Features

- **Two variants** — `gemoe` and `mltb`, each with its own dependency set
- **Isolated environments** — packages live in `/gemoe` (plus `/librespot`) and `/mltb`, not in the system Python
- **Prebuilt toolbox base** — media and CLI utilities inherited from `arakurumi/myne` and `arakurumi/mltb`
- **Multi-architecture** — `linux/amd64` and `linux/arm64` in a single manifest per tag
- **Daily rebuilds** — refreshed automatically on a schedule and on every change to its source directory
- **Verified publishes** — every build checks that the environment and key packages import inside the pushed image
- **No exposed ports** — designed for interactive use and for running bot code you mount in

| Tag      | Base image             | Virtual environment       | Platforms             |
| -------- | ---------------------- | ------------------------- | --------------------- |
| `gemoe`  | `arakurumi/myne:alpine`  | `/gemoe`, `/librespot`    | linux/amd64, arm64    |
| `mltb`   | `arakurumi/mltb:latest` | `/mltb`                   | linux/amd64, arm64    |

## Quick Start

Pull the image for the bot you want to run:

```bash
docker pull arakurumi/bot:gemoe
```

Start an interactive shell:

```bash
docker run --rm -it arakurumi/bot:gemoe
```

Working on files in your current directory? Mount it as a workspace:

```bash
docker run --rm -it -v "$PWD:/workspace" -w /workspace arakurumi/bot:gemoe
```

On Windows PowerShell:

```powershell
docker run --rm -it -v "${PWD}:/workspace" -w /workspace arakurumi/bot:gemoe
```

For the MLTB environment, use `arakurumi/bot:mltb`.

Because dependencies are installed into virtual environments, run bot code with the bundled interpreter:

```bash
docker run --rm arakurumi/bot:gemoe /gemoe/bin/python -c "import kurigram, yt_dlp; print('ok')"
```

```bash
docker run --rm arakurumi/bot:mltb /mltb/bin/python -c "import kurigram, yt_dlp; print('ok')"
```

## Configuration

No environment variables or ports are required. Both images default to `/bin/sh` as their command and inherit the media tooling and defaults of their base toolbox image.

## Tags

Only the two variant tags are published:

```text
gemoe
mltb
```

These tags are rebuilt and pushed automatically on changes to the source and on a daily schedule, so their contents can change between pulls.

## Updating

Pull fresh copies of the tag you use:

```bash
docker pull arakurumi/bot:gemoe
docker pull arakurumi/bot:mltb
```

## Documentation

Full source and build details are on GitHub: [arakurumi/Docker-Bot](https://github.com/arakurumi/Docker-Bot)

## License

Released under the [MIT License](https://opensource.org/license/mit).
