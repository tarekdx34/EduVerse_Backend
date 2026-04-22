# Hugging Face Deployment Guide (EduVerse Backend)

This guide documents how we deploy the backend to Hugging Face Space while keeping normal development on GitHub.

## Current Setup

- GitHub remote: `origin`
- Hugging Face remote: `huggingface`
- HF Space URL: `https://huggingface.co/spaces/Awab-Elsadig/eduverse-backend`
- HF deploy branch in local repo: `hf-clean`
- HF production branch target: `huggingface/main`

## Why We Use `hf-clean`

Hugging Face rejected pushes from normal `main` because historical commits included blocked binary files (for example files under `uploads/`).

To avoid rewriting GitHub history, we deploy from a clean branch (`hf-clean`) and push only that branch to HF `main`.

## One-Time Prerequisites

1. Install and login to HF CLI:
   - `hf auth login`
   - choose `Y` for "Add token as git credential"
2. Add remote:
   - `git remote add huggingface https://huggingface.co/spaces/Awab-Elsadig/eduverse-backend`
3. Ensure these files exist in deploy branch:
   - `README.md` with valid HF YAML metadata
   - root `Dockerfile`
   - root `.dockerignore`
4. Ensure `.gitignore` includes runtime uploads:
   - `uploads/`

## Normal Development Flow (GitHub)

Work normally on feature branches and `main` with `origin`.

Example:

```powershell
git checkout -b feature/my-change
# edit files
git add .
git commit -m "feat: my change"
git push origin feature/my-change
```

Merge to `main` when ready (as usual), then:

```powershell
git checkout main
git pull origin main
git push origin main
```

## Deploy to HF (Production-Ready Only)

When changes are stable and ready for cross-device testing:

1. Switch to deploy branch:

```powershell
git checkout hf-clean
```

2. Bring only required commit(s) from `main`:

```powershell
git cherry-pick <commit_sha_from_main>
```

3. Push to HF:

```powershell
git push huggingface hf-clean:main
```

If push is rejected with `stale info` or non-fast-forward:

```powershell
git ls-remote huggingface refs/heads/main
git push --force-with-lease=refs/heads/main:<hash_from_previous_command> huggingface hf-clean:main
```

## HF Runtime Requirements

In Space Settings -> Variables and secrets, set required backend env vars:

- DB vars: `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_DATABASE`
- Supabase vars used by backend
- JWT/auth vars used by backend
- Optional mail vars if email is needed:
  - `MAIL_HOST`, `MAIL_PORT`, `MAIL_SECURE`, `MAIL_USER`, `MAIL_PASSWORD`, `MAIL_FROM_NAME`, `MAIL_FROM_ADDRESS`

Notes:

- Missing env vars will crash startup.
- SMTP errors will not block app startup unless email is mandatory in a code path.

## Common Errors and Fixes

1. `Your push was rejected because it contains binary files`
   - Cause: blocked binary in history
   - Fix: deploy from `hf-clean`, not from local `main`

2. `Missing configuration in README`
   - Cause: missing/invalid HF YAML metadata block in root `README.md`
   - Fix: ensure valid metadata and real emoji character

3. `A circular dependency has been detected ...` from Swagger
   - We disabled Swagger by default for deployment stability.
   - Re-enable only after fixing DTO schema issue and setting `ENABLE_SWAGGER=true`.

## Quick Deploy Checklist

```powershell
git checkout hf-clean
git cherry-pick <sha1> <sha2> ...
git ls-remote huggingface refs/heads/main
git push --force-with-lease=refs/heads/main:<remote_hash> huggingface hf-clean:main
```

