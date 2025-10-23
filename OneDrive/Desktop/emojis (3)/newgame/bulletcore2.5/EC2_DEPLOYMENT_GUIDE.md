# Deploy Matchmaking Server to EC2 for 24/7 Operation

## Your EC2 Server Details
- **IP:** 18.116.64.173
- **Instance ID:** i-0b45bbd8105d85e19
- **Region:** us-east-2 (Ohio)

## Quick Deployment Steps

### Step 1: Connect to EC2
Use Remote Desktop Connection:
- Open `mstsc.exe`
- Enter: `18.116.64.173`
- Use your AWS key pair credentials

### Step 2: Install Node.js on EC2 (if not installed)
```powershell
# Download Node.js
Invoke-WebRequest -Uri "https://nodejs.org/dist/v20.10.0/node-v20.10.0-x64.msi" -OutFile "node.msi"
Start-Process msiexec.exe -ArgumentList '/i', 'node.msi', '/quiet', '/norestart' -Wait
```

### Step 3: Create Server Directory
```powershell
mkdir C:\GameServers
cd C:\GameServers
```

### Step 4: Copy matchmaking-server.cjs
Copy the file from your local machine to EC2

### Step 5: Install Dependencies
```powershell
npm install ws
```

### Step 6: Install PM2 for 24/7 Running
```powershell
npm install -g pm2-windows-service
pm2 install pm2-windows-service
```

### Step 7: Start Server with PM2
```powershell
pm2 start matchmaking-server.cjs --name "matchmaking"
pm2 save
pm2 startup
```

### Step 8: Configure Windows Firewall on EC2
```powershell
netsh advfirewall firewall add rule name="Matchmaking Server" dir=in action=allow protocol=TCP localport=3001
```

### Step 9: Verify AWS Security Group
Make sure port 3001 is open in your EC2 security group (you already did this!)

## Test Server
From any computer:
```bash
curl http://18.116.64.173:3001
```

Should return: "Matchmaking Server Running"

## PM2 Commands
- **Status:** `pm2 status`
- **Logs:** `pm2 logs matchmaking`
- **Restart:** `pm2 restart matchmaking`
- **Stop:** `pm2 stop matchmaking`

Server will auto-restart on crash and after Windows reboot!
