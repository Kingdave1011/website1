# How to Edit Security Group - Step by Step

Looking at your screenshot, you're on the right page! Follow these exact steps:

## STEP 1: Click on Security Group ID

1. You can see the Security Group ID: **sg-0e8e5d86ead4bc7ea**

2. **Click on that blue link**: `sg-0e8e5d86ead4bc7ea`

3. This will take you to the Security Group details page

## STEP 2: Edit Inbound Rules

Once you click the Security Group ID, you'll see a new page with:

1. Look for **"Inbound rules"** tab near the top

2. Click the **"Inbound rules"** tab

3. You'll see a button: **"Edit inbound rules"**

4. Click **"Edit inbound rules"**

## STEP 3: Add Port 3001 Rule

1. Click **"Add rule"** button

2. Fill in:
   - **Type**: Custom TCP
   - **Port range**: 3001
   - **Source**: Anywhere-IPv4 (0.0.0.0/0)
   - **Description**: WebSocket matchmaking server

3. Click **"Save rules"**

## STEP 4: Test Connection

On your LOCAL PC, open Command Prompt:
```
curl http://13.59.157.124:3001
```

Should return: `Cannot GET /`

That's it! Your server will be accessible to players worldwide!
