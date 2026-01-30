# Google OAuth Setup (Gmail, Calendar, Drive)

Connect OpenClaw to Google Workspace services using the `gog` CLI tool.

---

## Overview

The `gog` CLI handles OAuth authentication for:
- **Gmail** — Read/send emails
- **Calendar** — View/create events
- **Drive** — Read/write files

Since the VPS has no browser, we use the `--manual` flag for headless authentication.

---

## Prerequisites

1. Google Cloud project with OAuth credentials
2. `gog` CLI installed on the VPS
3. SSH access to the VPS

---

## Step 1: Install gog CLI

SSH into your VPS and install `gog`:

```bash
# Download and install gog CLI (https://gogcli.sh)
curl -fsSL https://github.com/steipete/gogcli/releases/latest/download/gogcli_0.9.0_linux_amd64.tar.gz \
  | tar -xz -C /usr/local/bin
chmod +x /usr/local/bin/gog

# Verify installation
gog --version
```

---

## Step 2: Set Up Google Cloud OAuth Credentials

If you don't have OAuth credentials:

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project (or select existing)
3. Go to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth client ID**
5. Application type: **Desktop app**
6. Name it (e.g., "OpenClaw Assistant")
7. Download the JSON credentials file

### Configure gog with credentials

```bash
# Create gog config directory
mkdir -p ~/.gog

# Copy credentials (or create client config)
gog client add myapp --id=YOUR_CLIENT_ID --secret=YOUR_CLIENT_SECRET
```

---

## Step 3: Authenticate (Headless Flow)

Use the `--manual` flag for VPS authentication:

```bash
gog auth add user@company.com \
  --client=myapp \
  --services=gmail,calendar,drive \
  --force-consent \
  --manual
```

This outputs a URL like:
```
Open this URL in your browser:
https://accounts.google.com/o/oauth2/v2/auth?client_id=...

After authorization, paste the redirect URL here:
```

### Complete the flow:

1. **Copy the URL** from the terminal
2. **Open it in your local browser** (not on the VPS)
3. Sign in with the Google account
4. Grant permissions
5. You'll be redirected to a URL (may show "This site can't be reached")
6. **Copy the entire URL from your browser's address bar**
7. **Paste it back into the terminal**

The URL will look something like:
```
http://localhost:8080/callback?code=4/0AX4XfWh...
```

---

## Step 4: Verify Authentication

```bash
# List authenticated accounts
gog auth list

# Test Gmail access
gog gmail threads --account user@company.com --max 5

# Test Calendar access
gog calendar events --account user@company.com --max 5

# Test Drive access
gog drive list --account user@company.com --max 5
```

---

## Available Services

| Service | Flag | Description |
|---------|------|-------------|
| Gmail | `gmail` | Read/send emails |
| Calendar | `calendar` | View/manage events |
| Drive | `drive` | Read/write files |
| Contacts | `contacts` | Access contacts |
| Tasks | `tasks` | Task management |

Add multiple services in one command:
```bash
gog auth add user@example.com --services=gmail,calendar,drive,contacts
```

---

## Multiple Accounts

You can authenticate multiple Google accounts:

```bash
# Work account
gog auth add work@company.com --client=myapp --services=gmail,calendar --manual

# Personal account
gog auth add personal@gmail.com --client=myapp --services=gmail,drive --manual
```

---

## Troubleshooting

### "Invalid grant"
- Token may have expired — re-run `gog auth add` with `--force-consent`

### "Access denied"
- Verify the OAuth app has the required scopes
- Check that the user has granted permissions

### "Client not found"
- Run `gog client add` first to configure OAuth credentials

### Token refresh issues
```bash
# Force re-authentication
gog auth add user@company.com --client=myapp --services=gmail --force-consent --manual
```

---

## Security Notes

- Tokens are stored locally on the VPS
- Use `gog auth remove` to revoke access when needed
- Rotate OAuth credentials periodically
- Consider using a dedicated Google Workspace account for the AI

---

## Keyring Configuration (Required for VPS)

On headless servers, gog needs file-based token storage:

```bash
# Set keyring to file mode
gog auth keyring file

# Create secure password file
mkdir -p ~/.config/gog
openssl rand -base64 32 > ~/.config/gog/.keyring-password
chmod 600 ~/.config/gog/.keyring-password

# Add to shell profile
echo 'export GOG_KEYRING_PASSWORD="$(cat ~/.config/gog/.keyring-password)"' >> ~/.bashrc
source ~/.bashrc
```

Without this, gog commands will hang trying to access the system keyring.
