# How to Add UI Elements in Godot - Step by Step

## 📋 What You're Adding

You need to add these UI elements to see timer, waves, and difficulty:
1. **WaveLabel** - Shows current wave number
2. **GameTimerLabel** - Shows elapsed time
3. **PausePanel** - Pause menu with buttons
4. **WaveTransitionLabel** - "Wave X Starting!" message
5. **DifficultyLabel** - Shows difficulty level

## 🎯 STEP-BY-STEP INSTRUCTIONS

### Part 1: Open the Scene

1. **Open Godot Engine**
2. **Open your project** (D:/GalacticCombat)
3. **In FileSystem** (bottom-left), double-click **Main.tscn**
4. You'll see the Scene Tree on the left side

### Part 2: Add Wave Label

1. **In Scene Tree** (left side), click on **UI** node
2. **Right-click** on UI → **Add Child Node**
3. **Search bar** appears → type `Label`
4. **Click** Label → **Click** "Create" button
5. **In Inspector** (right side):
   - **Name**: Change to `WaveLabel`
   - **Text**: Type `Wave: 1`
   - **Position**: X=20, Y=60
   - **Size**: X=150, Y=30
6. **Done!** First label added ✅

### Part 3: Add Game Timer Label

1. **Right-click** on UI again → **Add Child Node**
2. **Search** → type `Label` → **Create**
3. **In Inspector**:
   - **Name**: Change to `GameTimerLabel`
   - **Text**: Type `Time: 00:00`
   - **Position**: X=550, Y=20 (center-ish)
   - **Size**: X=200, Y=30
4. **Done!** Timer label added ✅

### Part 4: Add Wave Transition Label

1. **Right-click** on UI → **Add Child Node**
2. **Search** → `Label` → **Create**
3. **In Inspector**:
   - **Name**: Change to `WaveTransitionLabel`
   - **Text**: Type `Wave 2 Starting!`
   - **Position**: X=440, Y=300 (center of screen)
   - **Size**: X=400, Y=60
   - **Visible**: UNCHECK this box (hide it by default)
   - **Font Size**: Set to 32 (makes text bigger)
4. **Done!** Transition label added ✅

### Part 5: Add Difficulty Label

1. **Right-click** on UI → **Add Child Node**
2. **Search** → `Label` → **Create**
3. **In Inspector**:
   - **Name**: Change to `DifficultyLabel`
   - **Text**: Type `Difficulty: Normal`
   - **Position**: X=20, Y=90
   - **Size**: X=200, Y=30
4. **Done!** Difficulty label added ✅

### Part 6: Add Pause Panel (More Steps)

1. **Right-click** on UI → **Add Child Node**
2. **Search** → type `Panel` → **Create**
3. **In Inspector**:
   - **Name**: Change to `PausePanel`
   - **Position**: X=340, Y=160 (center-ish)
   - **Size**: X=600, Y=400
   - **Visible**: UNCHECK this box (hide by default)

4. **Now add children to PausePanel**:

   **A) Add Pause Title:**
   - **Right-click** PausePanel → **Add Child Node**
   - **Search** → `Label` → **Create**
   - **In Inspector**:
     - **Name**: `PauseTitle`
     - **Text**: `PAUSED`
     - **Position**: X=250, Y=20
     - **Font Size**: 48

   **B) Add Resume Button:**
   - **Right-click** PausePanel → **Add Child Node**
   - **Search** → `Button` → **Create**
   - **In Inspector**:
     - **Name**: `ResumeButton`
     - **Text**: `Resume`
     - **Position**: X=200, Y=120
     - **Size**: X=200, Y=50

   **C) Add Main Menu Button:**
   - **Right-click** PausePanel → **Add Child Node**
   - **Search** → `Button` → **Create**
   - **In Inspector**:
     - **Name**: `MainMenuButton`
     - **Text**: `Main Menu`
     - **Position**: X=200, Y=190
     - **Size**: X=200, Y=50

   **D) Add Quit Button:**
   - **Right-click** PausePanel → **Add Child Node**
   - **Search** → `Button` → **Create**
   - **In Inspector**:
     - **Name**: `QuitButton`
     - **Text**: `Quit Game`
     - **Position**: X=200, Y=260
     - **Size**: X=200, Y=50

5. **Done!** Pause panel complete ✅

### Part 7: Save Your Scene

1. **Press** Ctrl+S (or File → Save)
2. **Close** and **reopen** Main.tscn to make sure it saved
3. **All UI elements added!** ✅

## 🎮 What Happens Now?

- **Wave label** will show wave numbers automatically
- **Timer** will count up during gameplay
- **ESC key** will show/hide pause panel
- **Wave transition** appears between waves
- **Difficulty** shows your selected difficulty

## 🔍 How to Find Your New Elements

In Scene Tree, under UI node, you should now see:
```
UI
├── ScoreLabel (already existed)
├── HealthLabel (already existed)
├── TimeLabel (already existed)
├── GameOverPanel (already existed)
├── WaveLabel (NEW!)
├── GameTimerLabel (NEW!)
├── WaveTransitionLabel (NEW!)
├── DifficultyLabel (NEW!)
└── PausePanel (NEW!)
    ├── PauseTitle
    ├── ResumeButton
    ├── MainMenuButton
    └── QuitButton
```

## ⚙️ Next: Connect the Buttons

The pause panel buttons need to be connected:

1. **Click** PausePanel → ResumeButton
2. **In Inspector** → **Node** tab (top right)
3. **Double-click** `pressed()` signal
4. **Connect to**: GameManager
5. **Method**: Create new method called `resume_game`

Repeat for other buttons, or the code will handle it automatically!

## 🎯 Quick Test

1. **Press F5** to run the game
2. **Look for**:
   - Wave label top-left
   - Timer at top-center
   - Difficulty top-left under wave
3. **Press ESC** → Pause panel should appear (if connected)

That's it! All UI elements are now in your game! 🎉
