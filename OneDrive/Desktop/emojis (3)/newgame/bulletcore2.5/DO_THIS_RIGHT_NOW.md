# DO THIS RIGHT NOW - Step by Step

You're testing the server but it's not deployed yet. Follow these exact steps:

## STEP 1: Copy Files (On EC2 via RDP)

**You're already on EC2 in RDP, right?**

1. **On EC2**, open File Explorer
2. Type this in the address bar: `\\tsclient\c\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5`
3. Press Enter
4. Find these 2 files:
   - `matchmaking-server.cjs`
   - `setup-ec2-server.bat`
5. **Copy them** (Ctrl+C)
6. Go to EC2 Desktop
7. **Paste them** (Ctrl+V)

**ALTERNATIVE METHOD** (if above doesn't work):
1. On LOCAL PC: Email the 2 files to yourself
2. On EC2: Open email and download the 2 files to Desktop

## STEP 2: Run Setup (On EC2)

1. On EC2 Desktop, find `setup-ec2-server.bat`
2. **Right-click** → **"Run as administrator"**
3. Click **"Yes"**
4. Wait for installation (2-3 minutes)
5. You'll see: "Server is now running 24/7!"

## STEP 3: Verify (On EC2)

Open Command Prompt on EC2 and type:
```
pm2 status
```

Should show: `matchmaking-server | online`

## STEP 4: Configure Security Group (On LOCAL PC)

1. Open AWS Console in browser
2. Go to EC2 → Instances
3. Find instance `i-03ef2c768872f8af0`
4. Click Security tab
5. Click Security Group link
6. Click "Edit inbound rules"
7. Click "Add rule":
   - Type: Custom TCP
   - Port: 3001
   - Source: 0.0.0.0/0
8. Save rules

## STEP 5: Test Again (On LOCAL PC)

```
curl http://13.59.157.124:3001
```

Should return: `Cannot GET /` (this is GOOD!)

---

## Can't Access Files from LOCAL PC to EC2?

If you can't copy files directly, here's an easy alternative:

**Option A: Use Email**
1. On LOCAL PC: Attach the 2 files to an email and send to yourself
2. On EC2: Open email and download files to Desktop

**Option B: Use GitHub**
1. On LOCAL PC: Commit and push the 2 files to GitHub
2. On EC2: Clone or download from GitHub

**Option C: Use Pastebin (for matchmaking-server.cjs)**
1. On LOCAL PC: Open matchmaking-server.cjs, copy contents
2. Go to pastebin.com, paste, create paste
3. On EC2: Open the pastebin link, copy code
4. Create new file on EC2, paste contents

Which option works best for you?
