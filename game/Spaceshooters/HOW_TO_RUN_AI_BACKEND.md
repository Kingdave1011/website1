# How to Run Scene Crafter AI Backend Server

## 🤖 Complete Guide to Running the AI Backend

The Scene Crafter AI backend enables natural language scene generation. Here's how to get it running!

---

## ✅ Prerequisites (Already Done!)

- ✅ Python installed
- ✅ Dependencies installed (flask, transformers, torch, groq)

---

## 🚀 Running the AI Backend Server

### Method 1: Simple Command (Recommended)

Open a **new terminal** and run:

```bash
cd "C:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5\Spacegame\Space-Shooter\addons\scene-crafter-main\python-scripts\backend"
python app.py
```

**Expected Output:**
```
 * Serving Flask app 'app'
 * Debug mode: on
WARNING: This is a development server. Do not use it in production.
 * Running on http://127.0.0.1:8000
 * Running on http://127.0.0.1:8001
```

**Keep this terminal open while using Scene Crafter!**

---

### Method 2: Using PowerShell

```powershell
cd "C:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5\Spacegame\Space-Shooter\addons\scene-crafter-main\python-scripts\backend"
python app.py
```

---

### Method 3: Using VS Code Terminal

1. Open VS Code
2. Open terminal (View → Terminal or Ctrl+`)
3. Paste the commands above
4. Press Enter

---

## 🎯 What the Backend Does

Once running, the AI backend provides:

1. **Natural Language Processing**
   - Understands your scene descriptions
   - Parses commands into Godot actions

2. **Scene Generation**
   - Creates node structures from text
   - Configures properties automatically
   - Generates GDScript code

3. **Code Suggestions**
   - Real-time script recommendations
   - Property configuration help
   - Signal setup suggestions

---

## 📝 Using Scene Crafter with AI

### Step 1: Start the Backend
```bash
cd "Spacegame\Space-Shooter\addons\scene-crafter-main\python-scripts\backend"
python app.py
```

### Step 2: Open Godot
- Launch Godot
- Open your GalacticCombat project

### Step 3: Use Scene Crafter Panel

**Try these commands:**

```
"Create a player character with sprite, collision shape, and movement script"
```

```
"Add an enemy that patrols back and forth"
```

```
"Generate a boss enemy with health bar"
```

```
"Create a power-up collectible that rotates"
```

```
"Make a pause menu with resume and quit buttons"
```

---

## 🔧 Troubleshooting

### Error: "Module not found"

**Solution:** Install missing package
```bash
pip install [package-name]
```

### Error: "Port already in use"

**Solution:** Another app is using port 8000/8001
```bash
# Kill the process or change the port in app.py
netstat -ano | findstr :8000
taskkill /PID [process-id] /F
```

### Error: "Python not found"

**Solution:** Add Python to PATH
1. Search "Environment Variables" in Windows
2. Edit PATH
3. Add: `C:\Python313\` (or your Python location)
4. Restart terminal

### Backend Slow to Start

This is normal! First time loading takes 1-2 minutes because:
- Loading AI models
- Initializing transformers
- Caching model files

**Be patient on first run!**

---

## 🎮 Alternative: Use Without AI Backend

Scene Crafter works without the backend! You just won't have AI generation.

**What still works:**
- ✅ UI tools
- ✅ Manual node creation
- ✅ Scene templates
- ✅ Helper functions

**What needs backend:**
- ❌ Natural language generation
- ❌ AI code suggestions
- ❌ Automated scene creation

---

## 📊 Backend Status Check

### Verify It's Running:

Open browser and go to:
```
http://localhost:8000
```

You should see a response from the Flask server.

### Check from Godot:

Look for these messages in Godot Output console:
```
✅ "Connected to Scene Crafter backend"
✅ "AI generation ready"
```

Instead of:
```
❌ "ERROR: scene/main/http_request.cpp:118"
❌ "Connection refused"
```

---

## ⚡ Quick Start Commands

### Windows (Command Prompt):
```cmd
cd "C:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5\Spacegame\Space-Shooter\addons\scene-crafter-main\python-scripts\backend"
python app.py
```

### Windows (PowerShell):
```powershell
Set-Location "C:\Users\kinlo\OneDrive\Desktop\emojis (3)\newgame\bulletcore2.5\Spacegame\Space-Shooter\addons\scene-crafter-main\python-scripts\backend"
python app.py
```

### Keep Terminal Open
**Important:** Don't close the terminal! The server needs to stay running while you use Scene Crafter in Godot.

---

## 🔄 Stopping the Backend

**To stop the server:**
- Press `Ctrl+C` in the terminal

**To restart:**
- Run `python app.py` again

---

## 🎯 Pro Tips

1. **Run in separate terminal** - Don't use the same terminal you use for Godot commands

2. **Start backend BEFORE Godot** - This ensures Scene Crafter connects immediately

3. **Check Godot console** - Errors will appear there if connection fails

4. **First run is slow** - AI models take time to load initially (1-2 minutes)

5. **Keep updated** - Run `pip install --upgrade transformers` occasionally for improvements

---

## 📱 Using with Your Game Features

Now that backend is ready, you can use Scene Crafter to generate:

**Boss Battles:**
```
"Create a boss enemy with 1000 health and three attack patterns"
```

**Power-Ups:**
```
"Generate a power-up collectible that gives speed boost for 10 seconds"
```

**Ship Selection:**
```
"Make a ship selection screen with 5 different ships showing stats"
```

**Multiplayer Lobby:**
```
"Create a multiplayer lobby with player list and chat box"
```

---

## 🎓 Learning Resources

**Flask Documentation:**
https://flask.palletsprojects.com/

**Hugging Face Transformers:**
https://huggingface.co/docs/transformers/

**Godot HTTP Requests:**
https://docs.godotengine.org/en/stable/classes/class_httprequest.html

---

Your AI backend server is ready to power Scene Crafter's intelligent scene generation! 🚀🤖
