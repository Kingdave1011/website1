# Where to Find Position in Inspector - Visual Guide

## 🔍 Can't Find "Position"? Here's Why:

Labels in CanvasLayer use **"Offset"** instead of "Position"!

## ✅ EXACT STEPS:

1. **Click on WaveLabel** in Scene Tree (left side)
2. **Look at Inspector** (right side)
3. **Look for "Layout" section** near the top
4. **Click the arrow (▼)** next to "Layout" to expand it
5. You'll see these properties:
   - **Offset Left**
   - **Offset Top**
   - **Offset Right**
   - **Offset Bottom**

## 📐 How to Set Position Using Offsets:

Instead of "Position X=20, Y=60", use:
- **Offset Left** = 20
- **Offset Top** = 60
- **Offset Right** = 170 (Left + Width, e.g., 20 + 150)
- **Offset Bottom** = 90 (Top + Height, e.g., 60 + 30)

## 🎯 QUICK REFERENCE FOR YOUR LABELS:

### WaveLabel:
- Offset Left: `20`
- Offset Top: `60`
- Offset Right: `170`
- Offset Bottom: `90`

### GameTimerLabel:
- Offset Left: `550`
- Offset Top: `20`
- Offset Right: `750`
- Offset Bottom: `50`

### WaveTransitionLabel:
- Offset Left: `440`
- Offset Top: `300`
- Offset Right: `840`
- Offset Bottom: `360`

### DifficultyLabel:
- Offset Left: `20`
- Offset Top: `90`
- Offset Right: `220`
- Offset Bottom: `120`

### PausePanel:
- Offset Left: `340`
- Offset Top: `160`
- Offset Right: `940`
- Offset Bottom: `560`

## 🖱️ EASIER METHOD - Just Drag!

**Instead of typing numbers**, you can:

1. **Click on WaveLabel** in Scene Tree
2. **In the main viewport** (center screen showing your game), you'll see a small box
3. **Just DRAG that box** to the top-left corner
4. **Done!** Position is set automatically

The code will still find your elements even if positions aren't perfect!

## ✨ DON'T WORRY ABOUT EXACT POSITIONS!

The most important things are:
1. ✅ **Names are correct** (WaveLabel, GameTimerLabel, etc.)
2. ✅ **Text is set** (Wave: 1, Time: 00:00, etc.)

Positions can be anywhere on screen - the code will still work! Just make sure the names match what the code expects.

## 🎮 ALTERNATIVE: Skip Position Setup!

**The UI will still work even if you don't set positions!** The code just needs:
- ✅ Correct node names
- ✅ Text property set

Position just controls WHERE on screen the text appears. If you leave it at default (0,0), the text will be at top-left corner, which is fine!

**Just press Ctrl+S to save and F5 to run your game!**
