# Threat Model – Remote-BackyardAI

## Purpose

This project was built as a security-focused experiment to explore:

- Private remote access design
- SSH hardening
- Attack surface reduction
- Container isolation boundaries
- Zero public exposure architecture

---

## Assets

The following assets are considered sensitive or critical:

- Host machine (macOS)
- Docker daemon
- Gateway container (SSH entrypoint)
- Ollama container (LLM inference)
- SSH private/public keys
- Tailscale network identity
- Model files stored locally

---

## Trust Boundaries

1. Public Internet (untrusted)
2. Tailscale private mesh (trusted but device-dependent)
3. Docker internal network
4. Host operating system

---

## Threats Considered

### 1. Unauthorized Remote Access
- Attempted brute force SSH
- Credential stuffing
- Port scanning

### 2. SSH Key Compromise
- Stolen device
- Extracted private key
- Key reuse

### 3. Container Escape
- Exploiting Docker vulnerability
- Privilege escalation from container to host

### 4. Misconfiguration
- Binding services to 0.0.0.0
- Router port forwarding
- Password authentication enabled

### 5. Supply Chain Risk
- Vulnerable Docker base image
- Compromised dependency

---

## Mitigations Implemented

- SSH key-only authentication
- Password authentication disabled
- Forced-command configuration (no interactive shell)
- Service bound to Tailscale IP (100.x), not 0.0.0.0
- No router port forwarding
- Internal Docker network between gateway and Ollama
- Minimal container responsibility (single-purpose design)

---

## Residual Risk

- Compromised user device (stolen SSH key)
- Zero-day Docker vulnerability
- Host OS compromise
- Tailscale account compromise

No system is fully secure. This design reduces exposure and limits blast radius.

---

## Future Hardening Improvements

If deployed in production, the following would be added:

- Rootless Docker
- Fail2ban inside gateway container
- SSH key rotation policy
- Rate limiting
- Network segmentation
- Centralized logging / SIEM integration
- Vulnerability scanning pipeline
- Signed container images
- Mandatory multi-factor authentication for Tailscale

---

## Security Philosophy

Remote does not require public exposure.

This project prioritizes:

- Least privilege
- Reduced attack surface
- Controlled access
- Infrastructure clarity
- Practical security over theoretical perfection

