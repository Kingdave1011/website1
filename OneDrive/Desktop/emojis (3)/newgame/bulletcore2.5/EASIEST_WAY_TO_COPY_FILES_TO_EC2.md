# EASIEST WAY: Copy Files to EC2 (3 Simple Methods)

## METHOD 1: Copy/Paste Through RDP (EASIEST!)

This is the simplest way - just copy on your PC and paste on EC2:

### On LOCAL PC:
1. Open File Explorer
2. Go to: `C:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5`
3. Find these 2 files:
   - `matchmaking-server.cjs`
   - `setup-ec2-server.bat`
4. **Select both files** (Click first file, hold Ctrl, click second file)
5. **Copy them** (Right-click → Copy, or press Ctrl+C)

### On EC2 (in RDP window):
1. Click on the EC2 Desktop (anywhere empty)
2. **Paste** (Right-click → Paste, or press Ctrl+V)
3. The 2 files should appear on EC2 Desktop!

**If this works, STOP HERE and go to Step 2 below!**

---

## METHOD 2: Email to Yourself (If copy/paste doesn't work)

### On LOCAL PC:
1. Open your email (Gmail, Outlook, etc.)
2. Create new email to yourself
3. Attach the 2 files:
   - `matchmaking-server.cjs`
   - `setup-ec2-server.bat`
4. Send the email

### On EC2:
1. Open web browser (Edge or Chrome)
2. Go to your email
3. Download both attachments
4. Move them to Desktop

---

## METHOD 3: Use Google Drive/OneDrive

### On LOCAL PC:
1. Upload the 2 files to Google Drive or OneDrive
2. Get a share link (or just use your regular login)

### On EC2:
1. Open web browser
2. Go to Google Drive or OneDrive
3. Download the 2 files
4. Move them to Desktop

---

## AFTER FILES ARE ON EC2 DESKTOP:

### STEP 1: Run Setup Script
1. On EC2 Desktop, find `setup-ec2-server.bat`
2. **Right-click** → **"Run as administrator"**
3. Click **"Yes"** 
4. Wait 2-3 minutes for installation
5. You'll see: **"Server is now running 24/7!"**

### STEP 2: Verify It's Running
Open Command Prompt on EC2 and type:
```
pm2 status
```

Should show:
```
matchmaking-server | online
```

### STEP 3: Configure AWS Security Group (On LOCAL PC)
1. Go to AWS Console → EC2 → Instances
2. Click on instance `i-03ef2c768872f8af0`
3. Security tab → Edit inbound rules
4. Add rule:
   - Port: 3001
   - Source: 0.0.0.0/0
5. Save

### STEP 4: Test (On LOCAL PC)
```
curl http://13.59.157.124:3001
```

Should return: `Cannot GET /` (This is GOOD!)

---

## Which Method Should You Use?

- **Try Method 1 first** - it's the fastest
- **If Method 1 doesn't work**, use Method 2 (email)
- **Method 3 is backup** if you already use Google Drive/OneDrive

Once files are on EC2 Desktop, run the setup script as administrator!
