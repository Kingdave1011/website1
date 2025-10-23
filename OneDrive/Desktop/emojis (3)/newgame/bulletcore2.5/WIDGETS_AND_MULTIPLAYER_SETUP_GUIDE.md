# Quick Setup Guide - Widgets & Multiplayer

## Issue 1: Clock Not Showing

The clock widget needs to be loaded on your pages. I've already added the script tag to `index.html`:

```html
<!-- Local Time Clock Widget -->
<script src="time-clock.js"></script>
```

**To add to other pages**, add this line before `</body>`:
```html
<script src="time-clock.js"></script>
```

The clock will automatically appear in the top-right corner at position (70px from top, 15px from right).

---

## Issue 2: Multiplayer Server Offline

The multiplayer lobby shows "Server currently offline" because **you need to deploy the multiplayer server to Render.com**.

### Quick Fix - Deploy to Render.com (5 minutes):

1. **Go to**: https://render.com (Sign up - it's FREE)

2. **Click**: "New +" → "Web Service"

3. **Connect**: Your GitHub repository (https://github.com/Kingdave1011/website1)

4. **Configure**:
   - **Root Directory**: `multiplayer-server`
   - **Environment**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free

5. **Click**: "Create Web Service"

6. **Wait**: 5-10 minutes for deployment

7. **Copy**: Your server URL (e.g., `https://space-shooter-server.onrender.com`)

8. **Update** `HideoutAdsWebsite/multiplayer-lobby.html`:
   - Find: `ws://localhost:3001`
   - Replace with: `wss://your-app-name.onrender.com` (use YOUR Render.com URL)

9. **Push** changes to GitHub

10. **Done!** Server will run 24/7 for FREE

### Alternative: Keep Using "Server Offline" Message

If you don't want to deploy yet, the multiplayer lobby will still show the UI but say "Server offline" until you deploy the server.

---

## Issue 3: Admin Panel Not Showing

Looking at your screenshot, you're logged in as `King_davez` (Developer badge shows). 

The admin panel button should appear in the profile dropdown menu. Let me check the multiplayer-lobby.html file to see if it's missing the admin panel link.

**Quick Fix - Add Admin Panel to Profile Menu**:

In `multiplayer-lobby.html`, find the profile dropdown and add:

```html
<a href="admin-panel.html" style="...">⚡ Admin Panel</a>
```

Or you can access it directly at: `https://hideoutads.online/admin-panel.html`

---

## Summary of What You Need To Do:

### ✅ Already Done (Pushed to GitHub):
- Cookie manager created
- Live leaderboard widget created  
- Time clock widget created
- AI helper chatbot created
- Patch notes updated to v7.3
- Homepage updated with script tags

### 📝 What You Need To Do:

1. **Deploy Multiplayer Server** (5 min):
   - Go to Render.com
   - Deploy the `multiplayer-server` folder
   - Copy the server URL
   - Update multiplayer-lobby.html with the URL
   - Push to GitHub

2. **Add Admin Panel Link** (1 min):
   - Edit multiplayer-lobby.html
   - Add admin panel link to profile dropdown
   - Or just visit: https://hideoutads.online/admin-panel.html directly

3. **Test Everything**:
   - Refresh your website
   - Check if clock appears
   - Check if cookie banner shows (only first visit)
   - Check multiplayer connection after Render.com deployment

---

## Why Multiplayer Shows "Offline"

The multiplayer server (`multiplayer-server/server.js`) needs to be running 24/7 on a cloud platform. Currently it's trying to connect to `ws://localhost:3001` which only works if you're running the server on your local computer.

**Solution**: Deploy to Render.com (FREE, runs 24/7, never shuts down)

**See**: `multiplayer-server/README.md` for full deployment guide

---

## Quick Commands

### Push Homepage Changes:
```bash
git add HideoutAdsWebsite/index.html
git commit -m "Add widget script tags to homepage"
git push origin master
```

### Check What's Different:
```bash
git status
git diff HideoutAdsWebsite/index.html
```

---

## Files Ready To Use:

1. ✅ **cookie-manager.js** - Cookie consent system
2. ✅ **live-leaderboard-widget.js** - Auto-updating leaderboard  
3. ✅ **time-clock.js** - Local time/date display
4. ✅ **ai-helper-chatbot.js** - Q&A assistant
5. ✅ **multiplayer-server/** - 24/7 multiplayer server (needs deployment)

All files are in your GitHub repository and ready to use!

---

## Need Help?

- **Clock not showing?** - Make sure you pushed index.html changes and refreshed the page
- **Server offline?** - Deploy to Render.com following the steps above
- **Admin panel missing?** - Access directly at `/admin-panel.html` or add link to profile menu

Let me know if you need help with any of these steps!
