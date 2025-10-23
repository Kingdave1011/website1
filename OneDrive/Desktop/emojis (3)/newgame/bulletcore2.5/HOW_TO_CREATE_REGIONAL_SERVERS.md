# How to Create Regional Game Servers (US, EU, Asia, etc.)

## Why Regional Servers?

**Lower Latency = Better Experience**
- US players connecting to EU server: ~150ms ping ❌
- US players connecting to US server: ~30ms ping ✅
- EU players connecting to EU server: ~20ms ping ✅

Regional servers give each player the best possible connection speed.

---

## Current Setup

**You have:**
- **US East (Ohio)** server: ec2-18-116-64-173.us-east-2.compute.amazonaws.com
- Running matchmaking server on port 3001

---

## Step-by-Step: Create EU Server

### Step 1: Launch New EC2 Instance in EU Region

1. **Go to AWS Console**: https://console.aws.amazon.com/
2. **Switch Region** (top-right dropdown)
   - Change from "US East (Ohio)" to **"Europe (Frankfurt)"** or **"Europe (London)"**
3. **Go to EC2 Dashboard**
4. Click **Launch Instance**

### Step 2: Configure the Instance

**Name**: `Space-Shooter-EU-Server`

**OS**: Windows Server 2022

**Instance Type**: t2.micro (Free tier) or t3.small for better performance

**Key Pair**: 
- **IMPORTANT**: Click "Create new key pair"
- Name it: `eu-server-key`
- **DOWNLOAD THE .pem FILE** and save it somewhere safe!
- (This avoids the password reset issue we just had)

**Network Settings**:
- Allow RDP traffic (port 3389)
- Allow Custom TCP (port 3001) - for matchmaking server

**Storage**: 30 GB

**Launch Instance**

### Step 3: Get the EU Server Address

After instance starts:
1. Select your new EU instance
2. Copy the **Public IPv4 DNS**
3. Example: `ec2-X-X-X-X.eu-central-1.compute.amazonaws.com`

### Step 4: Connect via RDP

1. **Get Password**:
   - Select instance
   - Actions → Security → Get Windows Password
   - Upload the `eu-server-key.pem` file you downloaded
   - Click **Decrypt Password**
   - Copy the password

2. **Connect**:
   - Open Remote Desktop
   - Computer: `ec2-X-X-X-X.eu-central-1.compute.amazonaws.com`
   - Username: `Administrator`
   - Password: (the decrypted password)

### Step 5: Set Up Server (Same as US Server)

**In the RDP window:**

1. **Install Node.js**:
   - Open browser
   - Go to https://nodejs.org
   - Download and install LTS version
   
2. **Install PM2**:
   ```bash
   npm install -g pm2
   ```

3. **Upload Your matchmaking-server.cjs**:
   - Use RDP file transfer or
   - Use GitHub: `git clone https://github.com/Kingdave1011/website1.git`
   - Copy `matchmaking-server.cjs` to `C:\Server\`

4. **Start Server with PM2**:
   ```bash
   cd C:\Server
   pm2 start matchmaking-server.cjs
   pm2 save
   pm2 startup
   ```

5. **Configure Firewall** (Windows):
   ```bash
   netsh advfirewall firewall add rule name="Matchmaking Server" dir=in action=allow protocol=TCP localport=3001
   ```

---

## Your Regional Server List

After setting up multiple servers, you'll have:

| Region | Server Address | Port | Latency |
|--------|---------------|------|---------|
| 🇺🇸 **US East** | ec2-18-116-64-173.us-east-2.compute.amazonaws.com | 3001 | ~30ms (US players) |
| 🇪🇺 **EU** | ec2-X-X-X-X.eu-central-1.compute.amazonaws.com | 3001 | ~20ms (EU players) |
| 🌏 **Asia** | ec2-X-X-X-X.ap-southeast-1.compute.amazonaws.com | 3001 | ~30ms (Asia players) |

---

## Recommended Regions

**Top 5 for Game Servers:**

1. **🇺🇸 US East (N. Virginia)** - `us-east-1` - North America
2. **🇪🇺 Europe (Frankfurt)** - `eu-central-1` - Europe
3. **🌏 Asia Pacific (Singapore)** - `ap-southeast-1` - Southeast Asia
4. **🇯🇵 Asia Pacific (Tokyo)** - `ap-northeast-1` - Japan/Korea
5. **🇧🇷 South America (São Paulo)** - `sa-east-1` - South America

---

## Player Auto-Routing (How to Pick Best Server)

### Option 1: Simple Client-Side Ping Test

In your game code, test ping to each server:

```javascript
const servers = [
  { region: 'US', url: 'ws://ec2-18-116-64-173.us-east-2.compute.amazonaws.com:3001' },
  { region: 'EU', url: 'ws://ec2-X-X-X-X.eu-central-1.compute.amazonaws.com:3001' },
  { region: 'Asia', url: 'ws://ec2-X-X-X-X.ap-southeast-1.compute.amazonaws.com:3001' }
];

