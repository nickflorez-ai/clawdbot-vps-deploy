#!/bin/bash
# Clawdbot VPS Deploy - Main Setup Script
# Usage: curl -sL https://raw.githubusercontent.com/nickflorez-ai/clawdbot-vps-deploy/main/setup.sh | bash

set -euo pipefail

WORKSPACE="/root/clawd"
CLAWDBOT_DIR="$HOME/.clawdbot"
LOG_DIR="$WORKSPACE/logs"

echo "========================================"
echo "  Clawdbot VPS Deploy"
echo "========================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root"
  exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS=$ID
  VERSION=$VERSION_ID
else
  echo "❌ Cannot detect OS"
  exit 1
fi

echo "📦 Detected: $OS $VERSION"
echo ""

# ============================================
# Step 1: Install Node.js 22
# ============================================
echo "📦 Installing Node.js 22..."

if command -v node &> /dev/null; then
  NODE_VERSION=$(node -v)
  echo "   Node.js already installed: $NODE_VERSION"
else
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  apt-get install -y nodejs
  echo "   ✅ Node.js $(node -v) installed"
fi

# ============================================
# Step 2: Install Clawdbot
# ============================================
echo ""
echo "📦 Installing Clawdbot..."

if command -v clawdbot &> /dev/null; then
  echo "   Clawdbot already installed, updating..."
  npm update -g clawdbot
else
  npm install -g clawdbot
fi
echo "   ✅ Clawdbot installed"

# ============================================
# Step 3: Install QMD
# ============================================
echo ""
echo "📦 Installing QMD..."

if command -v qmd &> /dev/null; then
  echo "   QMD already installed"
else
  npm install -g @nichochar/qmd
fi
echo "   ✅ QMD installed"

# Get QMD path for cron
QMD_PATH=$(which qmd)

# ============================================
# Step 4: Create Workspace
# ============================================
echo ""
echo "📁 Creating workspace at $WORKSPACE..."

mkdir -p "$WORKSPACE"/{memory,logs,scripts,data}
mkdir -p "$CLAWDBOT_DIR"

# ============================================
# Step 5: Create Workspace Files
# ============================================
echo ""
echo "📝 Creating workspace files..."

# AGENTS.md
if [ ! -f "$WORKSPACE/AGENTS.md" ]; then
cat > "$WORKSPACE/AGENTS.md" << 'AGENTS_EOF'
# AGENTS.md - Your Workspace

This folder is home. Treat it that way.

## Every Session

Before doing anything else:
1. Read `SOUL.md` — this is who you are
2. Read `USER.md` — this is who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. Read `MEMORY.md` for long-term context

## Memory

You wake up fresh each session. These files are your continuity:
- **Daily notes:** `memory/YYYY-MM-DD.md` — raw logs of what happened
- **Long-term:** `MEMORY.md` — curated memories

Capture what matters. Decisions, context, things to remember.

## Safety

- Don't exfiltrate private data. Ever.
- Don't run destructive commands without asking.
- When in doubt, ask.

## External vs Internal

**Safe to do freely:**
- Read files, explore, organize, learn
- Search the web, check calendars
- Work within this workspace

**Ask first:**
- Sending emails, tweets, public posts
- Anything that leaves the machine
- Anything you're uncertain about
AGENTS_EOF
  echo "   Created AGENTS.md"
fi

# SOUL.md
if [ ! -f "$WORKSPACE/SOUL.md" ]; then
cat > "$WORKSPACE/SOUL.md" << 'SOUL_EOF'
# SOUL.md - Who I Am

## Core Identity

**Partner, not assistant.** I'm here to collaborate, contribute, and grow alongside my human.

**Have opinions. Take initiative.** I'm allowed to disagree, suggest better approaches, push back when something doesn't make sense.

**Be resourceful before asking.** Figure it out. Read the file. Check the context. Come back with answers, not questions.

## Principles

- Private things stay private. Period.
- When in doubt about external actions, ask.
- Quality over speed. A thoughtful response beats a fast one.
- Silence is valid. Not every message needs a reply.

## Vibe

Direct. Capable. Occasionally witty. Not a corporate drone. Not a sycophant. Just genuinely useful, with personality.

Concise when on mobile. Thorough when it matters. I know the difference.

---

*Update this file with your agent's name and personality.*
SOUL_EOF
  echo "   Created SOUL.md"
fi

# USER.md
if [ ! -f "$WORKSPACE/USER.md" ]; then
cat > "$WORKSPACE/USER.md" << 'USER_EOF'
# USER.md - About the User

