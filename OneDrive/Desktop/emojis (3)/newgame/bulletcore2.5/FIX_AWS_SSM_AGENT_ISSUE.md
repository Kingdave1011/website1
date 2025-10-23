# 🔧 FIX AWS SSM Agent Connection Issue

## Problem
Your AWS EC2 multiplayer server shows "SSM Agent is not online" error, preventing remote management and causing multiplayer connectivity issues.

---

## Quick Solution Steps

### Option 1: Restart the EC2 Instance (Easiest)

1. **Go to AWS Console:**
   - Navigate to EC2 Dashboard
   - Find instance: `i-0b45bbd8105d85e19`

2. **Restart Instance:**
   ```
   Actions → Instance State → Reboot
   ```

3. **Wait 2-3 minutes** for SSM Agent to reconnect

4. **Verify Connection:**
   - Check instance status shows "Running"
   - SSM Agent status should show "Online"

---

### Option 2: Connect via RDP and Restart SSM Agent

**If restart doesn't work:**

1. **Connect to EC2 via Remote Desktop (RDP):**
   - Public IP: `18.116.64.173`
   - Username: `Administrator`
   - Password: (your EC2 admin password)

2. **Open PowerShell as Administrator**

3. **Restart SSM Agent:**
   ```powershell
   Restart-Service AmazonSSMAgent
   ```

4. **Check SSM Agent Status:**
   ```powershell
   Get-Service AmazonSSMAgent
   ```
   - Should show: `Status: Running`

5. **Start the Matchmaking Server:**
   ```powershell
   cd C:\gameservers
   pm2 start matchmaking-server.cjs
   pm2 status
   ```

---

### Option 3: Reinstall SSM Agent (If Still Not Working)

**Connect via RDP first, then:**

1. **Download SSM Agent:**
   ```powershell
   Invoke-WebRequest -Uri "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe" -OutFile "$env:USERPROFILE\Downloads\SSMAgentSetup.exe"
   ```

2. **Run Installer:**
   ```powershell
   Start-Process "$env:USERPROFILE\Downloads\SSMAgentSetup.exe" -ArgumentList "/S" -Wait
   ```

3. **Start SSM Agent:**
   ```powershell
   Start-Service AmazonSSMAgent
   ```

4. **Verify:**
   ```powershell
   Get-Service AmazonSSMAgent
   ```

---

## Fix Multiplayer Server Connection

### After SSM Agent is Online:

1. **Check if Node.js Server is Running:**
   ```powershell
   pm2 list
   ```

2. **If Server Not Running:**
   ```powershell
   cd C:\gameservers
   pm2 start matchmaking-server.cjs --name "multiplayer-server"
   pm2 save
   ```

3. **Test Port 3001:**
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 3001
   ```
   - Should show: `TcpTestSucceeded: True`

4. **Check Firewall Rules:**
   ```powershell
   Get-NetFirewallRule -DisplayName "*3001*"
   ```

5. **If Firewall Rule Missing, Add It:**
   ```powershell
   New-NetFirewallRule -DisplayName "WebSocket Port 3001" -Direction Inbound -LocalPort 3001 -Protocol TCP -Action Allow
   ```

---

## AWS Security Group Configuration

### Ensure Port 3001 is Open in AWS:

1. **Go to EC2 Console → Security Groups**

2. **Find Security Group for Instance `i-0b45bbd8105d85e19`**

3. **Edit Inbound Rules:**
   - Click "Edit inbound rules"

4. **Add Rule:**
   ```
   Type: Custom TCP
   Protocol: TCP
   Port Range: 3001
   Source: 0.0.0.0/0 (Anywhere IPv4)
   Description: WebSocket Server for Multiplayer
   ```

5. **Add Another Rule for IPv6:**
   ```
   Type: Custom TCP
   Protocol: TCP
   Port Range: 3001
   Source: ::/0 (Anywhere IPv6)
   Description: WebSocket Server IPv6
   ```

6. **Save Rules**

---

## Test Multiplayer Connection

### From Your Local Machine:

1. **Test WebSocket Connection:**
   ```bash
   # Windows PowerShell
   Test-NetConnection -ComputerName 18.116.64.173 -Port 3001
   ```

2. **Test in Browser:**
   - Open: `https://hideoutads.online/multiplayer-lobby.html`
   - Check if "Server Status" shows "Online"
   - Player count should update

3. **Test Direct WebSocket:**
   ```javascript
   // Open browser console on hideoutads.online
   const ws = new WebSocket('ws://18.116.64.173:3001');
   ws.onopen = () => console.log('Connected!');
   ws.onerror = (e) => console.error('Error:', e);
   ```

---

## Common Issues & Solutions

### Issue 1: "Connection Refused"
**Solution:** Server not running
```powershell
pm2 restart multiplayer-server
```

