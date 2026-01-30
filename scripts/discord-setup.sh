#!/bin/bash
# Discord Auto-Setup Script
# Discovers all guilds/channels and updates OpenClaw config automatically

set -e

CONFIG_FILE="${HOME}/.openclaw/moltbot.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: Config file not found at $CONFIG_FILE"
  exit 1
fi

# Get bot token from config
DISCORD_BOT_TOKEN=$(jq -r '.channels.discord.token' "$CONFIG_FILE")

if [[ -z "$DISCORD_BOT_TOKEN" || "$DISCORD_BOT_TOKEN" == "null" ]]; then
  echo "Error: Discord bot token not found in config"
  exit 1
fi

echo "🔍 Discovering Discord servers and channels..."
echo ""

# Get all guilds
GUILDS=$(curl -s -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  "https://discord.com/api/v10/users/@me/guilds")

if echo "$GUILDS" | grep -q '"message"'; then
  echo "Error fetching guilds:"
  echo "$GUILDS" | jq .
  exit 1
fi

# Build guilds config object
GUILDS_CONFIG="{}"

for GUILD_ID in $(echo "$GUILDS" | jq -r '.[].id'); do
  GUILD_NAME=$(echo "$GUILDS" | jq -r ".[] | select(.id == \"$GUILD_ID\") | .name")
  echo "📁 Server: $GUILD_NAME ($GUILD_ID)"
  
  # Get channels for this guild
  CHANNELS=$(curl -s -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
    "https://discord.com/api/v10/guilds/$GUILD_ID/channels" 2>/dev/null)
  
  # Check if we got an error (missing access)
  if echo "$CHANNELS" | grep -q '"message"'; then
    echo "   ⚠️  No channel access (bot may need permissions)"
    continue
  fi
  
  # Build channels config for this guild
  CHANNELS_CONFIG="{}"
  
  for CHAN_ID in $(echo "$CHANNELS" | jq -r '.[] | select(.type == 0) | .id'); do
    CHAN_NAME=$(echo "$CHANNELS" | jq -r ".[] | select(.id == \"$CHAN_ID\") | .name")
    echo "   📝 #$CHAN_NAME ($CHAN_ID)"
    CHANNELS_CONFIG=$(echo "$CHANNELS_CONFIG" | jq --arg id "$CHAN_ID" '. + {($id): {"allow": true}}')
  done
  
  # Add guild to config
  GUILD_CONF=$(jq -n --argjson chans "$CHANNELS_CONFIG" '{"requireMention": false, "channels": $chans}')
  GUILDS_CONFIG=$(echo "$GUILDS_CONFIG" | jq --arg gid "$GUILD_ID" --argjson gconf "$GUILD_CONF" '. + {($gid): $gconf}')
done

echo ""
echo "📝 Updating config..."

# Update the config file
UPDATED_CONFIG=$(jq --argjson guilds "$GUILDS_CONFIG" '.channels.discord.guilds = $guilds' "$CONFIG_FILE")
echo "$UPDATED_CONFIG" > "$CONFIG_FILE"

echo "✅ Config updated!"
echo ""
echo "🔄 Restarting OpenClaw..."
systemctl restart openclaw
sleep 2

if systemctl is-active --quiet openclaw; then
  echo "✅ OpenClaw is running!"
else
  echo "❌ OpenClaw failed to start. Check: journalctl -u openclaw -n 20"
  exit 1
fi

echo ""
echo "🎉 Done! Bot will now respond to all channels in discovered servers."
