# Google Chat Setup (OAuth Flow)

This guide sets up Google Chat as a messaging channel for OpenClaw using OAuth (not service account).

**Requires:** Google Workspace Admin access + GCP Console access

---

## Part 1: GCP Setup (Workspace Admin / CISO)

### Step 1: Enable the Google Chat API

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select the existing project: **cardinal-ai-collaborator**
3. Navigate to **APIs & Services** → **Library**
4. Search for **Google Chat API**
5. Click **Enable**

### Step 2: OAuth Credentials

**We reuse the existing OAuth client** — no new client needed.

Just add the redirect URI for your deployment to the existing client:

| Deployment | Redirect URI |
|------------|--------------|
| Nick's Mac mini | `https://ottos-mac-mini.tail72a244.ts.net/oauth/callback/googlechat` |
| Barry VPS | `https://srv1073915.tail72a244.ts.net/oauth/callback/googlechat` |
| Erica VPS | `https://srv1297409-erica.tail72a244.ts.net/oauth/callback/googlechat` |
| Joe VPS | `https://srv1297411-joe.tail72a244.ts.net/oauth/callback/googlechat` |
| New VPS | `https://<tailscale-hostname>.tail72a244.ts.net/oauth/callback/googlechat` |

**To add a redirect URI:**
1. Go to **APIs & Services** → **Credentials**
2. Click on the existing OAuth 2.0 Client ID
3. Under **Authorized redirect URIs**, click **+ Add URI**
4. Paste the appropriate URI from the table above
5. Click **Save**

### Step 3: Add Chat Scopes to Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Click **Edit App**
3. Go to **Scopes** → **Add or Remove Scopes**
4. Add these scopes:
   ```
   https://www.googleapis.com/auth/chat.messages
   https://www.googleapis.com/auth/chat.spaces.readonly
   ```
5. Click **Save and Continue**

> ⚠️ **Note:** Do NOT add `chat.bot` — that's for service accounts only.

### Step 4: Configure the Chat App

1. In GCP Console, go to **Google Chat API** → **Configuration**
2. Fill in:

   | Field | Value |
   |-------|-------|
   | App name | `OpenClaw` (or exec name + "AI") |
   | Avatar URL | *(optional)* |
   | Description | `AI Collaborator for Cardinal Financial` |
   | Interactive features | ✅ **Enabled** |
   | App URL | *(leave blank — HTTP push mode)* |

3. Under **Functionality**:
   - ✅ Receive 1:1 messages
   - ✅ Join spaces and group conversations

4. Click **Save**

---

## Part 2: OpenClaw Configuration

### Credentials

Stored in **1Password:** `Cardinal Google OAuth` (Otto vault)

Or locally: `~/.secrets/cardinal-oauth.json`

### Step 1: Add Configuration

Edit your OpenClaw config (`~/.openclaw/openclaw.json` or via Control UI → Config → RAW):

```json
{
  "plugins": {
    "entries": {
      "googlechat": {
        "enabled": true,
        "config": {
          "clientId": "<from 1Password or cardinal-oauth.json>",
          "clientSecret": "<from 1Password or cardinal-oauth.json>",
          "redirectUri": "https://<your-tailscale-hostname>.tail72a244.ts.net/oauth/callback/googlechat",
          "dmPolicy": "allowlist",
          "allowFrom": ["your.email@cardinalfinancial.com"]
        }
      }
    }
  }
}
```

**Config options:**

| Field | Description |
|-------|-------------|
| `clientId` | OAuth Client ID (same for all deployments) |
| `clientSecret` | OAuth Client Secret (same for all deployments) |
| `redirectUri` | Must match GCP exactly — use your Tailscale hostname |
| `dmPolicy` | `"allowlist"` (recommended) or `"pairing"` or `"open"` |
| `allowFrom` | Array of allowed email addresses |

### Step 2: Restart Gateway

```bash
openclaw gateway restart
```

### Step 3: Complete OAuth Consent

1. Check OpenClaw logs or Control UI for an OAuth URL
2. Open the URL in your browser
3. Sign in with your Cardinal Google account
4. Grant the requested permissions
5. You'll be redirected back — tokens are now cached

### Step 4: Test

1. Open **Google Chat** (Gmail sidebar or chat.google.com)
2. Click **+ Start a chat**
3. Search for your app name (e.g., "OpenClaw")
4. Start a conversation
5. Send: `hello`

If it responds — you're live! ✅

---

## Troubleshooting

### "App not found in Chat"
- Ensure the Chat App is published (Part 1, Step 4)
- Ensure you're signed into the correct Workspace account
- Wait 1-2 minutes for propagation

### OAuth fails / redirect error
- Verify redirect URI matches **exactly** (including trailing slashes)
- Verify your Tailscale hostname is correct
- Check that OAuth consent screen is published

### "Insufficient permissions"
- Add the required scopes to OAuth consent screen
- Re-authenticate (tokens may be stale)

### Bot doesn't respond
- Check `openclaw logs --follow` for errors
- Verify `googlechat` plugin is enabled in config
- Ensure `allowFrom` includes your email

---

## Security Notes

- **Internal only:** Only Cardinal Workspace users can access
- **OAuth tokens:** Stored locally in `~/.openclaw/` — treat as sensitive
- **No service account:** Uses user-delegated OAuth — more secure, requires consent
- **Tailscale only:** All redirect URIs use Tailscale hostnames — no public exposure

---

## Quick Reference

| Item | Value |
|------|-------|
| GCP Project | cardinal-ai-collaborator |
| Tailscale Domain | tail72a244.ts.net |
| 1Password Item | Cardinal Google OAuth (Otto vault) |