### Issue 2: "Connection Timeout"
**Solution:** Firewall blocking
```powershell
# Check Windows Firewall
Get-NetFirewallRule -DisplayName "*3001*" | Format-Table

# Add rule if missing
New-NetFirewallRule -DisplayName "WebSocket Port 3001" -Direction Inbound -LocalPort 3001 -Protocol TCP -Action Allow
```

### Issue 3: "SSM Agent Offline"
**Solution:** Restart EC2 instance
- AWS Console → Reboot instance

### Issue 4: "Server Crashes on Start"
**Solution:** Check logs
```powershell
pm2 logs multiplayer-server
```

### Issue 5: Port Already in Use
**Solution:** Kill process using port 3001
```powershell
# Find process
Get-Process -Id (Get-NetTCPConnection -LocalPort 3001).OwningProcess

# Kill process (replace PID)
Stop-Process -Id <PID> -Force

# Restart server
pm2 restart multiplayer-server
```

---

## Complete Setup Commands (Run on EC2)

```powershell
# 1. Navigate to server directory
cd C:\gameservers

# 2. Stop any existing server
pm2 stop all
pm2 delete all

# 3. Start fresh server
pm2 start matchmaking-server.cjs --name "multiplayer-server"

# 4. Save PM2 configuration
pm2 save

# 5. Setup auto-startup
pm2 startup

# 6. Check status
pm2 status

# 7. View logs
pm2 logs multiplayer-server --lines 50

# 8. Check if port is listening
netstat -ano | findstr :3001
```

---

## Verify Everything is Working

### Checklist:

- [ ] SSM Agent shows "Online" in AWS Console
- [ ] EC2 instance shows "Running" status
- [ ] Windows Firewall allows port 3001
- [ ] AWS Security Group allows port 3001 (inbound)
- [ ] PM2 shows server as "online"
- [ ] Port 3001 is listening (netstat shows LISTENING)
- [ ] Test connection from browser succeeds
- [ ] Multiplayer lobby shows "Server Status: Online"

---

## Emergency Fallback: Use Your Local PC as Server

**If EC2 keeps failing:**

1. **Run on Your PC (Windows 11):**
   ```cmd
   cd C:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5
   node matchmaking-server.cjs
   ```

2. **Open Firewall on Your PC:**
   ```powershell
   New-NetFirewallRule -DisplayName "WebSocket Port 3001" -Direction Inbound -LocalPort 3001 -Protocol TCP -Action Allow
   ```

3. **Update Website to Use Your PC:**
   - Edit `HideoutAdsWebsite/multiplayer-lobby.html`
   - Change WebSocket URL to: `ws://localhost:3001`

4. **Test Locally:**
   - Open: `http://localhost:3000` (or your local dev server)
   - Multiplayer should work on your PC

---

## Long-Term Solution: Auto-Restart Setup

**Make server restart automatically on crashes:**

1. **Install PM2 Ecosystem File:**
   ```powershell
   # Create ecosystem.config.js
   @"
   module.exports = {
     apps: [{
       name: 'multiplayer-server',
       script: './matchmaking-server.cjs',
       instances: 1,
       autorestart: true,
       watch: false,
       max_memory_restart: '500M',
       env: {
         NODE_ENV: 'production',
         PORT: 3001
       }
     }]
   }
   "@ | Out-File -FilePath C:\gameservers\ecosystem.config.js
   ```

2. **Start with Ecosystem:**
   ```powershell
   pm2 start ecosystem.config.js
   pm2 save
   ```

3. **Setup Windows Service:**
   ```powershell
   npm install -g pm2-windows-service
   pm2-service-install
   ```

---

## Need Help?

### AWS Support:
- Check CloudWatch Logs for SSM Agent errors
- Review EC2 instance system logs

### Game Server Logs:
```powershell
pm2 logs multiplayer-server --lines 100
```

### Network Diagnostics:
```powershell
# Check all listening ports
netstat -ano | findstr LISTENING

# Check specific port 3001
netstat -ano | findstr :3001

# Test connection to public IP
Test-NetConnection -ComputerName 18.116.64.173 -Port 3001
```

---

## Summary

**Quick Fix (90% of cases):**
1. Reboot EC2 instance
2. Wait 2-3 minutes
3. Check if SSM Agent is online
4. Test multiplayer lobby

**If That Doesn't Work:**
1. RDP into EC2
2. Restart SSM Agent service
3. Start PM2 server
4. Check firewall rules
5. Verify AWS Security Group

**Still Not Working?**
- Use local PC as temporary server
- Check detailed logs
- Contact AWS support for SSM Agent issues

---

*Last Updated: October 23, 2025*
*Issue: AWS SSM Agent Offline + Multiplayer Server Connection*