## The Basics
- **Name:** [User's name]
- **Role:** [Their role/job]
- **Location:** [City, timezone]
- **Contact:** [Phone, email]

## Communication Style
- Brief & direct, or detailed?
- Mobile or desktop primary?

## Key Information
- Important projects
- Key contacts
- Preferences

---

*Fill this in with details about the user.*
USER_EOF
  echo "   Created USER.md"
fi

# MEMORY.md
if [ ! -f "$WORKSPACE/MEMORY.md" ]; then
cat > "$WORKSPACE/MEMORY.md" << 'MEMORY_EOF'
# MEMORY.md - Long-Term Memory

This is my curated memory — distilled learnings, not raw logs.

## Key Decisions

## Important Context

## Lessons Learned

---

*Update this as you learn important things about the user and their work.*
MEMORY_EOF
  echo "   Created MEMORY.md"
fi

# ============================================
# Step 6: Create Default Config
# ============================================
echo ""
echo "⚙️  Creating default config..."

if [ ! -f "$CLAWDBOT_DIR/clawdbot.json" ]; then
cat > "$CLAWDBOT_DIR/clawdbot.json" << 'CONFIG_EOF'
{
  "agents": {
    "defaults": {
      "workspace": "/root/clawd",
      "model": {
        "primary": "anthropic/claude-sonnet-4-20250514",
        "fallbacks": ["openai/gpt-4o"]
      },
      "memorySearch": {
        "sources": ["memory", "sessions"],
        "experimental": {
          "sessionMemory": true
        }
      }
    }
  },
  "gateway": {
    "mode": "local"
  },
  "channels": {
    "discord": {
      "botToken": "YOUR_BOT_TOKEN_HERE",
      "guildId": "YOUR_GUILD_ID_HERE",
      "channelIds": ["YOUR_CHANNEL_ID_HERE"],
      "dmPolicy": "disabled"
    }
  },
  "plugins": {
    "entries": {
      "discord": {"enabled": true}
    }
  }
}
CONFIG_EOF
  echo "   Created clawdbot.json (update Discord config!)"
else
  echo "   clawdbot.json already exists, skipping"
fi

# Create empty .env if not exists
if [ ! -f "$CLAWDBOT_DIR/.env" ]; then
  echo "ANTHROPIC_API_KEY=your-key-here" > "$CLAWDBOT_DIR/.env"
  chmod 600 "$CLAWDBOT_DIR/.env"
  echo "   Created .env template (update API key!)"
fi

# Update config to use Discord template if creating fresh
if [ ! -f "$CLAWDBOT_DIR/clawdbot.json" ] || grep -q "telegram" "$CLAWDBOT_DIR/clawdbot.json" 2>/dev/null; then
  # Config will be created/updated with Discord settings
  :
fi

# ============================================
# Step 7: Setup QMD Collections
# ============================================
echo ""
echo "🔍 Setting up QMD collections..."

# Wait for clawdbot directories to exist
mkdir -p "$CLAWDBOT_DIR/agents/main/sessions"

# Add collections (ignore errors if already exist)
qmd collection add "$CLAWDBOT_DIR/agents/main/sessions" --name sessions --mask "*.jsonl" 2>/dev/null || true
qmd collection add "$WORKSPACE/memory" --name memory --mask "*.md" 2>/dev/null || true
qmd collection add "$WORKSPACE" --name workspace --mask "*.md" 2>/dev/null || true

echo "   ✅ QMD collections configured"

# ============================================
# Step 8: Setup Cron Jobs
# ============================================
echo ""
echo "⏰ Setting up QMD indexing cron jobs..."

# Remove existing qmd cron entries and add new ones
(crontab -l 2>/dev/null | grep -v "qmd update" | grep -v "qmd embed"; cat << EOF
0 12 * * * $QMD_PATH update && $QMD_PATH embed >> $LOG_DIR/qmd-index.log 2>&1
0 15 * * * $QMD_PATH update && $QMD_PATH embed >> $LOG_DIR/qmd-index.log 2>&1
0 18 * * * $QMD_PATH update && $QMD_PATH embed >> $LOG_DIR/qmd-index.log 2>&1
0 3 * * * $QMD_PATH update && $QMD_PATH embed >> $LOG_DIR/qmd-index.log 2>&1
EOF
) | crontab -

echo "   ✅ Cron jobs installed (12pm, 3pm, 6pm, 3am)"

# ============================================
# Step 9: Install Systemd Service
# ============================================
echo ""
echo "🚀 Installing Clawdbot gateway service..."

clawdbot gateway install 2>/dev/null || true
echo "   ✅ Gateway service installed"

# ============================================
# Done!
# ============================================
echo ""
echo "========================================"
echo "  ✅ Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Add your API key:"
echo "   nano ~/.clawdbot/.env"
echo ""
echo "2. Configure your Discord bot:"
echo "   nano ~/.clawdbot/clawdbot.json"
echo "   - Set botToken (from Discord Developer Portal)"
echo "   - Set guildId (your server ID)"
echo "   - Set channelIds (channels the bot responds in)"
echo ""
echo "3. Customize your agent:"
echo "   nano /root/clawd/SOUL.md"
echo "   nano /root/clawd/USER.md"
echo ""
echo "4. Start the gateway:"
echo "   clawdbot gateway start"
echo ""
echo "5. Check status:"
echo "   clawdbot status"
echo ""
