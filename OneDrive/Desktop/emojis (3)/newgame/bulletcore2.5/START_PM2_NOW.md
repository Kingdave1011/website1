# START PM2 SERVER NOW - ON EC2

## RUN THESE COMMANDS ON EC2 (in Remote Desktop window):

Open Command Prompt on EC2 and run these commands one at a time:

### Step 1: Navigate to GameServers
```
cd C:\GameServers
```

### Step 2: Start the server with PM2
```
pm2 start matchmaking-server.cjs --name matchmaking-server
```

You should see output like:
```
[PM2] Starting C:\GameServers\matchmaking-server.cjs in fork_mode
[PM2] Done
```

### Step 3: Save PM2 configuration
```
pm2 save
```

### Step 4: Configure auto-start on boot
```
pm2 startup
```

### Step 5: Verify it's running
```
pm2 status
```

**You should see:**
```
┌─────┬────────────────────┬─────────┬─────────┬──────────┐
│ id  │ name               │ status  │ restart │ uptime   │
├─────┼────────────────────┼─────────┼─────────┼──────────┤
│ 0   │ matchmaking-server │ online  │ 0       │ 5s       │
└─────┴────────────────────┴─────────┴─────────┴──────────┘
```

## FINAL TEST

After PM2 shows "online", test the connection on YOUR LOCAL PC:
```
curl http://13.59.157.124:3001
```

**Expected result:**
```
Cannot GET /
```

**This is SUCCESS!** Your multiplayer server is now live!

---

## What This Does

- PM2 starts your matchmaking server on port 3001
- PM2 will automatically restart it if it crashes
- PM2 will automatically start it when EC2 boots
- The server runs 24/7 in the background

## Your Multiplayer Server is Ready!

Players can now connect at: **ws://13.59.157.124:3001**
