# How to Add Player Node and Pause Menu - Exact Steps

## 🎮 ADD PLAYER NODE

### Step 1: Open Main.tscn in Godot
1. In Godot FileSystem (bottom-left), double-click **Main.tscn**

### Step 2: Check if Player Exists
1. Look at **Scene Tree** (left side)
2. Do you see a node called "Player"?
   - **YES** → Go to Step 3
   - **NO** → Go to Step 4

### Step 3: If Player Exists - Fix Position
1. **Click on "Player"** node in Scene Tree
2. **In Inspector** (right side) → Find "Position" or "Transform"
3. **Set Y value to 600** (bottom of screen)
4. **Save** (Ctrl+S)
5. **Done!** Run game (F5)

### Step 4: If Player Missing - Add It
1. **Right-click** on root node (top node in Scene Tree)
2. **Click** "Instantiate Child Scene"
3. **Navigate** to find Player.tscn
4. **Click** Player.tscn → **Open**
5. **Player appears!**
6. **Click** Player in Scene Tree
7. **In Inspector** → Position Y = 600
8. **Save** (Ctrl+S)
9. **Done!** Run game (F5)

---

## 📋 ADD PAUSE MENU

### Step 1: Add PausePanel
1. **In Main.tscn**, look for **UI** node in Scene Tree
2. **Right-click UI** → **Add Child Node**
3. **Search for:** `Panel`
4. **Click** Panel → **Create**

### Step 2: Configure PausePanel
1. **Click** the new Panel node
2. **In Inspector** → **Name** field → Change to `PausePanel`
3. **Find** "Visible" checkbox → **UNCHECK IT** (hide by default)
4. **Set Size:** 
   - Custom Minimum Size → X: 600, Y: 400
5. **Set Position:**
   - Anchors Preset → Click "Center" (centers panel)

### Step 3: Add Pause Title
1. **Right-click PausePanel** → **Add Child Node**
2. **Search:** `Label` → **Create**
3. **Name:** `PauseTitle`
4. **Text:** `PAUSED`
5. **Font Size:** 48 (in Theme Overrides)
6. **Position:** Center it (X: 250, Y: 20)

### Step 4: Add Resume Button
1. **Right-click PausePanel** → **Add Child Node**
2. **Search:** `Button` → **Create**
3. **Name:** `ResumeButton`
4. **Text:** `Resume`
5. **Size:** X: 200, Y: 50
6. **Position:** X: 200, Y: 120

### Step 5: Add Main Menu Button
1. **Right-click PausePanel** → **Add Child Node**
2. **Search:** `Button` → **Create**
3. **Name:** `MainMenuButton`
4. **Text:** `Main Menu`
5. **Size:** X: 200, Y: 50
6. **Position:** X: 200, Y: 190

### Step 6: Add Quit Button
1. **Right-click PausePanel** → **Add Child Node**
2. **Search:** `Button` → **Create**
3. **Name:** `QuitButton`
4. **Text:** `Quit Game`
5. **Size:** X: 200, Y: 50
6. **Position:** X: 200, Y: 260

### Step 7: Connect Buttons (Optional)
The code will handle this automatically if names match!

But if you want to connect manually:
1. **Click ResumeButton**
2. **Node tab** (top-right) → **Signals**
3. **Double-click "pressed()"**
4. **Connect** to GameManager → `toggle_pause`

---

## ✅ DONE!

Now when you:
- **Press ESC** → Pause panel appears with buttons!
- **Your spaceship** → Visible at bottom!

Save (Ctrl+S) and run (F5)!

---

## 🚀 SUPER QUICK METHOD (If Above is Too Hard):

**Just add these to Main.tscn in Godot:**

1. **Right-click root** → Instantiate Child Scene → Choose Player.tscn
2. **Don't worry about pause menu** - ESC still pauses, press ESC again to unpause

Your game works! Enemies spawn, combat works, waves progress!
