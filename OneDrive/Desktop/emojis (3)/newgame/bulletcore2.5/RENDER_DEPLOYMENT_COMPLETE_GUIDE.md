# Deploy Space Shooter to Render.com - Complete Guide

## 🎮 Your Render Service
**URL**: https://dashboard.render.com/web/srv-d3su1mvgi27c73duktrg

## Problem Summary
- Railway deployment failing (wrong directory structure)
- Leaderboard can't connect to Supabase
- Need to properly deploy multiplayer server

## Solution: Deploy to Render.com

### Step 1: Connect GitHub Repository to Render

1. Go to your Render dashboard: https://dashboard.render.com/web/srv-d3su1mvgi27c73duktrg
2. Click on **Settings** tab
3. Under **Build & Deploy**, set:
   - **Root Directory**: `multiplayer-server`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Environment**: Node

### Step 2: Configure Environment Variables

In Render dashboard, go to **Environment** tab and add:
```
NODE_ENV=production
PORT=10000
```

### Step 3: Fix Multiplayer Server for Render

The server needs to bind to Render's assigned port. The package.json looks good, but make sure server.js uses `process.env.PORT`.

### Step 4: Deploy

1. Click **Manual Deploy** → **Deploy latest commit**
2. Wait for build to complete
3. Your multiplayer server will be live at the Render URL

### Step 5: Update Website to Use Render Server

After deployment, get your Render service URL (something like `https://your-service.onrender.com`)

Update these files:
- `HideoutAdsWebsite/multiplayer-lobby.html` - Change WebSocket URL to Render URL
- Update: `wss://your-service.onrender.com` (use wss:// for secure websocket)

## Fix Leaderboard Connection

The leaderboard is failing because it can't connect to Supabase. Here's what to check:

### Option 1: Check Supabase Credentials
1. Go to https://supabase.com/dashboard
2. Go to your project settings
3. Copy the **Project URL** and **anon/public API key**
4. Make sure these are in your `HideoutAdsWebsite/leaderboard.html` file

### Option 2: Fix CORS Issues
In your Supabase dashboard:
1. Go to **Authentication** → **URL Configuration**
2. Add your website domain to **Site URL**
3. Add your domain to **Redirect URLs**

### Option 3: Enable Row Level Security (RLS)
If RLS is blocking access:
1. Go to Supabase → **Table Editor**
2. Select your `leaderboard` table
3. Click **RLS** tab
4. Create a policy:
```sql
CREATE POLICY "Allow public read access" ON leaderboard
FOR SELECT USING (true);

CREATE POLICY "Allow authenticated write" ON leaderboard
FOR INSERT WITH CHECK (true);
```

## Quick Fix Commands

### For Render Deployment:
```bash
# Make sure you're in the project root
cd multiplayer-server

# Test locally first
npm install
npm start

# Should see: "Multiplayer server running on port 3000"
```

### For Leaderboard Fix:
The issue is likely:
1. **Missing Supabase URL/Key** in leaderboard.html
2. **CORS policy** not configured
3. **RLS policies** blocking public access

## Next Steps

1. **Deploy to Render** using the steps above
2. **Get your Render URL** (e.g., `https://space-shooter-multiplayer-xxxxx.onrender.com`)
3. **Update multiplayer-lobby.html** with the new Render WebSocket URL
4. **Fix leaderboard** by checking Supabase credentials and RLS policies
5. **Push changes to GitHub** so Render auto-deploys

## Important Notes

- **Render Free Tier**: Server may sleep after inactivity, takes ~30 seconds to wake up
- **Railway vs Render**: If Railway keeps failing, Render is a better alternative
- **WebSocket URL**: Must use `wss://` (secure) for production, not `ws://`

## Testing After Deployment

1. Visit your Render service URL in browser - should see "Multiplayer server running"
2. Test multiplayer lobby - should show "Online" status
3. Test leaderboard - should load without errors

## Status

✅ Admin panel hidden from homepage
🔄 Multiplayer server needs deployment to Render
🔄 Leaderboard needs Supabase configuration fix
🔄 Website needs to be updated with new server URL
