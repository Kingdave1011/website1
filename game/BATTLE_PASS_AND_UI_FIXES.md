# Battle Pass System & UI Fixes Implementation Guide

## Overview
This guide explains how to implement a monthly battle pass system with automatic resets and fix the UI display issues.

## Battle Pass System Already Implemented ✅

The game already has a functional battle pass system in `index.tsx`:

### Current Features:
- **BATTLE_PASS_REWARDS array** - Defines 7 tiers of rewards (levels 2, 4, 6, 8, 10, 12, 15)
- **battlePassTier tracking** - Tracks player progress
- **claimedBattlePassTiers** - Prevents duplicate claims
- **updateBattlePass()** function - Automatically grants rewards when level requirements are met
- **Reward types**: Credits, Boosters, Skins

### What's Missing:
1. **UI Modal** - Visual interface to see battle pass progress
2. **Monthly Reset** - System to reset battle pass each month
3. **Better Visibility** - Button to access battle pass from main menu

## How to Add Battle Pass UI & Monthly Reset

### Step 1: Add Battle Pass Modal to HTML

Add this to `website/game/index.html` after the other modals:

```html
<div id="battle-pass-modal" class="modal hidden">
    <div class="modal-content">
        <span class="close-button">&times;</span>
        <h2>🎖️ Battle Pass - Season <span id="bp-season">1</span></h2>
        <p style="text-align: center; color: #FFD700;">Resets Monthly | Your Level: <span id="bp-player-level">1</span></p>
        <div id="battle-pass-tiers"></div>
    </div>
</div>
```

### Step 2: Add Battle Pass Button to Main Menu

In `index.html`, add this button in the `.menu-buttons` section:

```html
<button id="battle-pass-button">🎖️ Battle Pass</button>
```

### Step 3: Add Monthly Reset Logic to `index.tsx`

Add this to the PlayerState interface (already exists, but add these fields):

```typescript
interface PlayerState {
    // ... existing fields ...
    battlePassSeason: number;
    battlePassLastReset: string; // Store as ISO date string
}
```

Add this function to check and reset battle pass monthly:

```typescript
function checkBattlePassReset() {
    const now = new Date();
    const currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
    
    if (!gameState.battlePassLastReset || gameState.battlePassLastReset !== currentMonth) {
        // Reset battle pass for new month
        gameState.battlePassSeason = (gameState.battlePassSeason || 0) + 1;
        gameState.claimedBattlePassTiers = [];
        gameState.battlePassLastReset = currentMonth;
        savePlayerState();
        
        // Show notification
        showBattlePassResetNotification();
    }
}

function showBattlePassResetNotification() {
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
        color: #000;
        padding: 30px 50px;
        border-radius: 15px;
        font-family: 'Orbitron', sans-serif;
        font-size: 1.5rem;
        z-index: 10003;
        box-shadow: 0 0 50px rgba(255, 215, 0, 0.8);
        text-align: center;
    `;
    notification.innerHTML = `
        <div style="font-size: 3rem;">🎖️</div>
        <div>NEW BATTLE PASS SEASON!</div>
        <div style="font-size: 1rem; margin-top: 10px;">Season ${gameState.battlePassSeason}</div>
    `;
    document.body.appendChild(notification);
    
    setTimeout(() => notification.remove(), 4000);
}
```

### Step 4: Add Battle Pass UI Population Function

```typescript
function populateBattlePass() {
    const tiersContainer = document.getElementById('battle-pass-tiers')!;
    tiersContainer.innerHTML = '';
    
    (document.getElementById('bp-season') as HTMLElement).textContent = (gameState.battlePassSeason || 1).toString();
    (document.getElementById('bp-player-level') as HTMLElement).textContent = gameState.level.toString();
    
    BATTLE_PASS_REWARDS.forEach((reward, index) => {
        const tierEl = document.createElement('div');
        tierEl.style.cssText = `
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 15px;
            margin: 10px 0;
            border: 2px solid ${gameState.claimedBattlePassTiers.includes(index) ? '#00FF00' : '#FFD700'};
            border-radius: 10px;
            background: ${gameState.level >= reward.level ? 'rgba(0, 255, 0, 0.1)' : 'rgba(255, 215, 0, 0.05)'};
        `;
        
        const locked = gameState.level < reward.level;
        const claimed = gameState.claimedBattlePassTiers.includes(index);
        
        tierEl.innerHTML = `
            <div>
                <div style="font-size: 1.2rem; color: #FFD700;">Tier ${index + 1} - Level ${reward.level}</div>
                <div style="font-size: 0.9rem; color: #E0E0E0;">${reward.description}</div>
            </div>
            <div style="font-size: 2rem;">
                ${claimed ? '✅' : locked ? '🔒' : '🎁'}
            </div>
        `;
        
        tiersContainer.appendChild(tierEl);
    });
}
```

### Step 5: Add Event Listeners

In `setupEventListeners()`, add:

```typescript
document.getElementById('battle-pass-button')!.addEventListener('click', () => {
    checkBattlePassReset(); // Check for reset before opening
    populateBattlePass();
    openModal('battle-pass-modal');
});
```

### Step 6: Update `getDefaultPlayerState()`

Add these fields to the default state:

```typescript
function getDefaultPlayerState(): PlayerState {
    return {
        // ... existing fields ...
        battlePassSeason: 1,
        battlePassLastReset: `${new Date().getFullYear()}-${String(new Date().getMonth() + 1).padStart(2, '0')}`,
    };
}
```

### Step 7: Check Reset on Login

In `showStartScreen()`, add:

```typescript
function showStartScreen() {
    // ... existing code ...
    
    checkBattlePassReset(); // Check if new month
    
    // ... rest of existing code ...
}
```

## UI Display Fixes

### Fix 1: Remove Info Icons from Booster Labels

The info icons (ℹ️) are showing because they're rendered as text. To hide them:

**Option A: Remove from HTML**
In `index.html`, find the booster labels and remove any ℹ️ characters.

**Option B: Hide with CSS**
Add to `index.css`:

```css
.booster-title {
    font-size: 1rem;
    color: #00C6FF;
    margin-bottom: 10px;
    text-align: center;
}

