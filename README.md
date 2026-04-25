---
title: Eduverse Backend
emoji: "🚀"
colorFrom: blue
colorTo: indigo
sdk: docker
app_port: 7860
pinned: false
---

# EduVerse Backend

Backend API for EduVerse.

The YAML header above configures this repository when it is used as a [Hugging Face Docker Space](https://huggingface.co/docs/hub/spaces-sdks-docker).

## Tech Stack

- NestJS
- TypeScript
- MySQL (TypeORM)
- Docker

## Local Development

1. Install dependencies:

```bash
npm install
```

2. Configure environment variables in `.env`.

3. Start development server:

```bash
npm run start:dev
```

Default local API URL: `http://localhost:8081`

## Docker requirements

### Local tooling

- **Docker Engine** 20.10 or newer (or **Docker Desktop** with WSL2 on Windows), with the Docker CLI available in your shell.
- Optional: **Docker Compose** v2 if you use multi-service compose files.

Use these to build and run container images once a `Dockerfile` is present at the repository root (or follow your own compose layout).

### Hugging Face Spaces (Docker SDK)

[Hugging Face Docker Spaces](https://huggingface.co/docs/hub/spaces-sdks-docker) expect:

1. A **`Dockerfile` at the repository root** of the Space (same layout as this repo when mirrored to HF).
2. A **`README.md` YAML header** at the repo root with at least `sdk: docker` and **`app_port`** set to the port your process listens on (default HF port is **7860**). The header must match the port you expose in the container (for example `CMD` / `EXPOSE`).
3. The app should bind to **`0.0.0.0`**, not only `localhost`, so the Space proxy can reach it.
4. **Runtime UID 1000**: HF runs the container as user id 1000; follow the [permissions guidance](https://huggingface.co/docs/hub/spaces-sdks-docker#permissions) (`USER`, `COPY --chown`, etc.) to avoid file permission errors.
5. **Secrets and variables**: configure build-time and runtime values in the Space **Settings** tab ([docs](https://huggingface.co/docs/hub/spaces-overview#managing-secrets)).

The same keys as in **`README.HF.md`** are kept in this file so the Space builder picks up `sdk: docker` and `app_port`. Edit **`README.HF.md`** when you want a canonical copy of only the card metadata (for example to paste into another repo).

More detail: **`README.HF.md`** (metadata notes) and **`README.HF-DEPLOY.md`** (checklist).

## Hugging Face Deployment

This repository also supports deployment to a Hugging Face Docker Space.

- Hugging Face metadata README: `README.HF.md`
- Deployment guide: `README.HF-DEPLOY.md`
