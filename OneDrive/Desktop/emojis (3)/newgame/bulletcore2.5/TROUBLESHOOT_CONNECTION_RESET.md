# Troubleshooting: Connection Reset Error

## What Happened
The curl test returned: **"Connection was reset"**

This means the connection reaches EC2 but is being blocked. Let's fix it!

## Step 1: Check if Security Group Rule is Added

1. Go to AWS Console → EC2 → Instances
2. Click instance: **i-03ef2c768872f8af0**
3. Click **Security** tab
4. Click Security Group: **sg-0e8e5d86ead4bc7ea**
5. Click **"Inbound rules"** tab
6. Look for a rule with **Port 3001**

**If port 3001 is NOT there:**
1. Click **"Edit inbound rules"**
2. Click **"Add rule"**
3. Set:
   - Type: Custom TCP
   - Port: 3001
   - Source: 0.0.0.0/0
4. Click **"Save rules"**

## Step 2: Verify Server is Running on EC2

**RDP back to EC2** and run:
```
pm2 status
```

**Expected**: `matchmaking-server | online`

**If NOT online:**
```
pm2 logs matchmaking-server
```
Check for errors

**To restart:**
```
pm2 restart matchmaking-server
```

**If PM2 doesn't show anything:**
```
cd C:\GameServers
node matchmaking-server.cjs
```
(This runs it manually to test - press Ctrl+C to stop, then use PM2 again)

## Step 3: Verify Windows Firewall on EC2

On EC2, open Command Prompt as admin:
```
netsh advfirewall firewall show rule name="WebSocket Port 3001"
```

**If rule doesn't exist**, add it:
```
netsh advfirewall firewall add rule name="WebSocket Port 3001" dir=in action=allow protocol=TCP localport=3001
```

## Step 4: Test Again

After making changes, test again:
```
curl http://13.59.157.124:3001
```

**Expected**: `Cannot GET /` (This is GOOD!)

## Quick Checklist

- [ ] AWS Security Group has port 3001 rule
- [ ] PM2 shows server as "online" on EC2
- [ ] Windows Firewall on EC2 allows port 3001
- [ ] Curl test returns "Cannot GET /"

## Most Likely Issue

**The AWS Security Group rule probably isn't added yet.**

Go to AWS Console and add the inbound rule for port 3001!
