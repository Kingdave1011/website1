# COPY FILE TO C:\GameServers

The setup script is running but needs you to copy the file! Follow these steps ON EC2:

## STEP 1: Copy matchmaking-server.cjs

1. **On EC2 Desktop**, find `matchmaking-server.cjs`

2. **Right-click** on it → **Copy** (or press Ctrl+C)

3. **Open File Explorer** on EC2

4. In the address bar, type: `C:\GameServers`

5. Press Enter

6. **Right-click** in the folder → **Paste** (or press Ctrl+V)

7. The file `matchmaking-server.cjs` should now be in C:\GameServers

## STEP 2: Continue Setup

1. Go back to the Command Prompt window (the black window with the setup script)

2. **Press any key** to continue

3. The script will now:
   - Install PM2
   - Install WebSocket library
   - Start the server
   - Configure auto-start

4. Wait until you see: **"Server is now running 24/7!"**

## STEP 3: Verify

After setup completes, type:
```
pm2 status
```

Should show: `matchmaking-server | online` ✅

## Then Continue With:

- Configure AWS Security Group (port 3001)
- Test with curl

You're almost there!
