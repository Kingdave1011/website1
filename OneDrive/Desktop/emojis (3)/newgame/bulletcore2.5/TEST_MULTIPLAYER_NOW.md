# ✅ Test Multiplayer Server After Reboot

## The EC2 instance has been rebooted. Let's verify everything is working!

---

## Step 1: Wait for EC2 to Fully Start (2-3 minutes)

The instance needs time to:
- Boot Windows Server
- Start SSM Agent
- Initialize network services
- **This takes about 2-3 minutes**

---

## Step 2: Check if SSM Agent is Online

### Go to AWS Console:
1. Open: https://console.aws.amazon.com/ec2
2. Click on "Instances" in left sidebar
3. Find instance: `i-0b45bbd8105d85e19`
4. Look at "Instance state" - should show **"Running"** (green)

### Check SSM Agent Status:
1. In AWS Console, go to **Systems Manager**
2. Click **Fleet Manager** in left sidebar
3. Look for your instance `i-0b45bbd8105d85e19`
4. Status should show **"Online"** (not "Offline" or "Connection Lost")

---

## Step 3: Test Multiplayer Connection from Your Browser

### Quick Test:
1. Open your game website: **https://hideoutads.online/multiplayer-lobby.html**
2. Look at the **"Server Status"** indicator
3. It should show:
   - ✅ **"Server Status: Online"** (in green)
   - Player count (e.g., "0/32 Players")
   - Ping display (e.g., "5ms")

### If Server Shows Offline:
**The PM2 server may not have started automatically.**

You'll need to connect via RDP and start it manually:

1. **Connect via Remote Desktop:**
   - Computer: `18.116.64.173`
   - Username: `Administrator`
   - Password: (your EC2 password)

2. **Open PowerShell as Administrator**

3. **Check PM2 Status:**
   ```powershell
   pm2 status
   ```

4. **If Server Not Running, Start It:**
   ```powershell
   cd C:\gameservers
   pm2 start matchmaking-server.cjs --name "multiplayer-server"
   pm2 save
   ```

5. **Verify Port 3001 is Listening:**
   ```powershell
   netstat -ano | findstr :3001
   ```
   - Should show: `TCP 0.0.0.0:3001 ... LISTENING`

---

## Step 4: Test from Browser Console

### Advanced Test (if needed):

1. Open **https://hideoutads.online/multiplayer-lobby.html**
2. Press **F12** to open Developer Console
3. Go to **Console** tab
4. Paste this code:

```javascript
const testWS = new WebSocket('ws://18.116.64.173:3001');
testWS.onopen = () => {
    console.log('✅ Connected to multiplayer server!');
    testWS.close();
};
testWS.onerror = (error) => {
    console.error('❌ Connection failed:', error);
};
testWS.onclose = () => {
    console.log('Connection closed');
};
```

5. **Check result:**
   - ✅ Should see: `"✅ Connected to multiplayer server!"`
   - ❌ If error: Server needs to be started manually

---

## Step 5: Verify AWS Security Group

### If Connection Still Fails:

1. **Go to EC2 Console → Security Groups**
2. Find security group for instance `i-0b45bbd8105d85e19`
3. Click on **"Inbound rules"** tab
4. **Verify Port 3001 is open:**

   Should see a rule like:
   ```
   Type: Custom TCP
   Protocol: TCP
   Port: 3001
   Source: 0.0.0.0/0
   Description: WebSocket Server for Multiplayer
   ```

5. **If Port 3001 Missing, Add It:**
   - Click "Edit inbound rules"
   - Click "Add rule"
   - Type: Custom TCP
   - Port range: 3001
   - Source: 0.0.0.0/0
   - Description: WebSocket Port 3001
   - Click "Save rules"

---

## Expected Results:

### ✅ Everything Working:
- EC2 Instance: **Running**
- SSM Agent: **Online**
- Multiplayer Lobby: **Server Status: Online**
- Player Count: **Displays (e.g., 0/32)**
- Ping: **Shows ms (e.g., 5ms)**
- Chat: **Can send messages**

### ❌ If Still Not Working:

**Most likely issue:** PM2 server didn't auto-start after reboot.

**Solution:** Connect via RDP and manually start the server:
```powershell
cd C:\gameservers
pm2 start matchmaking-server.cjs --name "multiplayer-server"
pm2 save
```

---

## Quick Troubleshooting Commands (via RDP)

```powershell
# Check if PM2 is running
pm2 status

# Check server logs
pm2 logs multiplayer-server --lines 50

# Restart server if needed
pm2 restart multiplayer-server

# Check if port 3001 is listening
netstat -ano | findstr :3001

# Check Windows Firewall rules
Get-NetFirewallRule -DisplayName "*3001*" | Format-Table

# Test local connection
Test-NetConnection -ComputerName localhost -Port 3001
```

---

## Auto-Start Fix (Do This Once on EC2)

**To make PM2 start automatically on reboot:**

1. **Connect via RDP to EC2**

2. **Run these commands in PowerShell:**
   ```powershell
   # Navigate to server directory
   cd C:\gameservers

   # Configure PM2 for startup
   pm2 startup

   # Save PM2 process list
   pm2 save

   # Install PM2 as Windows Service (optional but recommended)
   npm install -g pm2-windows-service
   pm2-service-install
   ```

3. **Reboot again to test:**
   ```powershell
   Restart-Computer
   ```

4. **After reboot, verify PM2 started automatically:**
   ```powershell
   pm2 status
   # Should show multiplayer-server as "online"
   ```

---

## Test Your Website Now!

1. Open: **https://hideoutads.online/multiplayer-lobby.html**
2. Check if "Server Status" shows **Online**
3. Try sending a chat message
4. If working, you're all set! 🎉

---

## What to Tell Me:

Please check and let me know:
- [ ] Is EC2 instance showing "Running"?
- [ ] Is SSM Agent showing "Online"?
- [ ] Does multiplayer lobby show "Server Status: Online"?
- [ ] Can you see the player count?
- [ ] Does chat work?

If anything shows offline or not working, let me know and we'll fix it together!

---

*Quick Check: Wait 2-3 minutes after reboot, then visit https://hideoutads.online/multiplayer-lobby.html*
