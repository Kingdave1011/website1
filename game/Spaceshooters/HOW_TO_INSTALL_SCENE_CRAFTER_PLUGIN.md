# 🔌 How to Install Scene Crafter Plugin

## 📦 What is Scene Crafter?

Scene Crafter is a Godot plugin that might help you build scenes faster! Let's install it.

---

## ⚡ Quick Installation Steps

### Step 1: Extract the ZIP File

1. Open **Windows File Explorer**
2. Navigate to: `C:\Users\kinlo\Downloads\`
3. Find: `scene-crafter-main.zip`
4. **Right-click** → **Extract All**
5. Extract to: `C:\Users\kinlo\Downloads\scene-crafter-main\`

---

### Step 2: Copy Plugin to Your Project

**After extracting, you should have:**
```
C:\Users\kinlo\Downloads\scene-crafter-main\
└── addons/
    └── scene_crafter/
        └── (plugin files)
```

**Now copy it:**

1. In the extracted folder, find the `addons` folder
2. **Copy** the entire `addons` folder
3. Navigate to: `d:/GalacticCombat/`
4. **Paste** the `addons` folder there

**Final structure:**
```
d:/GalacticCombat/
├── addons/
│   └── scene_crafter/
│       └── (plugin files)
├── Lobby.gd
├── Player.gd
└── (other files)
```

---

### Step 3: Enable Plugin in Godot

1. Open **Godot**
2. Load project: `d:/GalacticCombat`
3. Click **Project** menu (top)
4. Click **Project Settings**
5. Click **Plugins** tab (left side)
6. Find **Scene Crafter** in the list
7. Click the **checkbox** to enable it
8. Click **Close**

**Plugin is now active!** ✅

---

## 🎯 Alternative Method - Let Godot Do the Work

**If the plugin has a different structure:**

1. Extract the ZIP to: `d:/GalacticCombat/addons/scene_crafter/`
2. Make sure `plugin.cfg` file exists in `addons/scene_crafter/`
3. Open Godot
4. Godot auto-detects plugins in addons/ folder
5. Project → Project Settings → Plugins
6. Enable it!

---

## ✅ How to Know It Worked

After enabling:
- Check for new tools/buttons in Godot interface
- Look for Scene Crafter options in menus
- No errors in Output panel (bottom)

---

## 🔧 Troubleshooting

### "I don't see the plugin in the Plugins list"

**Check structure:**
```
d:/GalacticCombat/
└── addons/
    └── scene_crafter/  ← Must have this exact name
        ├── plugin.cfg  ← Must exist
        └── (other files)
```

### "Plugin shows errors"

- Make sure you're using Godot 4.x (not 3.x)
- Check if plugin is compatible with your Godot version
- Read any README files in the plugin folder

### "Can't find addons folder in extracted ZIP"

- Look inside the extracted folder for any folder named `addons`
- Sometimes plugins have different structures
- Create `addons/scene_crafter/` manually and copy plugin files there

---

## 💡 What This Plugin Might Do

Scene Crafter likely helps with:
- Creating scenes faster
- Templates for common structures
- Quick node setups
- Scene generation tools

**After installing, explore the plugin to see what it offers!**

---

## 🚀 After Installation

**Try it out:**
1. Create a new scene
2. Look for Scene Crafter tools/menu
3. Use it to speed up scene creation!

**But remember:** You can still create scenes manually if the plugin doesn't work. The guides I created don't require any plugins! ✨

---

## ⚠️ Important Note

**I cannot:**
- Extract ZIP files on your computer
- Copy files to your project
- Enable plugins in Godot

**Only you can do these steps** - but they're easy! Just:
1. Extract ZIP (right-click → Extract)
2. Copy addons folder to your project
3. Enable in Godot settings

**Takes 2 minutes!** ⏱️

---

## ✨ Summary

1. Extract `scene-crafter-main.zip`
2. Copy `addons/` folder to `d:/GalacticCombat/`
3. Enable in Godot: Project → Project Settings → Plugins
4. Done! 🎉

**This might make scene creation easier, but you can still follow my guides without it!**
