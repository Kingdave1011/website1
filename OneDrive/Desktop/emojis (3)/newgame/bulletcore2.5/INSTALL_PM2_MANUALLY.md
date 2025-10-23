# Install PM2 Manually on EC2

## Problem
Your screenshot shows: `'pm2' is not recognized as an internal or external command`

This means PM2 wasn't installed. Let's install it now!

## Step 1: Install PM2 (On EC2)

In the Command Prompt on EC2, run:

```
npm install -g pm2
```

Wait for installation to complete (should take 30 seconds).

## Step 2: Verify PM2 is Installed

```
pm2 --version
```

Should show a version number like: `5.3.0`

## Step 3: Start the Server

```
pm2 start matchmaking-server.cjs --name matchmaking-server
```

Should show:
```
[PM2] Starting matchmaking-server.cjs in fork_mode
[PM2] Done
```

## Step 4: Save Configuration

```
pm2 save
```

## Step 5: Enable Auto-Start

```
pm2 startup
```

This command will output another command - **copy and run that command** (it will be specific to your system).

## Step 6: Verify Server is Running

```
pm2 status
```

Should show:
```
matchmaking-server | online
```

## Step 7: Test Connection

On YOUR LOCAL PC, run:
```
curl http://13.59.157.124:3001
```

Should return: `Cannot GET /` ✅

---

## If NPM is Not Installed

If you get "'npm' is not recognized", you need to install Node.js first:

1. On EC2 Desktop, run the `setup-ec2-server.bat` file again as administrator
2. Or download Node.js manually from: https://nodejs.org
3. Install Node.js, then run the PM2 commands above

---

## All Commands in Order (Copy/Paste on EC2)

```
npm install -g pm2
pm2 start matchmaking-server.cjs --name matchmaking-server
pm2 save
pm2 startup
pm2 status
```

Your server will then be running 24/7!
