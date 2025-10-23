# Check If Server Is Running

The setup window closed - that's normal! Now let's check if the server is running.

## On EC2: Open New Command Prompt

1. Click the **Start menu** (Windows logo)

2. Type: **cmd**

3. Press **Enter**

4. A new Command Prompt window will open

## Check Server Status

Type this command:
```
pm2 status
```

Press Enter

## What You Should See:

### ✅ SUCCESS - Server Is Running:
```
┌─────┬────────────────────┬─────────┬─────────┬──────────┐
│ id  │ name               │ status  │ restart │ uptime   │
├─────┼────────────────────┼─────────┼─────────┼──────────┤
│ 0   │ matchmaking-server │ online  │ 0       │ 1m       │
└─────┴────────────────────┴─────────┴─────────┴──────────┘
```

If you see **"online"** - PERFECT! The server is running 24/7!

### ❌ IF YOU SEE "errored":
```
pm2 logs matchmaking-server
```
(This shows error details)

### ❌ IF YOU SEE EMPTY TABLE:
The server didn't start. Run the setup script again:
- Right-click `setup-ec2-server.bat` on Desktop
- "Run as administrator"

---

## AFTER You Confirm Server Is "online":

### NEXT STEP: Configure AWS Security Group

**On YOUR LOCAL PC** (not EC2):

1. Open browser → AWS Console

2. Go to **EC2** → **Instances**

3. Find instance: **i-03ef2c768872f8af0**

4. Click **Security** tab

5. Click **Security Group** link

6. Click **"Edit inbound rules"**

7. Click **"Add rule"**:
   - **Type**: Custom TCP
   - **Port**: 3001
   - **Source**: 0.0.0.0/0
   - **Description**: WebSocket server

8. Click **"Save rules"**

### FINAL STEP: Test Connection

On YOUR LOCAL PC, open Command Prompt:
```
curl http://13.59.157.124:3001
```

Should return: `Cannot GET /` (This is GOOD!)

## YOU'RE DONE! 🎉

Your multiplayer server will be running 24/7 at **13.59.157.124:3001**
