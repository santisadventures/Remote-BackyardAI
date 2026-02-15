# Publishing To GitHub (Clean Repo)

This folder (`santisplayground_repo/`) is intended to be published as its own GitHub repository.

## 1) Sanity Check

- Ensure you are not committing private keys.
- Ensure `.env` is not committed (use `.env.example` instead).
- If you used Termius, never copy/paste the "BEGIN OPENSSH PRIVATE KEY" section into the repo.

## 2) Initialize a Repo Inside This Folder

```bash
cd santisplayground_repo
git init
git add .
git commit -m "Initial release: local Ollama + SSH chat gateway template"
```

## 3) Push To GitHub

Create an empty repo on GitHub, then:

```bash
git branch -M main
git remote add origin https://github.com/<ORG_OR_USER>/<REPO>.git
git push -u origin main
```

## 4) What Users Do After Cloning

```bash
cp .env.example .env
# edit .env
docker compose up -d --build
```

