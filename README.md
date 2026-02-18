# opencode-web-devcontainer

A containerized [OpenCode](https://opencode.ai) dev environment with `gh`, `mise`, and a live app preview sidecar. Designed for multi-project deployments on Kubernetes — each project gets its own independent instance with its own storage and ingress.

## What's inside

- **[opencode](https://opencode.ai)** — AI coding agent, served as a web UI on port 4096
- **[gh](https://cli.github.com)** — GitHub CLI for repo operations
- **[mise](https://mise.jdx.dev)** — Polyglot tool version manager (installs node, python, ruby, etc.)
- **Startup clone** — on first boot, the configured GitHub repo is cloned into `~/workspace`
- **Preview sidecar** — a configurable dev server runs alongside opencode and exposes the app being developed

## Environment variables / secrets

| Variable | Required | Description |
|----------|----------|-------------|
| `GH_TOKEN` | Yes | GitHub personal access token (repo + packages scope) |
| `REPO_NAME` | Yes | GitHub repo to clone, e.g. `owner/my-website` |
| `OPENCODE_SERVER_PASSWORD` | Yes | Password for the OpenCode web UI (HTTP Basic Auth) |
| `OPENCODE_SERVER_USERNAME` | No | Username for the web UI (default: `opencode`) |
| `ANTHROPIC_API_KEY` | No | API key for Claude models |
| `OPENAI_API_KEY` | No | API key for GPT models |
| `GEMINI_API_KEY` | No | API key for Gemini models |
| `DEV_SERVER_CMD` | No | Command to start the dev server (default: `npm run dev -- --host 0.0.0.0`) |

## Running locally

Copy `.env.example` to `.env` and fill in your values, then:

```bash
docker compose up --build
```

- OpenCode web UI: http://localhost:4096
- App preview: http://localhost:5173 (or whichever port your dev server uses)

## Configuring the dev server

`DEV_SERVER_CMD` is the shell command run inside `~/workspace` to start the preview server. Examples:

| Stack | `DEV_SERVER_CMD` |
|-------|-----------------|
| Vite / Vue / React | `npm run dev -- --host 0.0.0.0` |
| Next.js | `npm run dev -- -H 0.0.0.0` |
| Jekyll | `bundle exec jekyll serve --host 0.0.0.0` |
| Python HTTP | `python -m http.server 5173` |
| Ruby on Rails | `bin/rails server -b 0.0.0.0 -p 5173` |

The preview sidecar shares the same `~/workspace` volume as opencode, so changes made by opencode are immediately visible in the preview.

## Installing tools with mise

Once inside the container (or via `kubectl exec`), use mise to install any runtime:

```bash
mise install node@22
mise install python@3.12
mise install ruby@3.3
```

Tool installations persist across restarts because `~/.local/share/mise` lives on the persistent PVC.

## Kubernetes deployment

Each project gets its own independent deployment. See the `_template/` directory in the cluster repo:

```
kubernetes/apps/my-software-development/_template/
```

To deploy a new project:

1. Copy the template directory: `cp -r _template opencode-myproject`
2. Replace `PROJECT_NAME` with `myproject` in all files
3. Fill in `app/secrets.sops.yaml` and encrypt: `sops -e -i app/secrets.sops.yaml`
4. Add `- ./opencode-myproject/ks.yaml` to `my-software-development/kustomization.yaml`
5. Commit and push — Flux will deploy automatically

Each deployment gets:
- Its own 5Gi Longhorn PVC at `/home/opencode`
- Its own ingress at `opencode-myproject.<domain>` and `opencode-myproject-preview.<domain>`
- Its own secret with project-specific config
