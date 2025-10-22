# How to Set Vercel Root Directory

## The 404 Error You're Seeing
You're getting `404: NOT_FOUND` because Vercel doesn't know to serve files from the `website/` folder. This is configured in your Vercel dashboard, not in files.

## Steps to Fix Vercel Deployment:

### 1. Go to Vercel Dashboard
- Visit: https://vercel.com/dashboard
- Log in with your account

### 2. Find Your Project
- Look for your project (probably named "website1" or similar)
- Click on it to open project details

### 3. Go to Settings
- Click the "Settings" tab at the top
- Look for "General" in the left sidebar

### 4. Set Root Directory
- Scroll down to find **"Root Directory"** setting
- Click "Edit" button
- Type: `website`
- Click "Save"

### 5. Redeploy
- Go back to "Deployments" tab
- Click the "..." menu on the latest deployment
- Click "Redeploy"

## Alternative: Using vercel.json (if dashboard doesn't work)
If the dashboard settings don't help, we may need to restructure the repository to have website files at the root instead of in a subfolder.

---

# PC Standalone Game - Spaceship Not Visible Issue

## The Problem
Your PC standalone version shows the main menu but when you click Play, you don't see your spaceship in-game.

## Why This Happens
This is a common Godot issue where:
- The game works fine in the editor
- But in the exported/compiled version, the player sprite doesn't appear

## Common Causes:
1. **Layer/Z-Index Issue**: Player sprite is behind the background
2. **Missing Scene Instance**: Player scene not being instantiated
3. **Export Settings**: Player scene not included in export
4. **Texture/Sprite Missing**: Player sprite image not exported

## To Fix This:
You need to open the Godot project (SpaceShooterV2) and:

1. **Check Player Scene is in Main.tscn**
   - Open Main.tscn
   - Verify Player node exists and is visible

2. **Check Z-Index/Layer**
   - Select Player node
   - In Inspector, check Z Index is higher than background
   - Make sure it's on the correct CanvasLayer

3. **Re-export the Game**
   - Project → Export
   - Make sure all resources are included
   - Export again for Windows

The PC version needs to be fixed by re-exporting from Godot after fixing the player visibility issue in the project itself.
