# Remeto-BackyardAI by Santisplayground

**Private Remote AI. Runs on your machine.**

RemoteSantis is a remote, phone-friendly AI chat system that runs entirely on your own hardware using local LLMs.

You connect from anywhere.  
The models never leave your machine.

Tested on **Apple Silicon Mac (M4)**.

---

## Threat Model

For a security-oriented overview of assumptions, mitigations, and residual risk, see:

- `THREAT_MODEL.md`

## What This Is

RemoteSantis gives you:

- A **remote AI assistant** accessible from your phone or laptop
- Local LLM inference (via Ollama)
- Private, invite-only access
- No public web exposure
- No shell access for users (chat-only environment)

This is not a SaaS wrapper.  
This is remote access to your own AI machine.

---

## Core Architecture

Remote access  
Local inference  
Private network only  

### Stack Overview

1. Tailscale creates a private encrypted mesh network.
2. Users connect remotely via SSH (Termius recommended).
3. SSH lands inside a Docker gateway container.
4. SSH keys are configured with a forced `command="..."`.

## Documentation

- `ARCHITECTURE.md` (how the system is structured)
- `THREAT_MODEL.md` (what threats we considered)
- `SECURITY.md` (security policy and reporting)
5. The gateway calls Ollama over Docker’s internal network.
6. Ollama runs models locally on your host.

There is no public HTTP endpoint.  
There is no browser UI.  
There is no exposed router port.

---

## What Makes This Different

### Remote Without Being Internet-Facing

- Docker binds SSH only to the host’s Tailscale IP (100.x)
- No router port-forwarding required
- Only authenticated Tailscale devices can reach the service

### Controlled Capability

- SSH key authentication only
- Forced-command gateway (no interactive shell)
- Easy access revocation

### Local-First AI

- Models run via Ollama in Docker
- No external inference calls
- Works offline once connected to Tailscale

---

## Security Model (Realistic View)

This setup reduces attack surface, but nothing is unhackable.

### Risk Categories

- Compromised user device (stolen SSH key)
- Misconfiguration (binding to `0.0.0.0`)
- Vulnerable Docker images
- Bugs in gateway scripts
- Host OS vulnerabilities

### What This Design Avoids

- Public web endpoints
- Password authentication
- Direct host shell access
- Public cloud inference

Containers are isolation layers — not perfect security boundaries.

---

## Data & Privacy

Designed behavior:

- Inference runs locally
- No persistent chat storage required
- Optional log auto-purge (24h retention)

Caveats:

- Tailscale uses a cloud coordination plane (traffic is end-to-end encrypted)
- Termius may sync configs if enabled
- Mobile devices may store scrollback locally

---

## Quick Start

### 1. Start the Stack

```bash
docker compose up -d --build
```

### 2. Pull Lightweight Models

```bash
docker exec -it ollama ollama pull phi
docker exec -it ollama ollama pull dolphin-phi
docker exec -it ollama ollama list
```

Model catalog:
https://ollama.com/library

---

## Inviting Remote Users

This is invite-only.

1. Invite user to your Tailscale network
2. User generates SSH key (Termius recommended)
3. Add their public key to the gateway
4. They connect to your Tailscale IP
5. They land directly inside the chat program

They never get a Linux shell.

Access can be revoked instantly by removing their key.

---

## Emergency Shutdown

Stop the stack:

```bash
docker compose down
```

Stop all containers:

```bash
docker stop $(docker ps -q)
```

Remove a user:
- Delete their public SSH key
- Redeploy gateway container

---

## Managing Models

List installed models:

```bash
docker exec -it ollama ollama list
```

Add a model:

```bash
docker exec -it ollama ollama pull <model>
```

Create a custom assistant:

```bash
docker exec -it ollama sh -lc 'cat > /tmp/Modelfile.custom << "EOF"
FROM dolphin-phi:latest
SYSTEM """You are the company assistant. Be concise and professional."""
EOF'

docker exec -it ollama ollama create company-assistant -f /tmp/Modelfile.custom
```

---

## UI Philosophy

This is not a web app.

The gateway is a terminal-based chat program with:

- Margins and wrapping
- Clean formatting
- “thinking…” animation with elapsed time
- Model selection support (v2)

It is intentionally minimal and infrastructure-first.

---

## Repo Structure

- `docker-compose.yml` — Ollama + gateway
- `gateway/` — SSH + chat entrypoint
- `docs/` — onboarding & invite flow
- `scripts/` — operational helpers

---

## Use Cases

- Private internal AI assistant
- Founder-only remote LLM access
- Invite-only research tool
- Secure edge AI prototype
- Early-stage AI infrastructure lab

---

## Positioning

RemoteSantis is not a consumer app.  
It’s a private edge AI infrastructure template.

Remote does not have to mean cloud.  
You can own your inference layer.

---

## License

Choose a license before publishing (MIT / Apache-2.0 / etc).
