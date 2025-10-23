# Windows Firewall Setup for Port 3001

## Issue
The firewall rule for port 3001 requires administrator privileges to add.

## Solution - Run Command as Administrator

### Step 1: Open Command Prompt as Administrator
1. Press `Windows Key + X`
2. Click **"Command Prompt (Admin)"** or **"Windows PowerShell (Admin)"** or **"Terminal (Admin)"**
3. Click **"Yes"** when prompted by User Account Control

### Step 2: Run the Firewall Command
Copy and paste this command into the administrator command prompt:

```cmd
netsh advfirewall firewall add rule name="WebSocket Port 3001" dir=in action=allow protocol=TCP localport=3001
```

Press Enter to execute.

### Step 3: Verify Success
You should see a message: **"Ok."**

This confirms the firewall rule was added successfully.

## What This Does
- **Rule Name**: "WebSocket Port 3001"
- **Direction**: Inbound (incoming connections)
- **Action**: Allow
- **Protocol**: TCP
- **Port**: 3001

This allows players to connect to your game server at **hideoutads.online** on port 3001 via WebSocket connections.

## To Verify the Rule Was Created
Run this command in an administrator command prompt:

```cmd
netsh advfirewall firewall show rule name="WebSocket Port 3001"
```

## To Remove the Rule (if needed)
If you ever need to remove this rule:

```cmd
netsh advfirewall firewall delete rule name="WebSocket Port 3001"
```

## Additional Notes
- This only affects your local Windows Firewall
- If you're hosting on a cloud server (AWS EC2, etc.), you'll also need to configure the security group/firewall rules on that platform
- For hideoutads.online, make sure your hosting provider also allows port 3001
