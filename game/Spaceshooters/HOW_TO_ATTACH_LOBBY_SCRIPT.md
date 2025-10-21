# 📎 How to Attach Lobby.gd Script - Step by Step

## 🎯 Simple Method (Drag & Drop)

### Step 1: Create the Lobby Scene

1. In Godot, click **Scene** menu → **New Scene** (or press Ctrl+N)
2. Click the **"User Interface"** button
3. This creates a **Control** node as the root

### Step 2: Attach the Script (2 Ways)

**Method A - Drag & Drop (Easiest):**

1. Look at the **FileSystem** panel (bottom-left in Godot)
2. Find `Lobby.gd` file in the file list
3. **Click and DRAG** `Lobby.gd` onto the **Control** node in the Scene panel
4. **Drop it!**
5. Done! ✓ The script is now attached

**Method B - Using Inspector:**

1. Select the **Control** node in the Scene panel (top-left)
2. Look at the **Inspector** panel (right side)
3. At the very top, you'll see a **"Script"** property
4. Click the **folder icon** next to Script
5. Navigate to and select `Lobby.gd`
6. Click **"Open"**
7. Done! ✓ The script is now attached

---

## ✅ How to Verify Script is Attached

After attaching, you should see:
- A small **scroll icon** 📜 next to the Control node name
- In Inspector, the Script property shows: `res://Lobby.gd`

If you see these, **it worked!** ✓

---

## 🏗️ Complete Lobby Scene Structure

After attaching the script, build this node structure:

```
Control (Lobby) [with Lobby.gd attached] 📜
└── VBoxContainer
    ├── Title (Label)
    ├── HBoxContainer (for main content)
    │   ├── PlayerList (Panel)
    │   │   └── ScrollContainer
    │   │       └── PlayerContainer (VBoxContainer)
    │   └── MapSelection (Panel)
    │       └── MapGrid (GridContainer - set columns: 2)
    ├── ChatPanel (Panel)
    │   ├── ChatBox (TextEdit - set editable: false)
    │   └── HBoxContainer
    │       ├── ChatInput (LineEdit)
    │       └── SendButton (Button)
    └── Controls (HBoxContainer)
        ├── StartButton (Button)
        ├── ReadyButton (Button)
        └── LeaveButton (Button)
```

**IMPORTANT:** The node names MUST match exactly as shown above!

---

## 🎯 Step-by-Step Node Creation

### 1. Add VBoxContainer

1. Right-click the **Control** node
2. Select **"Add Child Node"**
3. Search for: `VBoxContainer`
4. Click **"Create"**

### 2. Add Title Label

1. Right-click **VBoxContainer**
2. **Add Child Node** → Search: `Label`
3. Create it
4. Rename to: `Title`
5. In Inspector → **Text** property → Type: "Multiplayer Lobby"

### 3. Add Main HBoxContainer

1. Right-click **VBoxContainer**
2. **Add Child Node** → `HBoxContainer`
3. Keep the name as **HBoxContainer**

### 4. Add PlayerList Panel

1. Right-click **HBoxContainer**
2. **Add Child Node** → `Panel`
3. Rename to: `PlayerList`
4. Right-click **PlayerList** → Add Child → `ScrollContainer`
5. Right-click **ScrollContainer** → Add Child → `VBoxContainer`
6. Rename that VBoxContainer to: `PlayerContainer`

### 5. Add MapSelection Panel

1. Right-click **HBoxContainer** (the same one as before)
2. **Add Child Node** → `Panel`
3. Rename to: `MapSelection`
4. Right-click **MapSelection** → Add Child → `GridContainer`
5. Rename to: `MapGrid`
6. In Inspector, find **Columns** property → Set to: `2`

### 6. Add ChatPanel

1. Right-click **VBoxContainer** (the main one under Control)
2. **Add Child Node** → `Panel`
3. Rename to: `ChatPanel`
4. Right-click **ChatPanel** → Add Child → `TextEdit`
5. Rename to: `ChatBox`
6. In Inspector → **Editable** → Uncheck it (set to false)
7. Right-click **ChatPanel** → Add Child → `HBoxContainer`
8. Right-click that **HBoxContainer** → Add Child → `LineEdit`
9. Rename to: `ChatInput`
10. Right-click **HBoxContainer** → Add Child → `Button`
11. Rename to: `SendButton`
12. Set Button text to: "Send"

### 7. Add Controls HBoxContainer

1. Right-click **VBoxContainer** (main one)
2. **Add Child Node** → `HBoxContainer`
3. Rename to: `Controls`
4. Right-click **Controls** → Add Child → `Button`
5. Rename to: `StartButton`
6. Set text: "Start Game"
7. Right-click **Controls** → Add Child → `Button`
8. Rename to: `ReadyButton`
9. Set text: "Ready"
10. Right-click **Controls** → Add Child → `Button`
11. Rename to: `LeaveButton`
12. Set text: "Leave"

### 8. Save the Scene

1. Press **Ctrl+S** or **Scene** → **Save Scene**
2. Save as: `Lobby.tscn` in the root directory
3. Done! ✓

---

## 🔧 Troubleshooting

### "I don't see the scroll icon after attaching"
- Try saving the scene (Ctrl+S)
- Close and reopen the scene
- The icon should appear

### "Script shows error: 'Cannot find nodes'"
- Check that ALL node names match exactly
- Names are case-sensitive!
- Common mistakes:
  - `playerlist` vs `PlayerList` (wrong!)
  - `Shoot Button` vs `ShootButton` (wrong! - no space)

### "I can't find Lobby.gd in FileSystem"
- Look in the root of your project (res://)
- It should be there with other .gd files
- If not, check `d:/GalacticCombat/Lobby.gd` exists

---

## 📸 Visual Checklist

After you're done, verify:
- [ ] Control node has scroll icon 📜
- [ ] Inspector shows: Script: res://Lobby.gd
- [ ] VBoxContainer exists under Control
- [ ] PlayerContainer (VBoxContainer) exists
- [ ] MapGrid (GridContainer) exists with Columns = 2
- [ ] ChatBox (TextEdit) exists with editable = false
- [ ] ChatInput (LineEdit) exists
- [ ] Three buttons exist: StartButton, ReadyButton, LeaveButton
- [ ] Scene saved as Lobby.tscn

---

## ✨ Quick Tip

**Don't worry about making it look pretty!**

The nodes just need to exist with the right names. You can make it look nice later by:
- Setting sizes
- Adding colors
- Positioning elements
- Adding margins/padding

**First make it work, then make it pretty!** ✨

---

## 🎮 After This Step

Once Lobby.tscn is created with the script attached, you're 50% done!

**Next:** Create the 5 simple map scenes (even easier than this!)

**Then:** Press F5 and test your multiplayer! 🎉

---

## 🆘 Still Stuck?

The most common issue is **node names not matching**.

**Double-check these names are EXACT:**
- `PlayerContainer` (not Player_Container or playercontainer)
- `MapGrid` (not Map_Grid or mapgrid)
- `ChatBox` (not Chat_Box or chatbox)
- `ChatInput` (not Chat_Input)
- `StartButton` (not Start_Button or start_button)
- `ReadyButton` (not Ready_Button)
- `LeaveButton` (not Leave_Button)

**If names match exactly = It will work!** ✅
