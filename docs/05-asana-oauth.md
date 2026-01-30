# Asana OAuth Integration

Connect OpenClaw to Asana using OAuth for secure task and project management.

---

## Overview

OpenClaw integrates with Asana to:
- View and create tasks
- Manage projects
- Track goals
- Search across workspaces

**Authentication:** OAuth (not Personal Access Tokens)

---

## Prerequisites

1. Asana OAuth app created (admin does this once)
3. SSH access to the VPS

---

## Step 1: Create Asana OAuth App (Admin Only)

**This is done once for all executives.**

2. Click **Create new app**
3. Fill in:
   - **App name:** "Cardinal AI Collaborator"
   - **Redirect URI:** `urn:ietf:wg:oauth:2.0:oob` (for CLI apps)
4. Note the **Client ID** and **Client Secret**

---

## Step 2: Install OAuth Script


```bash
# Download the script
```

---

## Step 3: Configure OAuth Credentials

Add the OAuth app credentials to the VPS environment:

```bash
# Add to shell profile
echo 'export ASANA_CLIENT_ID="your-client-id"' >> ~/.bashrc
echo 'export ASANA_CLIENT_SECRET="your-client-secret"' >> ~/.bashrc
source ~/.bashrc
```

---

## Step 4: Authenticate (Executive Does This)

Run the OAuth flow:

```bash
```

**What happens:**
1. Script prints an Asana authorization URL
2. Executive opens the URL in their browser
3. Executive clicks **Allow** to grant access
4. Asana displays an authorization code
5. Executive pastes the code back into the terminal
6. Script exchanges code for access/refresh tokens

---

## Step 5: Verify Authentication

```bash
```

Should show: `Authenticated as: [Name] ([email])`

---

## Using the Token

Get the current access token for API calls:

```bash

# Test API access
curl -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
```

---

## Token Refresh

Access tokens expire after 1 hour. Refresh them:

```bash
```

The script automatically preserves the refresh token.

---

## Script Commands

| Command | Description |
|---------|-------------|

---

## Common Operations

Once authenticated, OpenClaw can perform these Asana operations:

### Tasks
- List tasks in a project
- Create new tasks
- Update task status
- Add comments

### Projects
- List projects in workspace
- Create projects
- View project details

### Search
- Search tasks across workspaces
- Filter by assignee, due date, etc.

---

## Troubleshooting

### "ASANA_CLIENT_ID must be set"
```bash
source ~/.bashrc  # Reload environment
```

### "Token expired"
```bash
```

### "Invalid grant" on refresh
The refresh token has expired or been revoked. Run:
```bash
```

---

## Security Notes

- OAuth credentials are shared (same app for all execs)
- Each exec's tokens are stored separately on their VPS
- Never commit tokens to git
- Refresh tokens can be revoked from Asana settings
