# Security Policy

*Mandatory security requirements for all AI assistant deployments.*

---

## Core Principles

1. **Isolation** — Each AI runs on its own VPS. No shared resources.
2. **Allowlist** — AI only responds to authorized user(s).
3. **No Public Access** — VPS is only reachable via Tailscale VPN.
4. **Audit Trail** — All actions logged and traceable.

---

## Telegram Security Configuration

Every bot MUST have this configuration:

```json
{
  "channels": {
    "telegram": {
      "dmPolicy": "allowlist",
      "allowFrom": ["<USER_TELEGRAM_ID>"],
      "groupPolicy": "disabled"
    }
  }
}
```

### What This Means

| Setting | Value | Effect |
|---------|-------|--------|
| `dmPolicy` | `allowlist` | Only listed IDs can message the bot |
| `allowFrom` | `["123456789"]` | The user's Telegram ID |
| `groupPolicy` | `disabled` | Bot cannot be added to any groups |

### Security Guarantees

- ✅ **Only the authorized user** can communicate with their bot
- ✅ **No group chat access** — prevents data leakage
- ✅ **Silent rejection** — unauthorized users get no response
- ✅ **Isolated memory** — each bot has separate VPS and data

---

## How to Get Telegram ID

Users should message `@userinfobot` on Telegram:

1. Open Telegram
2. Search for `@userinfobot`
3. Tap **Start**
4. Bot replies with your ID:
   ```
   Your user ID: 123456789
   ```
5. Use this number in the `allowFrom` configuration

---

## VPS Security Hardening

Every VPS must be hardened before deployment.

### 1. Lock Down SSH

Keys only, no passwords, no root login.

```bash
sudo nano /etc/ssh/sshd_config

# Set explicitly:
PasswordAuthentication no
PermitRootLogin no

# Test and reload
sudo sshd -t && sudo systemctl reload ssh
```

### 2. Default-Deny Firewall

Block everything incoming by default.

```bash
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
```

### 3. Brute-Force Protection

Auto-ban IPs after failed login attempts.

```bash
sudo apt install fail2ban -y
sudo systemctl enable --now fail2ban
```

### 4. Install Tailscale

Your private VPN mesh network.

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

### 5. SSH Only via Tailscale

No more public SSH exposure.

```bash
# Verify Tailscale is working first!
tailscale status

# Allow SSH only from Tailscale network
sudo ufw allow from 100.64.0.0/10 to any port 22 proto tcp

# Remove public SSH access
sudo ufw delete allow OpenSSH
```

### 6. Web Ports Private Too

App only accessible from your devices.

```bash
sudo ufw allow from 100.64.0.0/10 to any port 443 proto tcp
sudo ufw allow from 100.64.0.0/10 to any port 80 proto tcp
```

### 7. Fix Credential Permissions

Don't leave secrets world-readable.

```bash
chmod 700 ~/.clawdbot
chmod 600 ~/.clawdbot/.env
chmod 600 ~/.clawdbot/clawdbot.json
```

---

## Verification Checklist

```bash
# Check firewall rules
sudo ufw status

# Check listening ports
ss -tulnp

# Check Tailscale status
tailscale status

# Check Clawdbot health
clawdbot doctor

# Verify bot is locked to user
clawdbot config get channels.telegram
```

---

## Quick Reference

| Step | Command | Purpose |
|------|---------|---------|
| SSH lockdown | `sshd_config` edits | No password auth |
| Firewall | `ufw enable` | Default deny |
| Fail2ban | `apt install fail2ban` | Brute-force protection |
| Tailscale | `tailscale up` | Private VPN mesh |
| SSH restrict | `ufw allow from 100.64.0.0/10` | Tailscale-only SSH |
| Permissions | `chmod 600` | Protect secrets |

---

## Incident Response

If an unauthorized access attempt is detected:

1. Bot ignores the message (no response)
2. Attempt is logged
3. Repeated attempts trigger alert
4. Team investigates source

---

*Security is non-negotiable. Every bot MUST be locked to its user's Telegram ID before activation.* 🔒
