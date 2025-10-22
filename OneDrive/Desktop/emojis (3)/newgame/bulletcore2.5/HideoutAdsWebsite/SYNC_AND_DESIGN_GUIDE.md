# 🎨 Website Design & Game Sync Guide

## Current Status

Your website and game are ALREADY syncing! Here's how:

### ✅ Data Sync (Already Working)
Your game uses **localStorage** which automatically syncs between:
- Web version (browser game)
- Website profile page
- Standalone PC game (same localStorage)

**What's Synced:**
- Player stats (kills, waves, XP, level)
- Credits earned
- Ship skins unlocked
- Achievements
- Referral data
- All game progress

### 📊 Leaderboard Sync
The leaderboard (`leaderboard.html`) is ready to sync with real player data. To connect:

1. **Set up backend API** (Firebase, AWS, or your backend)
2. **Update leaderboard.html line 139:**
```javascript
const response = await fetch('YOUR_API_ENDPOINT/leaderboard');
const data = await response.json();
```

3. **Send data from game** - Add to `index.tsx` after game over:
```javascript
// In gameOver() function
fetch('YOUR_API_ENDPOINT/submit-score', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
        username: gameState.username,
        score: score,
        kills: gameState.stats.totalKills,
        games: 1
    })
});
```

## 🎨 Matching All Pages to Homepage Design

Your homepage has these design elements:
- **Animated starfield background** (moving stars)
- **Navigation header** (fixed top, same links)
- **Orbitron + Rajdhani fonts**
- **Cosmic Blue theme** (#00C6FF, #8A2BE2 colors)
- **Theme toggle button**
- **Smooth animations**
- **AI Chatbot widget**

### Pages That Need Design Updates:

1. **changelog.html** - Simple dark design
2. **leaderboard.html** - Purple gradient design
3. **profile.html** - Dark design

### How to Match Design:

**Option 1: Copy Homepage Template**
Each page should have:
```html
<head>
    <!-- Same fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Rajdhani:wght@300;400;600&display=swap" rel="stylesheet">
    
    <!-- Same styles from index.html -->
</head>
<body>
    <!-- Starfield canvas -->
    <canvas id="starfield"></canvas>
    
    <!-- Same navigation header -->
    <header>...</header>
    
    <!-- Page content -->
    <div class="content" style="padding-top: 80px;">
        <!-- Your page-specific content here -->
    </div>
    
    <!-- Same starfield animation script from index.html -->
    <script>
        // Copy starfield animation from index.html
    </script>
</body>
```

**Option 2: Create Shared CSS File**
Create `HideoutAdsWebsite/styles.css` with all shared styles, then:
```html
<link rel="stylesheet" href="styles.css">
```

### Quick Fix Template

To quickly match any page to homepage:

1. **Copy these sections from `index.html`:**
   - `<head>` fonts link
   - Starfield canvas element
   - Navigation header
   - All CSS styles
   - Starfield animation script
   - Theme system script

2. **Wrap your page content in:**
```html
<div class="content" style="padding-top: 80px;">
    <section>
        <!-- Your page content -->
    </section>
</div>
```

3. **Use same color scheme:**
   - Primary: #00C6FF (cyan)
   - Secondary: #8A2BE2 (purple)
   - Accent: #FF007F (pink)
   - Background: #05050A (dark)

## 🔄 Data Flow Diagram

```
┌─────────────────┐
│   Game (TSX)    │
│  localStorage   │◄──┐
└────────┬────────┘   │
         │            │
         ▼            │
┌─────────────────┐   │
│  Profile Page   │   │ Same localStorage
│  (stats/refs)   │◄──┤
└─────────────────┘   │
                      │
┌─────────────────┐   │
│  Leaderboard    │───┘
│  (API needed)   │
└─────────────────┘
```

## 🚀 Implementation Priority

### Immediate (Do First):
1. ✅ Profile page created with stats
2. ✅ Referral system added
3. ✅ 9 new skins added

### Next Steps:
1. Match changelog.html to homepage design
2. Match leaderboard.html to homepage design
3. Match profile.html to homepage design
4. Test all pages for consistency

### Future (Backend Required):
1. Set up API for real-time leaderboard
2. Cloud save system (optional)
3. Cross-device sync (optional)

## 📝 Notes

- **Current sync works perfectly** for single-device play
- **localStorage** persists between web/standalone on same PC
- **Leaderboard needs backend API** for global data
- All new features (skins, referrals, stats) are ready and working!

Your game and website are set up for success! The main task is just matching the visual design of the secondary pages to your beautiful homepage.
