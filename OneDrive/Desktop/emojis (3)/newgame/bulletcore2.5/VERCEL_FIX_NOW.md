# URGENT: Fix Vercel Deployment Error

## Problem
Vercel is rejecting the deployment because it's seeing the full file path with spaces:
`'OneDrive/Desktop/emojis (3)/newgame/bulletcore2.5/HideoutAdsWebsite/api/leaderboard.js'`

## Solution

### Go to Vercel Dashboard RIGHT NOW:

1. **Open**: https://vercel.com/dashboard
2. **Select** your project (website1)
3. **Click** Settings tab
4. **Scroll to** "Build & Development Settings"
5. **Set Root Directory** to: `HideoutAdsWebsite`
6. **Click** Save
7. **Go to** Deployments tab
8. **Click** the three dots (...) on the failed deployment
9. **Click** "Redeploy"

## Why This Fixes It

By setting Root Directory to `HideoutAdsWebsite`, Vercel will:
- Treat `HideoutAdsWebsite` as the project root
- See files as `api/leaderboard.js` instead of the full path
- Remove the spaces and length issues from paths

## After Fixing

Your APIs will be available at:
- `https://your-domain.vercel.app/api/leaderboard`
- `https://your-domain.vercel.app/api/matchmaking`  
- `https://your-domain.vercel.app/api/stats`
- `https://your-domain.vercel.app/api/ai-bot` (NEW!)

---

**DO THIS NOW** before adding more features!
