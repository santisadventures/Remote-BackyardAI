# Architecture Overview – Remote-BackyardAI

## Design Goals

This architecture was designed to achieve:

- Remote access without public exposure
- Local-first AI inference
- Minimal attack surface
- Controlled user capability
- Clear trust boundaries

---

## High-Level Flow

User Device (Phone / Laptop)
        ↓
SSH over Tailscale (Private Mesh)
        ↓
Gateway Container (Forced Command)
        ↓
Docker Internal Network
        ↓
Ollama Container
        ↓
Local LLM Inference

---

## Component Breakdown

### 1. User Device

- Connects via SSH
- Authenticates using public key
- No password authentication
- No interactive shell

### 2. Tailscale

- Private encrypted mesh network
- Devices must be authenticated
- Service bound only to Tailscale IP (100.x)
- No public exposure

Trust assumption:
Device integrity and account security.

---

### 3. Gateway Container

Purpose:
- Entry point for all remote sessions

Responsibilities:
- Accept SSH connections
- Enforce forced-command execution
- Run chat interface only
- Prevent shell access

Security properties:
- Key-only authentication
- No privilege escalation
- Minimal installed packages

---

### 4. Docker Internal Network

- Isolated bridge network
- Only gateway can reach Ollama
- Ollama not exposed externally

Reduces lateral movement and service discovery risk.

---

### 5. Ollama Container

Purpose:
- Local LLM inference engine

Properties:
- No public port exposure
- Accessible only within Docker network
- Model files stored locally

Inference happens entirely on host hardware.

---

## Trust Boundaries

1. Public Internet (Untrusted)
2. Tailscale Mesh (Authenticated Private Network)
3. Docker Internal Network
4. Host Operating System

Each boundary reduces exposure scope.

---

## Why SSH Instead of HTTP?

SSH advantages:

- Mature authentication model
- Key-based access
- No exposed web server
- Smaller attack surface
- Easy revocation of access

HTTP-based APIs would increase exposure and require additional hardening layers.

---

## Why Forced Command?

The forced command ensures:

- No interactive shell
- No arbitrary command execution
- No filesystem browsing
- Chat-only environment

Principle applied: Least Privilege.

---

## Why Bind to Tailscale IP Only?

Binding to 0.0.0.0 would:

- Expose service on all interfaces
- Increase attack surface
- Allow scanning from public internet (if router exposed)

Binding to Tailscale IP ensures:

- Service reachable only inside private mesh
- No accidental public exposure

---

## Failure Scenarios

If a user device is compromised:
- SSH key may be abused
- Attacker gains chat access only
- No shell access available

If container escape occurs:
- Host compromise possible
- Mitigated by avoiding privileged containers

If Tailscale account is compromised:
- Network trust boundary collapses

---

## Scalability Considerations

This design is optimized for:

- Small team usage
- Personal infrastructure
- Controlled invite-only environments

For large-scale production:

- Add orchestration layer
- Introduce monitoring stack
- Implement rate limiting
- Add centralized auth system

---

## Architectural Philosophy

Remote does not require cloud.

Secure access does not require public exposure.

Complexity increases attack surface.

Clarity reduces risk.

