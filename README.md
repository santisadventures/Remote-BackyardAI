# Santisplayground (Template Repo)

**A private, phone-friendly AI chat experience that runs on your own machine, using local models.**

Santisplayground is a scrappy, startup-friendly way to give yourself (and invited teammates) access to offline-capable LLMs without building a full web app. It’s intentionally designed to be easy to explain to non-technical stakeholders while still respecting real security constraints.

Tested stable on **Apple Silicon Mac (M4)**.

## What You Get (In Plain English)

- A local AI “chat assistant” you can reach from a phone.
- Models run on your machine, not on a hosted SaaS.
- Access is private: only people you invite can connect.
- No Linux shell access: users are forced into the chat program.
- A clean “terminal UI” with margins, line wrapping, and a “thinking…..... + seconds” indicator.

## Why Teams Like This (HR-Friendly, Security-Aware)

- **Privacy first:** model inference is local; the gateway can be configured to avoid server-side chat logs.
- **Access you can actually manage:** users authenticate with SSH keys; you can revoke access fast.
- **Not publicly exposed by default:** bind to a private Tailscale IP (100.x) so it’s not Internet-facing.
- **Easy to pilot:** works with common tooling (Docker, Tailscale, Termius).

## How It Works (60-Second Overview)

1. **Tailscale** creates a private network between your host and your users’ devices.
2. Users connect with **Termius** (SSH client) to a single port on the host’s Tailscale IP.
3. SSH lands inside a Docker container called the **gateway**.
4. The SSH key is configured with a forced `command="..."`, so users run the chat program, not a shell.
5. The gateway calls **Ollama** (also in Docker) over an internal network to get responses from local models.

## “Are We Exposing the Mac to Attacks?”

In the recommended setup:

- You do **not** open any ports on your router.
- Docker binds the SSH port only to the host’s **Tailscale IP** (100.x), not to `0.0.0.0`.
- Only authenticated devices in your Tailscale network can reach the port.
- Even if someone connects, they don’t get a shell. They only get the chat program.

Reality check:

- No system is “unhackable”. This template reduces risk by limiting exposure and capability.
- Misconfigurations (port-forwarding, privileged containers, mounting sensitive host paths, exposing Docker socket) can increase risk.

## Security Disclaimer (What Can Still Go Wrong)

Even with Tailscale-only exposure and a forced-command gateway, realistic risk categories include:

- **Credential/device compromise:** if a user’s phone is compromised, their SSH key can be abused.
- **Misconfiguration:** binding to `0.0.0.0`, port-forwarding a router, or enabling password auth increases exposure.
- **Supply chain / image risk:** Docker images and dependencies can have vulnerabilities.
- **Gateway bugs:** any bug in the gateway script or SSH server could be exploited.
- **Host risk:** Docker Desktop and the host OS still matter; containers are not a perfect security boundary.

This project is built to reduce risk, not eliminate it.

## Data Handling and Privacy (What’s Stored Where)

Designed behavior:

- The models and inference run locally (Ollama in Docker).
- The gateway can be configured to avoid persisting chat logs and to purge container logs older than 24h.

Important caveats:

- Tailscale uses a cloud control plane for coordination/authentication, but traffic is end-to-end encrypted.
- Termius can sync configuration data if you enable sync. For maximum privacy, disable sync features.
- The phone may keep scrollback locally, and mobile backups may capture app data.

## Emergency Stop (Shut Everything Down)

If you ever need to immediately disable the system, run this on the Mac host:

```bash
cd /path/to/this/repo
docker compose down
```

If you want to stop *all* running containers on the machine:

```bash
docker stop $(docker ps -q)
```

To remove access for a specific user, delete their gateway container/volume (or remove their public key) and redeploy.

## Getting Started (Copy/Paste)

1. Start the stack:

```bash
docker compose up -d --build
```

2. Download a few lightweight models:

```bash
docker exec -it ollama ollama pull phi
docker exec -it ollama ollama pull dolphin-phi
docker exec -it ollama ollama list
```

Model catalog:

- [Ollama library](https://ollama.com/library)

## Inviting Colleagues as Users (Tailscale + Termius)

This is a “invite-only” approach:

1. Invite the person to your Tailscale network.
2. They generate an SSH key in Termius.
3. You add their public key to a gateway instance.
4. They connect to your Tailscale IP and are dropped into the chat program.

Detailed steps:

- `docs/FRIENDS.md`

Optional:

- Termius can be protected with biometrics (Face ID/Touch ID) if your app/version supports it.

## Adding and Managing Models (Your “Library”)

The gateway v2 lists installed models from:

```text
http://ollama:11434/api/tags
```

Add a model:

```bash
docker exec -it ollama ollama pull <model>
docker exec -it ollama ollama list
```

## Customizing How a Model Responds (Modelfile Copies)

Create a “copy” of a model with a new name and your own instructions:

```bash
docker exec -it ollama sh -lc 'cat > /tmp/Modelfile.mycopy << "EOF"
FROM dolphin-phi:latest
SYSTEM """You are the company assistant. Be concise. Use a professional tone."""
# PARAMETER temperature 0.6
EOF'

docker exec -it ollama ollama create my-company-assistant -f /tmp/Modelfile.mycopy
docker exec -it ollama ollama list | grep my-company-assistant
```

Inspect a model’s configuration:

```bash
docker exec -it ollama ollama show dolphin-phi:latest --modelfile
```

## Operational Hygiene: Auto-Purge Logs and Scheduled Restarts

Log purge (default 24h):

- `RETENTION_MINUTES=1440`
- `PRIVACY_SWEEP_SECONDS=3600`

Optional periodic restarts (example for macOS `launchd`):

- `scripts/com.santisplayground.restart.plist`
- `scripts/restart.sh`

To publish this as a clean GitHub repo (without leaking secrets), see:

- `PUBLISHING.md`

## The Phone-Friendly Chat “UI”

The gateway is a terminal program (not a web UI), but it’s formatted to feel like a chat:

- margins and wrapping to avoid edge-to-edge text
- “thinking….....” animation and elapsed seconds per response

See the code:

- `gateway/chat.sh`
- `gateway/chat_v2.sh`

## Repo Layout

- `docker-compose.yml`: runs Ollama + gateway
- `gateway/`: gateway image and scripts
- `docs/`: non-technical onboarding
- `scripts/`: optional operational helpers

## License

Pick a license before publishing (MIT/Apache-2.0/etc.). This template includes an MIT license stub; replace as needed.
