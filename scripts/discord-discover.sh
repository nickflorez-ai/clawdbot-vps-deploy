#!/bin/bash
# Discord Server/Channel Discovery Script
# Uses the bot token to discover all guilds and channels

# Get token from environment or OpenClaw config
if [[ -z "$DISCORD_BOT_TOKEN" ]]; then
  # Try to extract from moltbot.json
  if [[ -f ~/.openclaw/moltbot.json ]]; then
    DISCORD_BOT_TOKEN=$(jq -r '.channels.discord.token' ~/.openclaw/moltbot.json)
  fi
fi

if [[ -z "$DISCORD_BOT_TOKEN" || "$DISCORD_BOT_TOKEN" == "null" ]]; then
  echo "Error: DISCORD_BOT_TOKEN not set and not found in config"
  exit 1
fi

echo "=== Discord Bot Guilds & Channels ==="
echo ""

# Get all guilds the bot is in
GUILDS=$(curl -s -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  "https://discord.com/api/v10/users/@me/guilds")

if echo "$GUILDS" | grep -q '"message"'; then
  echo "Error fetching guilds:"
  echo "$GUILDS" | jq .
  exit 1
fi

# Process each guild
echo "$GUILDS" | jq -r '.[] | "\(.id) \(.name)"' | while read -r GUILD_ID GUILD_NAME; do
  echo "Server: $GUILD_NAME"
  echo "  Server ID: $GUILD_ID"
  echo "  Channels:"
  
  # Get channels for this guild
  CHANNELS=$(curl -s -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
    "https://discord.com/api/v10/guilds/$GUILD_ID/channels")
  
  # Filter to text channels (type 0) and list them
  echo "$CHANNELS" | jq -r '.[] | select(.type == 0) | "    - \(.name): \(.id)"' 2>/dev/null
  echo ""
done

echo "=== Config Snippet ==="
echo "Add this to your moltbot.json under channels.discord:"
echo ""

# Generate config JSON
echo '"guilds": {'
FIRST_GUILD=true
echo "$GUILDS" | jq -r '.[].id' | while read -r GUILD_ID; do
  CHANNELS=$(curl -s -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
    "https://discord.com/api/v10/guilds/$GUILD_ID/channels")
  
  if [[ "$FIRST_GUILD" != "true" ]]; then
    echo ","
  fi
  FIRST_GUILD=false
  
  echo "  \"$GUILD_ID\": {"
  echo "    \"requireMention\": false,"
  echo "    \"channels\": {"
  
  FIRST_CHAN=true
  echo "$CHANNELS" | jq -r '.[] | select(.type == 0) | .id' | while read -r CHAN_ID; do
    if [[ "$FIRST_CHAN" != "true" ]]; then
      echo ","
    fi
    FIRST_CHAN=false
    echo -n "      \"$CHAN_ID\": { \"allow\": true }"
  done
  echo ""
  echo "    }"
  echo -n "  }"
done
echo ""
echo "}"
