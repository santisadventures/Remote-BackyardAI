# Security Policy – Remote-BackyardAI

## Security Philosophy

Remote-BackyardAI is designed around one core principle:

Reduce exposure. Limit capability. Control access.

This project prioritizes:

- Private networking over public exposure
- SSH key authentication over passwords
- Forced command execution over shell access
- Minimal service surface area
- Clear infrastructure boundaries

This is not a zero-risk system. It is a risk-reduced architecture.

---

## Supported Deployment Model

The secure configuration assumes:

- Tailscale private mesh network
- No router port forwarding
- SSH key-only authentication
- Forced-command gateway (no interactive shell)
- Docker services not bound to 0.0.0.0
- No password authentication enabled

If deployed differently, the security guarantees change.

---

## Secure Configuration Requirements

### SSH

- Password authentication must be disabled
- Root login must be disabled
- Only public key authentication allowed
- Each user must have their own key
- Keys must be removable without redeploying entire stack

### Network

- SSH must bind only to Tailscale IP (100.x)
- Do not expose service on 0.0.0.0
- Do not open router ports
- Do not expose Ollama externally

### Docker

- Avoid privileged containers
- Avoid mounting sensitive host directories
- Do not expose Docker socket inside containers
- Keep images updated

---

## Reporting a Vulnerability

If you discover a security issue:

1. Do not publicly disclose immediately.
2. Open a private issue or contact the repository owner.
3. Provide:
   - Description of the issue
   - Steps to reproduce
   - Potential impact
   - Suggested mitigation (if available)

Security issues will be reviewed and addressed responsibly.

---

## Known Security Limitations

- Containers are not perfect isolation boundaries
- Compromised SSH keys grant chat-level access
- Host OS compromise bypasses container protections
- Tailscale account compromise affects network trust

---

## Recommended Production Hardening

If deploying in a production environment, consider:

- Rootless Docker
- Fail2ban or connection rate limiting
- Mandatory key rotation policy
- MFA enforcement on Tailscale
- Network segmentation (VLAN separation)
- Centralized logging pipeline (SIEM)
- Vulnerability scanning for container images
- Signed Docker images
- Intrusion detection monitoring

---

## Scope of Responsibility

This repository provides a template architecture.

Security of deployment depends on:

- Host configuration
- Key management practices
- Network setup
- Update hygiene
- Operational discipline

Misconfiguration can significantly increase risk.

---

## Final Note

Security is a process, not a state.

This project demonstrates defensive architectural thinking,
not absolute protection.

