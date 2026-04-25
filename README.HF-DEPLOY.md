# Hugging Face Docker Space — deployment checklist

Use this with the [Docker Spaces documentation](https://huggingface.co/docs/hub/spaces-sdks-docker).

1. **Root `Dockerfile`** — HF builds from the Space repo root. Add or maintain a root `Dockerfile` that installs dependencies, builds the Nest app if needed, and starts the API on the port declared below.

2. **`README.md` YAML** — Root `README.md` must start with the `---` … `---` block (`sdk: docker`, `app_port`, etc.). This repo keeps it at the top of `README.md` and mirrors the card fields in `README.HF.md`; update both when you change port or Space metadata.

3. **Port alignment** — `app_port` in the README (e.g. `7860`) must match how the container listens (e.g. Nest `listen(7860, '0.0.0.0')` or equivalent).

4. **Secrets** — Add database URLs, API keys, and other sensitive values under the Space **Settings → Variables and secrets**.

5. **Push** — Push `main` to the Hugging Face remote (this repo: `huggingface`) after the above files are in place.

For local Docker-only workflows, see **Docker requirements** in `README.md`.
