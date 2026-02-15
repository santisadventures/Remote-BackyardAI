# Invite Users (Friends / Colleagues)

This guide explains how to invite people as "users" while keeping access private and easy to manage.

## Overview

Each friend gets:

- a Tailscale device on your tailnet
- a Termius SSH key (private key stays on their phone)
- an SSH account that is forced into the chat program (no shell)
- optionally their own gateway container + port for isolation

## Step 1: Invite Them to Tailscale

1. Open the Tailscale admin console.
2. Invite your friend (email) or add them to a group.
3. Confirm their device shows up in your tailnet.

## Step 2: Termius Setup (User Side)

1. Install Termius.
2. Create a key: ED25519.
3. Copy and send you the **public** key only.
4. Optional: enable biometric / App Lock in Termius settings if available.

## Step 3: Add Them as a User (Recommended: One Container Per User)

Create a new gateway service per friend with:

- its own port (2222, 2223, 2224, ...)
- its own `/config` volume
- `PUBLIC_KEY` set to `command="...chat-v2"... ssh-ed25519 ...`

Example:

```bash
export TS_IP="$(tailscale ip -4)"
docker compose up -d --build
```

## Step 4: They Connect (User Side)

Host: your server Tailscale IPv4
Port: the friend-specific port (e.g., 2223)
Username: the friend-specific username (e.g., friend2)

## Removing a Friend

1. Remove their device from Tailscale (admin console).
2. Stop and remove their gateway container and volume:

```bash
docker rm -f gateway-friend2
docker volume rm gateway-friend2-config
```
