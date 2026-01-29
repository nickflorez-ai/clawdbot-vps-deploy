# Security Policy

*Mandatory security requirements for all AI assistant deployments.*

---

## Core Principles

1. **Isolation** — Each AI runs on its own VPS. No shared resources.
2. **Channel Allowlist** — AI only responds in authorized Discord channels.
3. **No Public Access** — VPS is only reachable via Tailscale VPN.
4. **Audit Trail** — All actions logged and traceable.

---

## Discord Security Configuration

Every bot MUST have this configuration:

```json
{
  "channels": {
    "discord": {
      "botToken": "YOUR_BOT_TOKEN",
      "guildId": "YOUR_GUILD_ID",
      "channelIds": ["AUTHORIZED_CHANNEL_ID"],
      "dmPolicy": "disabled"
    }
  }
}
```

### What This Means

| Setting | Value | Effect |
|---------|-------|--------|
| `guildId` | `"123456789"` | Bot only operates in this server |
| `channelIds` | `["987654321"]` | Bot only responds in these channels |
| `dmPolicy` | `"disabled"` | Bot ignores all direct messages |

### Security Guarantees

- ✅ **Channel isolation** — Bot only responds in explicitly listed channels
- ✅ **No DM access** — Prevents unauthorized private communication
- ✅ **Guild-locked** — Cannot be used in other Discord servers
- ✅ **Isolated memory** — Each bot has separate VPS and data
- ✅ **Permission-based access** — Discord roles control who can access channels

---

## Discord Channel Setup

Each executive gets a private channel:

1. Create a category (e.g., "Executives")
2. Create a private channel per user (e.g., `#barry`, `#erica`)
3. Set channel permissions:
   - Only the executive + admins can view
   - Bot has Send Messages + Read Message History
4. Use that channel's ID in the agent's `channelIds` config

### How to Get Discord IDs

Enable Developer Mode in Discord:
1. User Settings → App Settings → Advanced
2. Enable **Developer Mode**
3. Right-click any channel/server → **Copy ID**

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

# Verify bot is locked to channel
clawdbot config get channels.discord
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

If unauthorized access is attempted:

1. Bot ignores messages outside configured channels
2. Attempts are logged
3. Discord audit log captures all activity
4. Team investigates source

---

*Security is non-negotiable. Every bot MUST be locked to its designated channel before activation.* 🔒