async function findBestServer() {
  let bestServer = null;
  let lowestPing = Infinity;
  
  for (const server of servers) {
    const ping = await testServerPing(server.url);
    console.log(`${server.region}: ${ping}ms`);
    
    if (ping < lowestPing) {
      lowestPing = ping;
      bestServer = server;
    }
  }
  
  console.log(`Best server: ${bestServer.region} (${lowestPing}ms)`);
  return bestServer;
}

async function testServerPing(url) {
  const start = Date.now();
  try {
    const ws = new WebSocket(url);
    await new Promise((resolve, reject) => {
      ws.onopen = resolve;
      ws.onerror = reject;
      setTimeout(reject, 5000); // 5 second timeout
    });
    ws.close();
    return Date.now() - start;
  } catch {
    return 9999; // Server unreachable
  }
}

// Use it
const bestServer = await findBestServer();
const ws = new WebSocket(bestServer.url);
```

### Option 2: Geo-Location Based

Detect player's location and route them:

```javascript
const regionServers = {
  'US': 'ws://ec2-18-116-64-173.us-east-2.compute.amazonaws.com:3001',
  'EU': 'ws://ec2-X-X-X-X.eu-central-1.compute.amazonaws.com:3001',
  'Asia': 'ws://ec2-X-X-X-X.ap-southeast-1.compute.amazonaws.com:3001'
};

// Detect player region
const playerRegion = Intl.DateTimeFormat().resolvedOptions().timeZone;

let serverUrl;
if (playerRegion.includes('America')) {
  serverUrl = regionServers.US;
} else if (playerRegion.includes('Europe')) {
  serverUrl = regionServers.EU;
} else {
  serverUrl = regionServers.Asia;
}

const ws = new WebSocket(serverUrl);
```

---

## Cost Estimate

**Per Server (t2.micro with 30GB storage):**
- Instance: ~$8-10/month
- Data transfer: ~$1-5/month
- **Total per region**: ~$10-15/month

**3 Regions**: ~$30-45/month total

**Tip**: Start with 2 regions (US + EU) to cover most players.

---

## Management Tips

### 1. Keep Servers Synced

When you update your matchmaking code:
1. Update the file locally
2. Push to GitHub
3. RDP into each server
4. Pull latest code: `git pull`
5. Restart: `pm2 restart matchmaking-server`

### 2. Monitor Server Health

Create a simple status page:

```javascript
// In your game
const servers = [
  { name: 'US East', url: 'ws://...' },
  { name: 'EU', url: 'ws://...' },
  { name: 'Asia', url: 'ws://...' }
];

servers.forEach(async server => {
  const status = await checkServer(server.url);
  console.log(`${server.name}: ${status ? 'ONLINE ✅' : 'OFFLINE ❌'}`);
});
```

### 3. Use PM2 on All Servers

PM2 ensures your servers auto-restart if they crash.

---

## Quick Setup Checklist

For each new region:

- [ ] Switch to target region in AWS
- [ ] Launch Windows Server EC2 instance
- [ ] Download and SAVE the .pem key file
- [ ] Open ports 3389 (RDP) and 3001 (game server)
- [ ] Connect via RDP
- [ ] Install Node.js
- [ ] Install PM2
- [ ] Clone your GitHub repo
- [ ] Start matchmaking server with PM2
- [ ] Configure Windows Firewall
- [ ] Test connection from your game
- [ ] Add server to your region list

---

## Common Issues

**Issue**: "Can't connect to new server"
**Fix**: Check Windows Firewall - allow port 3001

**Issue**: "Server stops after closing RDP"
**Fix**: Make sure you used PM2, not just `node matchmaking-server.cjs`

**Issue**: "Players still have high ping"
**Fix**: Verify they're connecting to the correct regional server

---

## Next Steps

1. Start with **2 servers**: US (you have) + EU
2. Test with a few players
3. Monitor which regions need servers
4. Add Asia if you get Asian players
5. Add more regions as your player base grows

**Remember**: More servers = more cost, but better player experience!
