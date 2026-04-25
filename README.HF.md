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

When this repository is the source for the Space, the same YAML block should appear at the top of root **`README.md`** (this file is the canonical copy for the EduVerse card). See **`README.HF-DEPLOY.md`** for a short checklist and **`README.md`** for general Docker prerequisites.