/* Hide info icons if they exist */
.booster-item label::after {
    content: '';
}
```

### Fix 2: Style Welcome Message Better

The welcome message needs better visibility. Update the styling:

Add to `index.css`:

```css
#welcome-message {
    font-size: 1.3rem;
    color: #00FF00;
    text-shadow: 0 0 10px #00FF00;
    margin: 20px 0;
    padding: 15px;
    background: rgba(0, 255, 0, 0.1);
    border: 2px solid #00FF00;
    border-radius: 10px;
    animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.7; }
}
```

## Monthly Reset Summary

The battle pass will now automatically:
1. ✅ Check for month change when player logs in
2. ✅ Reset claimed tiers to empty array
3. ✅ Increment season number
4. ✅ Show notification of new season
5. ✅ Save the current month to prevent multiple resets

## Reward Distribution

Rewards are automatically given when:
- Player reaches the required level
- Tier hasn't been claimed yet
- `updateBattlePass()` is called (happens after gaining XP)

## Testing the System

### To test monthly reset:
1. Manually change `battlePassLastReset` in localStorage to last month
2. Reload the page
3. Should see "NEW BATTLE PASS SEASON!" notification
4. All tiers should be unclaimed again

### To test rewards:
1. Use console: `gameState.level = 15`
2. Call `updateBattlePass()`
3. All rewards up to level 15 should be granted

## Current Rewards Structure

```typescript
{ level: 2, type: 'credits', amount: 250 }
{ level: 4, type: 'booster', booster: 'shield', amount: 2 }
{ level: 6, type: 'credits', amount: 500 }
{ level: 8, type: 'booster', booster: 'rapidFire', amount: 2 }
{ level: 10, type: 'credits', amount: 1000 }
{ level: 12, type: 'booster', booster: 'doubleCredits', amount: 2 }
{ level: 15, type: 'skin', ship: 'ranger', skinName: 'Ranger Elite' }
```

## Future Enhancements

Consider adding:
- Premium Battle Pass tier (requires payment)
- More reward tiers (up to level 30+)
- Exclusive skins each season
- Battle Pass XP multipliers
- Season-specific challenges
- Leaderboard for fastest completion

## Notes

- Battle pass progress is saved per account
- Works for both registered players and guests
- Fully automatic - no manual intervention needed
- Compatible with existing save system
