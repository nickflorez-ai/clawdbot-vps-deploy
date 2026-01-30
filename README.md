# OpenClaw VPS Deploy

Deploy [OpenClaw](https://openclaw.ai) personal AI assistant on Hostinger VPS in minutes.

---

## Deploy OpenClaw

### 1. Get a Hostinger VPS

1. Go to [Hostinger Moltbot VPS](https://www.hostinger.com/vps/docker/moltbot)
2. Select a plan ($5-6/mo)
3. Click **Deploy**
4. Complete purchase

### 2. Configure

During setup, you'll enter:

| Variable | Description |
|----------|-------------|
| `MOLTBOT_GATEWAY_TOKEN` | Auto-generated — **save this!** |
| `ANTHROPIC_API_KEY` | Your Claude API key from [console.anthropic.com](https://console.anthropic.com) |

### 3. Access OpenClaw

1. In hPanel → **Docker Manager** → note the port
2. Visit `http://your-vps-ip:port`
3. Enter your gateway token → **Connect**

You're in.

---

## Connect Discord

1. Create a bot at [Discord Developer Portal](https://discord.com/developers/applications)
2. Enable **Privileged Gateway Intents** (Message Content, Server Members, Presence)
3. Invite bot to your server
4. In OpenClaw: **Settings** → **Config** → **RAW**
5. Add:

```json
{
  "channels": {
    "discord": {
      "enabled": true,
      "token": "YOUR_DISCORD_BOT_TOKEN",
      "channelIds": ["YOUR_CHANNEL_ID"],
      "dm": { "policy": "pairing" }
    }
  }
}
```

6. **Apply** → **Update** → **Restart Gateway**

---

## Connect WhatsApp

1. In **Config** → **RAW**, add:

```json
{
  "channels": {
    "whatsapp": {
      "dmPolicy": "allowlist",
      "allowFrom": ["+1234567890"]
    }
  }
}
```

2. **Apply** → **Update**
3. **Channels** → **Show QR** → Scan with WhatsApp

---

## Customize Your Agent

Edit workspace files:
- `SOUL.md` — Personality
- `USER.md` — User info  
- `AGENTS.md` — Behavior

---

## Update OpenClaw

Docker Manager → Your project → **Rebuild**

---

## Resources

- [OpenClaw](https://openclaw.ai)
- [Hostinger Setup Guide](docs/hostinger-setup.md)
- [Security Guide](https://www.hostinger.com/support/how-to-secure-and-harden-moltbot-security/)

---

## License

MIT
