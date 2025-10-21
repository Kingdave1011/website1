# 🖱️ Godot Basics - Where to Find "Add Child Node"

## 📍 Where is "Add Child Node"?

### Step-by-Step with Pictures Description

**1. Look at the Scene Panel (Top-Left)**

```
┌─────────────────────────────┐
│ Scene                    🔍 │ ← This is the Scene panel
├─────────────────────────────┤
│ ▼ Control                   │ ← Your root node
│                              │
│                              │
└─────────────────────────────┘
```

**2. RIGHT-CLICK on the node** (in this case, Control)

When you right-click, a menu appears:

```
┌───────────────────────┐
│ Add Child Node        │ ← Click this!
│ Instance Child Scene  │
│ Change Type          │
│ Rename               │
│ Delete               │
│ ...                  │
└───────────────────────┘
```

**3. Click "Add Child Node"** and this window opens:

```
┌────────────────────────────┐
│ Create New Node            │
├────────────────────────────┤
│ Search: [           ] 🔍  │ ← Type node name here
├────────────────────────────┤
│ Node                       │
│ ▼ CanvasItem              │
│   ▼ Node2D                │
│     ▼ Control             │ ← Find your node type
│       ▼ Container         │
│         VBoxContainer     │ ← Example
│         HBoxContainer     │
│                            │
├────────────────────────────┤
│        [Create]   [Cancel] │ ← Click Create
└────────────────────────────┘
```

---

## 🎯 Quick Example - Adding VBoxContainer

**Step 1:** Right-click **Control** in Scene panel

**Step 2:** Click **"Add Child Node"**

**Step 3:** Type in search box: `VBoxContainer`

**Step 4:** Click **"Create"** button

**Done!** VBoxContainer is now under Control! ✅

---

## 📍 Where Are the Panels in Godot?

Here's the Godot layout:

```
┌──────────────────────────────────────────────────────────┐
│ File  Scene  Project  Debug  Help                        │ ← Menu bar
├────────────┬─────────────────────────────────┬───────────┤
│  Scene     │                                 │ Inspector │
│  (tree)    │      Viewport                  │  (right)  │
│            │      (center)                   │           │
│  Control   │                                 │ Script:   │
│  └─VBox... │   [Your game appears here]     │ Lobby.gd  │
│            │                                 │           │
│            │                                 │ Properties│
├────────────┴─────────────────────────────────┴───────────┤
│  FileSystem                 Output                       │
│  (files)                    (errors/logs)                │
│  res://                                                   │
│  ├─ Lobby.gd                                            │
│  ├─ Player.gd                                           │
└──────────────────────────────────────────────────────────┘
```

**Key Panels:**
- **Scene** (top-left) - Your scene tree, right-click here
- **Inspector** (right) - Properties of selected node
- **FileSystem** (bottom-left) - Your project files
- **Viewport** (center) - Visual editor

---

## 🖱️ The Add Child Node Flow

**Every time you want to add a node:**

1. **Find parent node** in Scene panel (top-left)
2. **Right-click** the parent node
3. **Click** "Add Child Node" from menu
4. **Type** the node name you want (e.g., "Button")
5. **Click** "Create" button
6. **Rename** the node if needed (right-click → Rename)

**Repeat this for every node!**

---

## 🎯 Let's Practice - Add Your First Node

**You should have:**
- Godot open
- d:/GalacticCombat project loaded
- A new scene with a Control node

**Now do this:**

1. Look at **Scene panel** (top-left corner of Godot)
2. You should see: `Control`
3. **RIGHT-CLICK** on Control
4. A menu pops up
5. **CLICK** "Add Child Node" (first option)
6. A new window opens with a search box
7. **TYPE:** `VBoxContainer`
8. **CLICK** the "Create" button at the bottom
9. Done! VBoxContainer is now under Control!

**Did it work?** You should now see:
```
Control
└── VBoxContainer
```

If yes, **you've got it!** Just repeat this process for all other nodes! 🎉

---

## 📝 Common Node Types You'll Need

| Node Type | What It's For | Where to Use |
|-----------|---------------|--------------|
| VBoxContainer | Arranges children vertically | Main layout |
| HBoxContainer | Arranges children horizontally | Button rows |
| Label | Displays text | Titles, player names |
| Button | Clickable button | Ready, Start, Leave |
| Panel | Background panel | Visual grouping |
| TextEdit | Multi-line text box | Chat display |
| LineEdit | Single-line text input | Chat input |
| ScrollContainer | Scrollable area | Player list |
| GridContainer | Grid layout | Map selection |

---

## 🔍 Can't Find a Node Type?

**Use the search box!**

1. When "Create New Node" window is open
2. **Type** the node name in the search box at top
3. It filters the list automatically
4. Example: Type "Button" → Only button-related nodes show

**This is way faster than scrolling!**

---

## ✅ Quick Checklist

To add a child node:
- [ ] Right-click parent node in Scene panel
- [ ] Click "Add Child Node"
- [ ] Type node name in search
- [ ] Click "Create"
- [ ] Rename if needed
- [ ] Repeat for next node

---

## 🎮 You're Learning Godot!

**These are THE most basic Godot skills:**
1. Create scene
2. Add nodes
3. Rename nodes
4. Attach scripts
5. Save scene

**You're literally learning the fundamentals right now!** 🎓

Once you understand "right-click → Add Child Node", you can build ANYTHING in Godot!

---

## 🚀 Next Step

After you've added one node successfully:
1. Repeat the process for all other nodes
2. Follow the node tree structure in `HOW_TO_ATTACH_LOBBY_SCRIPT.md`
3. Make sure names match exactly
4. Save when done

**You've got this!** 💪

---

## 💡 Pro Tip

**Don't try to memorize everything!**

Just keep this guide open and follow it step-by-step:
- Right-click parent
- Add Child Node
- Search for type
- Create
- Rename
- Next!

**It becomes automatic after a few times!** ✨
