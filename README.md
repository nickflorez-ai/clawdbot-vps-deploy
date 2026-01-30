# OpenClaw VPS Deploy

Deploy [OpenClaw](https://openclaw.ai) personal AI assistant on a VPS.

> **Recommended:** Use Hostinger's one-click Docker deployment for the easiest setup.

---

## Option 1: Hostinger One-Click Deploy (Recommended)

The fastest way to get OpenClaw running. No command line required.

### New VPS

1. Go to [Hostinger Moltbot VPS](https://www.hostinger.com/vps/docker/moltbot) *(still uses Moltbot name)*
2. Select a plan ($5-6/mo works fine)
3. Click **Deploy** — Moltbot/OpenClaw is pre-selected
4. Complete purchase

During setup, configure:
- `MOLTBOT_GATEWAY_TOKEN` — Auto-generated (**save this!**)
- `ANTHROPIC_API_KEY` — Your Claude API key
- `OPENAI_API_KEY` — Optional

### Existing Hostinger VPS

1. Access **hPanel** → **Docker Manager**
2. Install Docker Manager if not installed (takes 2-3 min)
3. Go to **Catalog** → Search "Moltbot"
4. Click **Deploy**
5. Configure environment variables
6. Click **Deploy**

### Access OpenClaw

1. In Docker Manager, note the assigned port
2. Visit `http://your-vps-ip:port`
3. Enter your gateway token → **Connect**

### Connect Discord

1. Go to **Settings** → **Config** → **RAW**
2. Add Discord configuration:

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "YOUR_DISCORD_BOT_TOKEN",
      "channelIds": ["YOUR_CHANNEL_ID"],
      "dm": {
        "policy": "pairing"
      }
    }
  }
}
```

3. Click **Apply** → **Update**
4. Go to **Overview** → **Restart Gateway**
5. Check **Channels** — Discord should show as connected

See [docs/hostinger-setup.md](docs/hostinger-setup.md) for the complete guide.

---

## Option 2: Manual Ubuntu Setup

For non-Hostinger VPS or custom setups.

### Quick Start

SSH into your fresh Ubuntu 24.04 VPS:

```bash
curl -sL https://raw.githubusercontent.com/nickflorez-ai/openclaw-vps-deploy/main/setup.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/nickflorez-ai/openclaw-vps-deploy.git
cd openclaw-vps-deploy
./setup.sh
```

### What It Does

1. **Installs Node.js 22** via NodeSource
2. **Installs OpenClaw** globally via npm
3. **Installs QMD** for semantic search
4. **Creates workspace** at `/root/clawd/`
5. **Sets up collections** (sessions, memory, workspace)
6. **Configures cron jobs** for QMD indexing
7. **Installs systemd service** for OpenClaw gateway

### Post-Install

#### Add API Keys

```bash
cat > ~/.openclaw/.env << 'EOF'
ANTHROPIC_API_KEY=your-key-here
OPENAI_API_KEY=your-key-here
EOF
chmod 600 ~/.openclaw/.env
```

#### Configure Discord

Edit `~/.openclaw/config.json`:

```json
{
  "channels": {
    "discord": {
      "token": "YOUR_BOT_TOKEN",
      "guildId": "YOUR_GUILD_ID",
      "channelIds": ["CHANNEL_ID"],
      "dmPolicy": "disabled"
    }
  }
}
```

#### Customize Agent

Edit workspace files in `/root/clawd/`:
- `SOUL.md` — Agent personality
- `USER.md` — User info
- `AGENTS.md` — Behavioral instructions

#### Start Gateway

```bash
openclaw gateway start
openclaw status
```

---

## Templates

| Template | Description |
|----------|-------------|
| [Workspace](templates/workspace/) | User workspace repo template |
| [Config](templates/config.json) | Default OpenClaw configuration |

---

## Security

See [docs/security.md](docs/security.md) for VPS hardening:
- Tailscale-only SSH
- Discord channel allowlist
- Firewall configuration

---

## Directory Structure

```
/root/clawd/                    # Workspace
├── AGENTS.md                   # Agent behavior
├── SOUL.md                     # Agent personality
├── USER.md                     # User info
├── MEMORY.md                   # Long-term memory
├── memory/                     # Daily notes
└── logs/                       # Log files

~/.openclaw/
├── config.json                # Main config
├── .env                        # API keys
└── agents/main/sessions/       # Conversation history
```

---

## Maintenance

```bash
# Check status
openclaw status

# View logs
openclaw logs --follow

# Restart gateway
openclaw gateway restart

# Update OpenClaw
npm update -g openclaw
openclaw gateway restart
```

### Hostinger Docker Updates

In Docker Manager → Your project → **Rebuild**

---

## Resources

- [OpenClaw Website](https://openclaw.ai)
- [Hostinger Moltbot Guide](https://www.hostinger.com/support/how-to-install-moltbot-on-hostinger-vps/)
- [Hostinger Security Guide](https://www.hostinger.com/support/how-to-secure-and-harden-moltbot-security/)

---

## Requirements

### Hostinger Docker
- Any Hostinger VPS plan with Docker Manager

### Manual Setup
- Ubuntu 22.04 or 24.04
- Root access
- 2+ CPU cores, 4GB+ RAM recommended

---

## License

MIT
