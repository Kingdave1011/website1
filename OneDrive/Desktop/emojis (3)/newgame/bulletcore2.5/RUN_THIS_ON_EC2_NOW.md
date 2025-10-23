# RUN THIS ON EC2 RIGHT NOW

You've copied the files to EC2! Now follow these exact steps:

## STEP 1: Run Setup Script (On EC2)

1. On EC2 Desktop, find the file: **setup-ec2-server.bat**

2. **Right-click** on it

3. Select **"Run as administrator"**

4. Click **"Yes"** when Windows asks for permission

5. A black command window will open and start installing:
   - Node.js
   - PM2 
   - WebSocket library
   - Starting the server
   - Configuring auto-start

6. **Wait 2-3 minutes** until you see:
   ```
   Server is now running 24/7!
   Press any key to continue...
   ```

7. Press any key to close the window

## STEP 2: Verify Server is Running (On EC2)

1. On EC2, open **Command Prompt** (search for "cmd" in Start menu)

2. Type this command:
   ```
   pm2 status
   ```

3. **You should see**:
   ```
   ┌─────┬────────────────────┬─────────┬─────────┬──────────┐
   │ id  │ name               │ status  │ restart │ uptime   │
   ├─────┼────────────────────┼─────────┼─────────┼──────────┤
   │ 0   │ matchmaking-server │ online  │ 0       │ 10s      │
   └─────┴────────────────────┴─────────┴─────────┴──────────┘
   ```

4. If status shows **"online"** → SUCCESS! ✅

## STEP 3: Configure AWS Security Group (On YOUR LOCAL PC)

Now switch to YOUR LOCAL PC (not EC2) and do this:

1. Open browser and go to **AWS Console**

2. Navigate to: **EC2** → **Instances**

3. Find your instance: **i-03ef2c768872f8af0** (IP: 13.59.157.124)

4. Click on it, then click the **Security** tab

5. Click on the **Security Group** link (looks like sg-xxxxxxxxx)

6. Click **"Edit inbound rules"** button

7. Click **"Add rule"** button

8. Fill in:
   - **Type**: Custom TCP
   - **Port range**: 3001
   - **Source**: Anywhere-IPv4 (0.0.0.0/0)
   - **Description**: WebSocket matchmaking server

9. Click **"Save rules"**

## STEP 4: Test the Connection (On YOUR LOCAL PC)

1. On YOUR LOCAL PC, open Command Prompt

2. Type:
   ```
   curl http://13.59.157.124:3001
   ```

3. **Expected response**:
   ```
   Cannot GET /
   ```
   
   **This is GOOD!** It means the server is running and accessible!

## YOU'RE DONE! 🎉

Your matchmaking server is now:
- ✅ Running 24/7 on EC2
- ✅ Auto-restarts if it crashes
- ✅ Auto-starts when EC2 boots
- ✅ Accessible from anywhere in the world

Players can now connect to your multiplayer game at: **13.59.157.124:3001**

---

## Helpful Commands (Run on EC2 if needed)

**View server logs:**
```
pm2 logs matchmaking-server
```

**Restart server:**
```
pm2 restart matchmaking-server
```

**Stop server:**
```
pm2 stop matchmaking-server
```

**Check server status:**
```
pm2 status
