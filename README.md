# Remote-BackyardAI

**Private Remote AI Infrastructure – Security-Focused Design**

Remote-BackyardAI is a security-oriented infrastructure experiment designed to explore:

- Private remote access architecture
- SSH hardening strategies
- Attack surface reduction
- Container isolation boundaries
- Local-first AI inference
- Zero public exposure design

This project demonstrates defensive infrastructure thinking rather than feature development.

All model inference runs locally.  
Remote access is achieved without exposing public ports.

Tested stable on **Apple Silicon Mac (M4)**.

---

## Why This Exists (Startup-Friendly, Security-Aware)

This is a practical template you can pilot quickly, without building a full web app or exposing a public web endpoint.

It’s built to communicate well to a mixed audience:

- non-technical stakeholders (clear and simple access story)
- security-minded reviewers (explicit boundaries and controls)

---

## Design Objectives

1. Enable remote access without public internet exposure
2. Eliminate password-based authentication
3. Prevent interactive shell access
4. Restrict service binding scope
5. Minimize container responsibility
6. Clearly define trust boundaries

Security was considered first, convenience second.

---

## High-Level Architecture

User Device  
↓  
SSH over Tailscale (Private Mesh Network)  
↓  
Gateway Container (Forced Command Only)  
↓  
Docker Internal Network  
↓  
Ollama Container  
↓  
Local LLM Inference

### Architecture Diagram (At a Glance)

```text
[Phone / Laptop]
      |
  SSH over Tailscale (private mesh)
      |
[Gateway Container]  (forced command, no shell)
      |
 Docker internal network
      |
[Ollama Container]   (local inference)
      |
 [Local Models]
```

There is:

- No public HTTP endpoint
- No router port forwarding (recommended)
- No password authentication
- No interactive shell access

---

## Documentation (Security-First)

- `ARCHITECTURE.md` (system structure and boundaries)
- `THREAT_MODEL.md` (assets, threats, mitigations, residual risk)
- `SECURITY.md` (security policy and reporting)

---

## Security Decisions Explained

### Why SSH Instead of HTTP?

- Mature key-based authentication
- Smaller exposed surface
- Avoids common web server attack classes
- Simple revocation model (remove a key, access is gone)

### Why Forced Command?

SSH is configured with a forced command (`command="..."` in `authorized_keys`):

- Prevents shell access
- Prevents arbitrary command execution
- Limits capability to the chat program only

Principle applied: Least Privilege.

### Why Bind Only to the Tailscale IP?

Binding to `0.0.0.0` increases exposure.

Instead, bind the SSH port to your host’s Tailscale IP (100.x):

- Service is reachable only inside the private mesh
- No router port forwarding required
- Reduces scanning and remote exploitation risk

---

## Threat Model Summary

Assets considered:

- Host machine
- Docker daemon
- Gateway container
- Ollama container
- SSH keys
- Tailscale identity

Threats considered:

- Unauthorized remote access
- SSH key compromise
- Container escape / privilege escalation
- Misconfiguration exposure
- Supply chain vulnerabilities

See `THREAT_MODEL.md` for full analysis.

---

## Security Controls Implemented (Template Baseline)

- SSH key-only authentication (no passwords)
- Forced-command execution (no interactive shell)
- Docker internal networking (gateway can reach Ollama; Ollama not exposed externally)
- Tailscale-only exposure (recommended binding)
- Minimal container responsibility (single-purpose design)

---

## Known Limitations (Residual Risk)

This is not a production-hardened enterprise system.

Residual risks include:

- Compromised user device (stolen SSH key)
- Docker zero-day vulnerability
- Host OS compromise
- Tailscale account compromise

Security is risk reduction, not risk elimination.

---

## Production Hardening Roadmap

If deploying in production, consider:

- Rootless Docker
- Rate limiting / fail2ban-like controls
- Key rotation policy
- Mandatory MFA on Tailscale
- Signed container images
- Vulnerability scanning pipeline
- Centralized logging / SIEM integration
- Intrusion detection monitoring

---

## Getting Started (Copy/Paste)

1. Create config:

```bash
cp .env.example .env
# edit .env
```

2. Start the stack:

```bash
docker compose up -d --build
```

3. Download a few lightweight models:

```bash
docker exec -it ollama ollama pull phi
docker exec -it ollama ollama pull dolphin-phi
docker exec -it ollama ollama list
```

Model catalog: `https://ollama.com/library`

---

## Invite Users (Friends / Colleagues)

This is invite-only by design:

1. Invite the user into your Tailscale network.
2. The user generates an SSH key (Termius recommended).
3. Add their **public** key to a gateway instance.
4. They connect to your Tailscale IP and land directly in the chat program.

They never get a Linux shell.

Detailed onboarding:

- `docs/FRIENDS.md`

---

## Customizing Models (Modelfile Copies)

Create a copy of an existing model with your own system prompt:

```bash
docker exec -it ollama sh -lc 'cat > /tmp/Modelfile.custom << "EOF"
FROM dolphin-phi:latest
SYSTEM """You are the company assistant. Be concise and professional."""
EOF'

docker exec -it ollama ollama create company-assistant -f /tmp/Modelfile.custom
docker exec -it ollama ollama list | grep company-assistant
```

---

## Data & Privacy (What Is and Isn't Stored)

Designed behavior:

- Inference runs locally (Ollama in Docker).
- The gateway can be configured to avoid persisting chat logs.
- Optional log auto-purge (24h retention) can be enabled.

Caveats:

- Tailscale uses a cloud coordination plane (traffic is end-to-end encrypted).
- Termius may sync configuration data if enabled.
- Mobile devices may store scrollback locally (and backups may capture app data).

---

## Emergency Shutdown (Mac Terminal)

Stop this stack:

```bash
docker compose down
```

Stop all containers:

```bash
docker stop $(docker ps -q)
```

---

## Skills Demonstrated

This repository demonstrates practical experience with:

- Docker networking and isolation
- SSH hardening configuration
- Key-based authentication systems
- Forced command restrictions
- Network exposure control
- Threat modeling and risk analysis
- Secure architecture documentation
- Least privilege design

---

## License

Pick a license before publishing (MIT / Apache-2.0 / etc.). This template includes an MIT license stub.
