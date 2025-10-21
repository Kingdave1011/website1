# UI Configuration Settings - Copy These Exact Values

## 🎯 For Each UI Element You Added:

Click on each element in the Scene Tree (left side), then change these values in the Inspector (right side):

---

## 1️⃣ WaveLabel

**Click on "WaveLabel" in Scene Tree, then in Inspector:**

### Node Tab (Properties):
- **Name**: `WaveLabel`
- **Text**: `Wave: 1`
- **Position**: X = `20`, Y = `60`
- **Size**: X = `150`, Y = `30`
- **Theme Overrides > Font Sizes > Font Size**: `16` (optional, makes text readable)

---

## 2️⃣ GameTimerLabel

**Click on "GameTimerLabel" in Scene Tree, then in Inspector:**

### Node Tab (Properties):
- **Name**: `GameTimerLabel`
- **Text**: `Time: 00:00`
- **Position**: X = `550`, Y = `20`
- **Size**: X = `200`, Y = `30`
- **Theme Overrides > Font Sizes > Font Size**: `16`

---

## 3️⃣ WaveTransitionLabel

**Click on "WaveTransitionLabel" in Scene Tree, then in Inspector:**

### Node Tab (Properties):
- **Name**: `WaveTransitionLabel`
- **Text**: `Wave 2 Starting!`
- **Position**: X = `440`, Y = `300`
- **Size**: X = `400`, Y = `60`
- **Visible**: ❌ UNCHECK THIS BOX (makes it hidden by default)
- **Theme Overrides > Font Sizes > Font Size**: `32` (big text)
- **Horizontal Alignment**: `Center` (optional, centers the text)

---

## 4️⃣ DifficultyLabel

**Click on "DifficultyLabel" in Scene Tree, then in Inspector:**

### Node Tab (Properties):
- **Name**: `DifficultyLabel`
- **Text**: `Difficulty: Normal`
- **Position**: X = `20`, Y = `90`
- **Size**: X = `200`, Y = `30`
- **Theme Overrides > Font Sizes > Font Size**: `16`

---

## 5️⃣ PausePanel (If you added it)

**Click on "PausePanel" in Scene Tree, then in Inspector:**

### Node Tab (Properties):
- **Name**: `PausePanel`
- **Position**: X = `340`, Y = `160`
- **Size**: X = `600`, Y = `400`
- **Visible**: ❌ UNCHECK THIS BOX (hidden by default)

### For children of PausePanel:

**PauseTitle (Label inside PausePanel):**
- **Text**: `PAUSED`
- **Position**: X = `250`, Y = `20`
- **Font Size**: `48`

**ResumeButton:**
- **Text**: `Resume`
- **Position**: X = `200`, Y = `120`
- **Size**: X = `200`, Y = `50`

**MainMenuButton:**
- **Text**: `Main Menu`
- **Position**: X = `200`, Y = `190`
- **Size**: X = `200`, Y = `50`

**QuitButton:**
- **Text**: `Quit Game`
- **Position**: X = `200`, Y = `260`
- **Size**: X = `200`, Y = `50`

---

## ✅ After Setting All Values:

1. **Press Ctrl+S** to save your scene
2. **Press F5** to run the game
3. You should now see:
   - Wave counter top-left
   - Timer at top
   - Difficulty below wave counter

---

## 🎮 Quick Test:

**Run the game (F5) and check:**
- ✅ "Wave: 1" visible top-left
- ✅ "Time: 00:00" visible at top
- ✅ "Difficulty: Normal" visible under wave
- ✅ "Wave 2 Starting!" NOT visible (hidden until wave changes)
- ✅ Pause panel NOT visible (hidden until you press ESC)

**Press ESC in game:**
- ✅ Pause panel should appear with buttons

---

## 💡 If You Need Help Finding Properties:

In the **Inspector** panel (right side):
- Scroll down to find properties
- Click the arrow (▼) next to sections to expand them
- **Theme Overrides** section is usually near the bottom
- **Position** and **Size** are usually near the top

All your game code is ready! Once you set these values, your game is 100% complete! 🎉
