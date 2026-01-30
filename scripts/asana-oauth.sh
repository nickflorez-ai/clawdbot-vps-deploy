#!/bin/bash
# Asana OAuth CLI Helper
# Handles the OAuth flow for Asana API access

ASANA_CLIENT_ID="${ASANA_CLIENT_ID:-}"
ASANA_CLIENT_SECRET="${ASANA_CLIENT_SECRET:-}"
ASANA_REDIRECT_URI="urn:ietf:wg:oauth:2.0:oob"
CONFIG_DIR="${HOME}/.config/asana"
TOKEN_FILE="${CONFIG_DIR}/token.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: asana-oauth.sh <command>"
    echo ""
    echo "Commands:"
    echo "  auth     - Authenticate with Asana (OAuth flow)"
    echo "  refresh  - Refresh the access token"
    echo "  token    - Print current access token"
    echo "  status   - Check authentication status"
}

check_config() {
    if [[ -z "$ASANA_CLIENT_ID" || -z "$ASANA_CLIENT_SECRET" ]]; then
        echo -e "${RED}Error: ASANA_CLIENT_ID and ASANA_CLIENT_SECRET must be set${NC}"
        exit 1
    fi
}

auth() {
    check_config
    mkdir -p "$CONFIG_DIR"
    
    AUTH_URL="https://app.asana.com/-/oauth_authorize?client_id=${ASANA_CLIENT_ID}&redirect_uri=${ASANA_REDIRECT_URI}&response_type=code"
    
    echo -e "${YELLOW}Visit this URL to authorize:${NC}"
    echo ""
    echo "$AUTH_URL"
    echo ""
    echo -e "${YELLOW}After authorizing, Asana will display a code. Paste it here:${NC}"
    read -p "Authorization code: " AUTH_CODE
    
    [[ -z "$AUTH_CODE" ]] && { echo -e "${RED}No code provided.${NC}"; exit 1; }
    
    RESPONSE=$(curl -s -X POST "https://app.asana.com/-/oauth_token" \
        -d "grant_type=authorization_code" \
        -d "client_id=${ASANA_CLIENT_ID}" \
        -d "client_secret=${ASANA_CLIENT_SECRET}" \
        -d "redirect_uri=${ASANA_REDIRECT_URI}" \
        -d "code=${AUTH_CODE}")
    
    if echo "$RESPONSE" | grep -q '"error"'; then
        echo -e "${RED}Error:${NC}" && echo "$RESPONSE" | jq . && exit 1
    fi
    
    echo "$RESPONSE" > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    echo -e "${GREEN}Authentication successful!${NC}"
}

refresh() {
    check_config
    [[ ! -f "$TOKEN_FILE" ]] && { echo -e "${RED}No token file. Run 'auth' first.${NC}"; exit 1; }
    
    REFRESH_TOKEN=$(jq -r '.refresh_token' "$TOKEN_FILE")
    [[ -z "$REFRESH_TOKEN" || "$REFRESH_TOKEN" == "null" ]] && { echo -e "${RED}No refresh token.${NC}"; exit 1; }
    
    RESPONSE=$(curl -s -X POST "https://app.asana.com/-/oauth_token" \
        -d "grant_type=refresh_token" \
        -d "client_id=${ASANA_CLIENT_ID}" \
        -d "client_secret=${ASANA_CLIENT_SECRET}" \
        -d "refresh_token=${REFRESH_TOKEN}")
    
    if echo "$RESPONSE" | grep -q '"error"'; then
        echo -e "${RED}Error:${NC}" && echo "$RESPONSE" | jq . && exit 1
    fi
    
    echo "$RESPONSE" | jq --arg rt "$REFRESH_TOKEN" '. + {refresh_token: $rt}' > "$TOKEN_FILE"
    chmod 600 "$TOKEN_FILE"
    echo -e "${GREEN}Token refreshed!${NC}"
}

get_token() {
    [[ ! -f "$TOKEN_FILE" ]] && { echo "Not authenticated" >&2; exit 1; }
    jq -r '.access_token' "$TOKEN_FILE"
}

status() {
    [[ ! -f "$TOKEN_FILE" ]] && { echo -e "${YELLOW}Not authenticated${NC}"; exit 0; }
    
    ACCESS_TOKEN=$(jq -r '.access_token' "$TOKEN_FILE")
    RESPONSE=$(curl -s "https://app.asana.com/api/1.0/users/me" -H "Authorization: Bearer ${ACCESS_TOKEN}")
    
    if echo "$RESPONSE" | grep -q '"errors"'; then
        echo -e "${YELLOW}Token expired. Run: asana-oauth.sh refresh${NC}"
    else
        NAME=$(echo "$RESPONSE" | jq -r '.data.name')
        EMAIL=$(echo "$RESPONSE" | jq -r '.data.email')
        echo -e "${GREEN}Authenticated as:${NC} ${NAME} (${EMAIL})"
    fi
}

case "${1:-}" in
    auth) auth ;;
    refresh) refresh ;;
    token) get_token ;;
    status) status ;;
    *) usage; exit 1 ;;
esac
