# 🎯 Make Lobby - SIMPLEST Steps Possible

## ✅ Follow These Steps EXACTLY

### Step 1: Create New Scene (30 seconds)

1. Open Godot
2. Load project: `d:/GalacticCombat`
3. Click **Scene** menu (top)
4. Click **New Scene**
5. Click **"User Interface"** button
6. You now have a **Control** node

---

### Step 2: Attach Lobby Script (10 seconds)

1. Look at **FileSystem** panel (bottom-left)
2. Find file: `Lobby.gd`
3. **DRAG** Lobby.gd onto the **Control** node
4. See scroll icon 📜? Script attached! ✓

---

### Step 3: Add Nodes (5 minutes)

**Just copy this pattern 7 times:**

#### Node 1: VBoxContainer
1. Right-click **Control**
2. "Add Child Node"
3. Type: `VBoxContainer`
4. Click "Create"

#### Node 2: Label
1. Right-click **VBoxContainer**
2. "Add Child Node"
3. Type: `Label`
4. Click "Create"
5. Rename to: `Title`

#### Node 3: Panel
1. Right-click **VBoxContainer**
2. "Add Child Node"
3. Type: `Panel`
4. Click "Create"
5. Rename to: `PlayerList`

#### Node 4: ScrollContainer
1. Right-click **PlayerList**
2. "Add Child Node"
3. Type: `ScrollContainer`
4. Click "Create"

#### Node 5: VBoxContainer
1. Right-click **ScrollContainer**
2. "Add Child Node"
3. Type: `VBoxContainer`
4. Click "Create"
5. Rename to: `PlayerContainer`

#### Node 6: Panel
1. Right-click **VBoxContainer** (the main one, not PlayerContainer)
2. "Add Child Node"
3. Type: `Panel`
4. Click "Create"
5. Rename to: `MapSelection`

#### Node 7: GridContainer
1. Right-click **MapSelection**
2. "Add Child Node"
3. Type: `GridContainer`
4. Click "Create"
5. Rename to: `MapGrid`
6. In **Inspector** (right side) → Find "Columns" → Set to: `2`

#### Node 8: Panel
1. Right-click **VBoxContainer** (main one)
2. "Add Child Node"
3. Type: `Panel`
4. Click "Create"
5. Rename to: `ChatPanel`

#### Node 9: TextEdit
1. Right-click **ChatPanel**
2. "Add Child Node"
3. Type: `TextEdit`
4. Click "Create"
5. Rename to: `ChatBox`
6. In **Inspector** → Uncheck "Editable"

#### Node 10: HBoxContainer
1. Right-click **ChatPanel**
2. "Add Child Node"
3. Type: `HBoxContainer`
4. Click "Create"

#### Node 11: LineEdit
1. Right-click **HBoxContainer** (the one under ChatPanel)
2. "Add Child Node"
3. Type: `LineEdit`
4. Click "Create"
5. Rename to: `ChatInput`

#### Node 12: Button
1. Right-click **HBoxContainer** (same one)
2. "Add Child Node"
3. Type: `Button`
4. Click "Create"
5. Rename to: `SendButton`

#### Node 13: HBoxContainer
1. Right-click **VBoxContainer** (main one)
2. "Add Child Node"
3. Type: `HBoxContainer`
4. Click "Create"
5. Rename to: `Controls`

#### Node 14: Button
1. Right-click **Controls**
2. "Add Child Node"
3. Type: `Button`
4. Click "Create"
5. Rename to: `StartButton`
6. In **Inspector** → "Text" → Type: "Start Game"

#### Node 15: Button
1. Right-click **Controls**
2. "Add Child Node"
3. Type: `Button`
4. Click "Create"
5. Rename to: `ReadyButton`
6. In **Inspector** → "Text" → Type: "Ready"

#### Node 16: Button
1. Right-click **Controls**
2. "Add Child Node"
3. Type: `Button`
4. Click "Create"
5. Rename to: `LeaveButton`
6. In **Inspector** → "Text" → Type: "Leave"

---

### Step 4: Save Scene (5 seconds)

1. Press **Ctrl+S**
2. Save as: `Lobby.tscn`
3. Click "Save"
4. Done! ✓

---

## ✅ Final Result

Your Scene tree should look like:

```
Control [Lobby.gd] 📜
└── VBoxContainer
    ├── Title (Label)
    ├── PlayerList (Panel)
    │   └── ScrollContainer
    │       └── PlayerContainer (VBoxContainer)
    ├── MapSelection (Panel)
    │   └── MapGrid (GridContainer)
    ├── ChatPanel (Panel)
    │   ├── ChatBox (TextEdit)
    │   └── HBoxContainer
    │       ├── ChatInput (LineEdit)
    │       └── SendButton (Button)
    └── Controls (HBoxContainer)
        ├── StartButton (Button)
        ├── ReadyButton (Button)
        └── LeaveButton (Button)
```

---

## 🎯 That's It!

**You just created the multiplayer lobby!** 🎉

**Next:** Create 5 simple maps (even easier - only 3 nodes each!)

---

## 🔧 If You Get Errors

**Most common issue:** Node names don't match exactly

**Check these names are PERFECT:**
- `PlayerContainer` (not playercontainer)
- `MapGrid` (not Map_Grid)
- `ChatBox` (not Chat_Box)
- `ChatInput` (not Chat_Input)
- `StartButton` (not Start_Button)
- `ReadyButton` (not Ready_Button)
- `LeaveButton` (not Leave_Button)

**Names MUST match code exactly!** ✅

---

## 💡 Pro Tip

**Rename a node:**
1. Right-click the node
2. Click "Rename"
3. Type new name
4. Press Enter

**Easy!** ✨

---

## 🚀 You Did It!

Save the scene (Ctrl+S) and you're done!

**Next file to open:** `HOW_TO_CREATE_MAPS_IN_GODOT.md` (for the 5 maps)

Maps are MUCH easier - only 3 nodes each! 🎮
