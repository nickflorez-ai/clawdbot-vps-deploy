# Clawdbot VPS Deploy

One-command deployment of Clawdbot on a fresh Ubuntu VPS.

**📖 [Read the Vision](VISION.md)** — Why AI assistants matter

**🔒 [Security Policy](docs/security.md)** — Mandatory security requirements

**📋 [Governance Model](docs/governance.md)** — How AI work flows through organizations

---

## Quick Start

SSH into your fresh Ubuntu 24.04 VPS and run:

```bash
curl -sL https://raw.githubusercontent.com/nickflorez-ai/clawdbot-vps-deploy/main/setup.sh | bash
```

Or clone and run:

```bash
git clone https://github.com/nickflorez-ai/clawdbot-vps-deploy.git
cd clawdbot-vps-deploy
./setup.sh
```

## What It Does

1. **Installs Node.js 22** via NodeSource
2. **Installs Clawdbot** globally via npm
3. **Installs QMD** for semantic search
4. **Installs Beautiful Mermaid** for diagram rendering (SVG/ASCII)
5. **Creates workspace** at `/root/clawd/`
6. **Sets up collections** (sessions, memory, workspace)
7. **Configures cron jobs** for QMD indexing (12pm, 3pm, 6pm, 3am)
8. **Installs systemd service** for Clawdbot gateway

## Post-Install Steps

After running the setup script:

### 1. Add API Keys

```bash
# Create .env with your API keys
cat > ~/.clawdbot/.env << 'EOF'
ANTHROPIC_API_KEY=your-key-here
OPENAI_API_KEY=your-key-here  # Optional fallback
EOF
chmod 600 ~/.clawdbot/.env
```

### 2. Configure Telegram Bot

Edit `~/.clawdbot/clawdbot.json` and add your bot token:

```json
{
  "channels": {
    "telegram": {
      "botToken": "YOUR_BOT_TOKEN",
      "dmPolicy": "pairing",
      "allowFrom": [],
      "groupPolicy": "disabled"
    }
  }
}
```

### 3. Customize Agent

Edit the workspace files in `/root/clawd/`:
- `SOUL.md` - Agent personality and name
- `USER.md` - Info about the user
- `AGENTS.md` - Behavioral instructions

### 4. Start the Gateway

```bash
clawdbot gateway start
clawdbot status
```

### 5. Pair with Telegram

Message your bot on Telegram. Complete the pairing process.

## Directory Structure

```
/root/clawd/                    # Workspace
├── AGENTS.md                   # Agent behavior
├── SOUL.md                     # Agent personality
├── USER.md                     # User info
├── MEMORY.md                   # Long-term memory
├── memory/                     # Daily notes
├── logs/                       # Log files
└── scripts/                    # Utility scripts

~/.clawdbot/
├── clawdbot.json              # Main config
├── .env                        # API keys
└── agents/main/sessions/       # Conversation history
```

## Cron Jobs

The setup installs these cron jobs for QMD indexing:

| Time | Command |
|------|---------|
| 12:00 PM | `qmd update && qmd embed` |
| 3:00 PM | `qmd update && qmd embed` |
| 6:00 PM | `qmd update && qmd embed` |
| 3:00 AM | `qmd update && qmd embed` |

Logs: `/root/clawd/logs/qmd-index.log`

## Maintenance

```bash
# Check status
clawdbot status
clawdbot gateway status

# View logs
clawdbot logs --follow

# Restart gateway
clawdbot gateway restart

# Update Clawdbot
npm update -g clawdbot
clawdbot gateway restart

# Manual QMD reindex
qmd update && qmd embed
```

## Requirements

- Ubuntu 22.04 or 24.04
- Root access
- 2+ CPU cores, 4GB+ RAM recommended
- Internet access

## License

MIT
