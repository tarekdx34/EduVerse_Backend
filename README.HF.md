---
title: Eduverse Backend
emoji: "🚀"
colorFrom: blue
colorTo: indigo
sdk: docker
app_port: 7860
pinned: false
---

# EduVerse Backend Space

Dockerized backend deployment for EduVerse.

This Space runs the backend API container.

## Docker / Space requirements

- **`sdk: docker`** — Declares a [Docker Space](https://huggingface.co/docs/hub/spaces-sdks-docker). HF builds from a root **`Dockerfile`**.
- **`app_port`** — Must equal the port your process binds to inside the container (here **7860**). The app must listen on **`0.0.0.0`** so the Space proxy can connect.
- **Permissions** — Prefer a non-root user with UID **1000** and `COPY --chown` / `WORKDIR` patterns from the [HF Docker permissions section](https://huggingface.co/docs/hub/spaces-sdks-docker#permissions).
- **Configuration** — Use Space **Settings** for secrets and environment variables at build and runtime.

Root **`README.md`** includes the same YAML block for the Space builder; this file documents the card fields only. See **`README.HF-DEPLOY.md`** for a short checklist and **`README.md`** for general Docker prerequisites.
