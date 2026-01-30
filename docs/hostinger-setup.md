# Hostinger OpenClaw Setup Guide

Complete guide for deploying OpenClaw on Hostinger VPS using their one-click Docker template.

> **Note:** Hostinger's catalog still uses the "Moltbot" name. Moltbot = OpenClaw.

## Prerequisites

- Hostinger VPS (any plan with Docker Manager support)
- Anthropic API key from [console.anthropic.com](https://console.anthropic.com)
- Discord bot token (optional) from [Discord Developer Portal](https://discord.com/developers/applications)

---

## Step 1: Deploy OpenClaw

### New VPS Purchase

1. Visit [hostinger.com/vps/docker/moltbot](https://www.hostinger.com/vps/docker/moltbot)
2. Select your plan:
   - **KVM 1** ($5.99/mo) — Good for personal use
   - **KVM 2** ($8.99/mo) — Better for multiple channels
3. Click **Deploy**
4. Complete purchase and wait for VPS provisioning

### Existing VPS

1. Log into [hPanel](https://hpanel.hostinger.com)
2. Select your VPS
3. Click **Docker Manager** in sidebar
4. If not installed, click **Install Docker Manager** (takes 2-3 min)
5. Go to **Catalog** tab
6. Search for "Moltbot"
7. Click the Moltbot card → **Deploy**

---

## Step 2: Configure Environment Variables

During deployment, you'll see a configuration screen:

| Variable | Required | Description |
|----------|----------|-------------|
| `MOLTBOT_GATEWAY_TOKEN` | Auto | Auto-generated. **Save this!** |
| `ANTHROPIC_API_KEY` | Yes | Your Claude API key |
| `OPENAI_API_KEY` | No | Optional OpenAI key |
| `DISCORD_BOT_TOKEN` | No | Discord bot token |
| `TELEGRAM_BOT_TOKEN` | No | Telegram bot token |

⚠️ **Important:** Copy the `MOLTBOT_GATEWAY_TOKEN` immediately. You'll need it to access the web interface.

Click **Deploy** to start the container.

---

## Step 3: Access OpenClaw Web Interface

1. In Docker Manager, go to your project
2. Note the **port number** (usually 18789)
3. Access: `http://YOUR_VPS_IP:PORT`
4. Enter your gateway token
5. Click **Connect**

You should see "Health: OK" in the top right.

---

## Step 4: Connect Discord

### Create Discord Bot (if not done)

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Click **New Application** → Name it → Create
3. Go to **Bot** tab → **Reset Token** → Copy token
4. Enable these **Privileged Gateway Intents**:
   - ✅ Message Content Intent
   - ✅ Server Members Intent
   - ✅ Presence Intent
5. Go to **OAuth2** → **URL Generator**:
   - Scopes: `bot`
   - Permissions: Send Messages, Read Message History, Add Reactions
6. Copy the invite URL and add bot to your server

### Configure in OpenClaw

1. Go to **Settings** → **Config**
2. Click **RAW** button (bottom of page)
3. Add or update the config:

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

4. Click **Apply** → **Update**
5. Go to **Overview** → **Restart Gateway**
6. Check **Channels** page — Discord should show "Running: Yes"

### Get Channel ID

1. In Discord, enable Developer Mode (Settings → App Settings → Advanced)
2. Right-click your channel → **Copy Channel ID**

---

## Step 5: Connect WhatsApp (Optional)

1. In RAW config, add:

```json
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+1234567890"],
      "groupPolicy": "disabled",
      "mediaMaxMb": 50
    }
  }
}
```

2. Replace the phone number with yours (international format)
3. Click **Apply** → **Update**
4. Go to **Channels** → Click **Show QR** under WhatsApp
5. On your phone: WhatsApp → Settings → Linked Devices → Link a Device
6. Scan the QR code

---

## Step 6: Customize Your Agent

### Via Web Interface

1. Go to **Config** → **Form** view
2. Navigate to agent settings
3. Adjust model, workspace settings

### Via Config File

Add to your RAW config:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-20250514"
      },
      "workspace": "/root/clawd"
    }
  }
}
```

---

## Troubleshooting

### "Container service disconnected"
- Wait 1-2 minutes for cold start
- Click **Restart Gateway** in Overview
- Check Docker Manager for container status

### Discord not connecting
- Verify bot token is correct
- Check that Privileged Intents are enabled
- Ensure bot is invited to your server
- Add `channelIds` to config

### Config changes not saving
- Click **Apply** first, then **Update**
- Restart Gateway after config changes

### WhatsApp QR not showing
- Restart Gateway
- Check Channels page for errors

---

## Security

See [Hostinger's security guide](https://www.hostinger.com/support/how-to-secure-and-harden-moltbot-security/) for:
- Firewall configuration
- Tailscale for secure access
- Rate limiting
- Allowlists for channels

---

## Updating OpenClaw

1. Go to Docker Manager → Your project
2. Click **Rebuild** or **Update**
3. Docker pulls the latest image
4. Container restarts automatically

---

## Useful Links

- [OpenClaw Website](https://openclaw.ai)
- [Hostinger Moltbot Page](https://www.hostinger.com/vps/docker/moltbot)
- [Discord Developer Portal](https://discord.com/developers/applications)
- [Anthropic Console](https://console.anthropic.com)
