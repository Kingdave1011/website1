# How to Improve Main Menu Visuals - Step by Step

## What We've Done So Far

✅ **Fixed all code errors**
✅ **Enhanced MainMenu.gd** with settings and maps button support
✅ **Sound effects are ready** to use

## What You Need to Do in Godot

The MainMenu.gd script is ready, but you need to **add the visual buttons in Godot editor**.

### Step 1: Open Godot and Your Project
1. Launch Godot
2. Open D:\GalacticCombat project
3. Wait for assets to import

### Step 2: Open MainMenu.tscn
1. In the FileSystem panel (bottom-left), find `MainMenu.tscn`
2. Double-click to open it

### Step 3: Add Settings and Maps Buttons
1. In the Scene tree (top-left), you'll see: `VBoxContainer`
2. Select `VBoxContainer`
3. Click the `+` icon to add a child node
4. Search for `Button` and add it
5. Rename it to `SettingsButton` (in Inspector panel, change "Name" property)
6. Repeat to add `MapsButton`

### Step 4: Arrange the Buttons
Your button order should be:
```
VBoxContainer
├── TitleLabel
├── PlayButton
├── SettingsButton  ← NEW
├── MapsButton      ← NEW
└── QuitButton
```

To reorder: Drag and drop buttons in the Scene tree

### Step 5: Style the Buttons
For each button:
1. Select the button
2. In Inspector panel:
   - **Text**: Set to "SETTINGS" or "MAPS"
   - **Theme Overrides → Font Sizes**: Set to 32
   - **Theme Overrides → Colors → Font Color**: Set to cyan/blue (0, 1, 1, 1)
   - **Custom Minimum Size**: Set width to 200, height to 60

### Step 6: Change Title to "GALACTIC COMBAT"
1. Select `TitleLabel`
2. In Inspector → Text: Change from "SPACE SHOOTER" to "GALACTIC COMBAT"
3. Font Size: Increase to 64 or 72

### Step 7: Save and Test
1. Press Ctrl+S to save
2. Press F5 to run the game
3. You should now see 4 buttons instead of 2!

## Quick Visual Improvements You Can Make

### A. Better Title Styling
1. Select TitleLabel
2. Inspector → Theme Overrides:
   - Font Size: 72
   - Colors → Font Color: Cyan (0, 1, 1, 1) or Gold (1, 0.84, 0, 1)
   - Outline Size: 4
   - Outline Color: Black (0, 0, 0, 1)

### B. Better Background
1. Select the root Control node
2. Add a ColorRect as child
3. Move it to the top of the scene tree (drag above everything)
4. In Inspector:
   - Layout → Anchors Preset: Full Rect
   - Color: Dark blue gradient or space black

### C. Add Background Image
1. Add a TextureRect as child of root
2. Move to top of scene tree
3. In Inspector:
   - Texture: Load a space background from Assets
   - Layout → Anchors Preset: Full Rect
   - Expand Mode: Ignore Size
   - Stretch Mode: Scale

### D. Add Ship Preview
1. Add a Sprite2D node to the scene
2. Position it on the left or right side
3. Texture: Load a ship from `Assets/kenney_space-shooter-redux/PNG/`
4. Scale it up (e.g., Scale: 2, 2)
5. Add a rotation animation in MainMenu.gd

## Alternative: Import Pre-Made Menu

If the above is too complex, you can:
1. Check if you have a Settings.tscn file
2. Copy its layout style to MainMenu.tscn
3. Or use Scene → Import to bring in a better menu template

## Testing Your Changes

After making changes:
1. **Save the scene** (Ctrl+S)
2. **Run the game** (F5)
3. **Check the output** tab for any errors
4. **Test all buttons** work correctly

## Common Issues

**Buttons don't appear?**
- Make sure button names match exactly: SettingsButton, MapsButton
- Check that buttons are children of VBoxContainer
- Save the scene and restart Godot

**Buttons don't work?**
- The script (MainMenu.gd) already has the code
- Just need to add the button nodes to the scene
- Button names must match exactly

**Want professional menu?**
- Copy button styling from Settings.tscn if it exists
- Or start a new task and I can create a complete professional menu for you

## Next Steps

Once you have the basic buttons working:
1. We can add a map selection screen
2. We can add ship selection
3. We can add better backgrounds
4. We can add particle effects
5. We can add background music

For now, focus on adding the two buttons (Settings and Maps) to MainMenu.tscn in Godot!
