# 🔧 Fix "Remote Desktop can't connect" Error

## The Error You're Seeing:

```
Remote Desktop can't connect to the remote computer for one of these reasons:
1) Remote access to the server is not enabled
2) The remote computer is turned off  
3) The remote computer is not available on the network
```

---

## Quick Fixes (Try In Order):

### Fix 1: Check if EC2 Instance is Running

**Go to AWS Console:**

1. Open: https://console.aws.amazon.com/ec2
2. Click "Instances" in left sidebar
3. Find instance: `i-0b45bbd8105d85e19`
4. Check "Instance state"

**If it shows "Stopped":**
- Select the instance
- Click "Instance state" → "Start instance"
- Wait 2-3 minutes for it to boot
- Try RDP again

**If it shows "Running":**
- Continue to Fix 2

---

### Fix 2: Check Security Group (RDP Port 3389)

**In EC2 Console:**

1. Select your instance `i-0b45bbd8105d85e19`
2. Click "Security" tab
3. Click on the security group link
4. Click "Edit inbound rules"

**Make sure you have this rule:**
```
Type: RDP
Protocol: TCP  
Port: 3389
Source: 0.0.0.0/0
Description: Remote Desktop
```

**If missing, add it:**
- Click "Add rule"
- Type: RDP
- Port range: 3389
- Source: My IP (or 0.0.0.0/0 for anywhere)
- Save rules

---

### Fix 3: Get Correct Public IP

**Your EC2's public IP might have changed after reboot!**

1. Go to EC2 Console
2. Select instance `i-0b45bbd8105d85e19`
3. Look at "Public IPv4 address" 
4. Copy the NEW IP address
5. Try RDP with the NEW IP

**Current IP (might be old):** 18.116.64.173

---

### Fix 4: Get/Reset EC2 Password

**If you don't have the password or forgot it:**

1. In EC2 Console, select instance
2. Click "Actions" → "Security" → "Get Windows password"
3. Upload your `.pem` key file (ec2-key.pem)
4. Click "Decrypt password"
5. Copy the password
6. Try RDP again with:
   - Username: `Administrator`
   - Password: (decrypted password)

---

### Fix 5: Alternative - Use AWS Systems Manager (Session Manager)

**If RDP still won't work, try SSM:**

**In AWS Console:**
1. Go to Systems Manager (not EC2)
2. Click "Session Manager" in left sidebar
3. Click "Start session"
4. Select your instance `i-0b45bbd8105d85e19`
5. Click "Start session"

**Once connected:**
```powershell
# Switch to PowerShell
powershell

# Then install PM2 and start server:
npm install -g pm2
cd C:\gameservers
pm2 start matchmaking-server.cjs --name "multiplayer-server"
pm2 save
pm2 status
```

---

## Common Causes & Solutions:

### Cause 1: Instance is Stopped
**Solution:** Start instance in EC2 console

### Cause 2: IP Address Changed
**Solution:** Use new IP from EC2 console

### Cause 3: Security Group Blocks RDP
**Solution:** Add port 3389 inbound rule

### Cause 4: Windows Firewall
**Solution:** Use SSM Session Manager instead

### Cause 5: Password Unknown
**Solution:** Decrypt password in EC2 console

---

## Alternative: Run Server via SSM (Easier!)

**You don't actually need RDP!** Use Systems Manager:

**Steps:**
1. AWS Console → Systems Manager
2. Session Manager → Start session
3. Select your instance
4. Run these commands in the browser terminal:

```powershell
powershell
npm install -g pm2
cd C:\gameservers
pm2 start matchmaking-server.cjs --name "multiplayer-server"
pm2 save
```

No RDP password needed!

---

## After Connecting:

**Once you're connected (RDP or SSM):**

```powershell
# Install PM2
npm install -g pm2

# Start server
cd C:\gameservers
pm2 start matchmaking-server.cjs --name "multiplayer-server"
pm2 save

# Check status
pm2 status

# Verify port
netstat -ano | findstr :3001
```

Then test: https://hideoutads.online/multiplayer-lobby.html

---

## Quick Summary:

1. **Check instance is Running** in EC2 console
2. **Get current public IP** (might have changed)
3. **Check Security Group** has port 3389 open
4. **Get/reset password** if needed
5. **Or use SSM Session Manager** (easier, no password needed!)

---

*Try SSM Session Manager first - it's easier than RDP!*
