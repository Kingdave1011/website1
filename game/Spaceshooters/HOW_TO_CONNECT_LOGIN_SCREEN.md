# 🔐 HOW TO CONNECT LOGIN SCREEN - STEP BY STEP

## COMPLETE GUIDE TO CREATING LoginScreen.tscn

---

## 📋 STEP 1: CREATE THE LOGIN SCREEN SCENE

### In Godot Editor:

1. **Click "Scene" → "New Scene"** (top left)
2. **Select "User Interface"** (this creates a Control node)
3. **Rename the root node:**
   - Click on "Control" in the Scene tree
   - In the Inspector panel (right side), change "Name" to **LoginScreen**
4. **Attach the script:**
   - Right-click **LoginScreen** node
   - Select "Attach Script"
   - Browse to **LoginScreen.gd**
   - Click "Create"

---

## 📋 STEP 2: CREATE THE UI STRUCTURE

### Add TabContainer:

1. **Right-click LoginScreen** → "Add Child Node"
2. **Search for**: `TabContainer`
3. **Click "Create"**
4. **In Inspector (right side), set:**
   - Anchor Preset: **Full Rect** (click the preset button at top of Inspector)
   - Or manually set:
     - Anchor Left: 0
     - Anchor Right: 1
     - Anchor Top: 0
     - Anchor Bottom: 1

### Add 4 Tabs:

For each tab, do this **4 times**:

1. **Right-click TabContainer** → "Add Child Node"
2. **Search for**: `Panel`
3. **Click "Create"**
4. **Rename Panel** (in Inspector → Name field):
   - First one: **GuestTab**
   - Second one: **LoginTab**
   - Third one: **SignupTab**
   - Fourth one: **ForgotTab**

The tab names will automatically appear in the TabContainer!

---

## 📋 STEP 3: ADD UI ELEMENTS TO EACH TAB

### GUEST TAB:

1. **Right-click GuestTab** → "Add Child Node" → **VBoxContainer**
2. **In VBoxContainer Inspector:**
   - Anchor Preset: **Center**
   - Or set: Anchor Left: 0.5, Top: 0.5, Right: 0.5, Bottom: 0.5

3. **Add to VBoxContainer** (Right-click → Add Child Node):
   - **Label** - Rename to "TitleLabel"
     - In Inspector → Text: "Play as Guest"
     - Horizontal Alignment: Center
   - **LineEdit** - Rename to "GuestNameInput"
     - Placeholder Text: "Enter your name (optional)"
   - **Button** - Rename to "GuestPlayButton"
     - Text: "PLAY AS GUEST"

### LOGIN TAB:

1. **Right-click LoginTab** → "Add Child Node" → **VBoxContainer**
2. **Set anchor preset to Center**
3. **Add to VBoxContainer:**
   - **Label** - "TitleLabel" - Text: "Login"
   - **LineEdit** - "LoginUsernameInput" - Placeholder: "Username"
   - **LineEdit** - "LoginPasswordInput" - Placeholder: "Password", Secret: ☑ (checked)
   - **Button** - "LoginButton" - Text: "LOGIN"
   - **Label** - "LoginStatusLabel" - Text: "" (empty)

### SIGNUP TAB:

1. **Right-click SignupTab** → "Add Child Node" → **VBoxContainer**
2. **Set anchor preset to Center**
3. **Add to VBoxContainer:**
   - **Label** - "TitleLabel" - Text: "Create Account"
   - **LineEdit** - "SignupUsernameInput" - Placeholder: "Username"
   - **LineEdit** - "SignupPasswordInput" - Placeholder: "Password", Secret: ☑
   - **LineEdit** - "SignupEmailInput" - Placeholder: "Email (optional)"
   - **Button** - "SignupButton" - Text: "CREATE ACCOUNT"
   - **Label** - "SignupStatusLabel" - Text: "" (empty)

### FORGOT PASSWORD TAB:

1. **Right-click ForgotTab** → "Add Child Node" → **VBoxContainer**
2. **Set anchor preset to Center**
3. **Add to VBoxContainer:**
   - **Label** - "TitleLabel" - Text: "Forgot Password"
   - **LineEdit** - "ForgotUsernameInput" - Placeholder: "Username"
   - **LineEdit** - "RecoveryCodeInput" - Placeholder: "6-Digit Recovery Code"
   - **LineEdit** - "NewPasswordInput" - Placeholder: "New Password", Secret: ☑
   - **Button** - "ResetPasswordButton" - Text: "RESET PASSWORD"
   - **Label** - "ForgotStatusLabel" - Text: "" (empty)

---

## 📋 STEP 4: CONNECT ALL BUTTONS

### Guest Play Button:

1. **Click GuestPlayButton** in Scene tree
2. **Go to Node tab** (right side, next to Inspector)
3. **Find "pressed()" signal**
4. **Double-click "pressed()"**
5. **In popup, make sure LoginScreen is selected**
6. **In "Receiver Method" box, type**: `_on_guest_play_pressed`
7. **Click "Connect"**

### Login Button:

1. **Click LoginButton**
2. **Node tab → Double-click "pressed()"**
3. **Receiver Method**: `_on_login_pressed`
4. **Connect**

### Signup Button:

1. **Click SignupButton**
2. **Node tab → Double-click "pressed()"**
3. **Receiver Method**: `_on_signup_pressed`
4. **Connect**

### Reset Password Button:

1. **Click ResetPasswordButton**
2. **Node tab → Double-click "pressed()"**
3. **Receiver Method**: `_on_reset_password_pressed`
4. **Connect**

---

## 📋 STEP 5: GET NODE PATHS FOR SCRIPT

Your LoginScreen.gd script needs to reference all these UI elements. Here's how the script finds them:

### The script uses these node paths:

```gdscript
# Guest tab
@onready var guest_name_input = $TabContainer/GuestTab/VBoxContainer/GuestNameInput
@onready var guest_play_button = $TabContainer/GuestTab/VBoxContainer/GuestPlayButton

# Login tab
@onready var login_username_input = $TabContainer/LoginTab/VBoxContainer/LoginUsernameInput
@onready var login_password_input = $TabContainer/LoginTab/VBoxContainer/LoginPasswordInput
@onready var login_button = $TabContainer/LoginTab/VBoxContainer/LoginButton
@onready var login_status = $TabContainer/LoginTab/VBoxContainer/LoginStatusLabel

# Signup tab
@onready var signup_username_input = $TabContainer/SignupTab/VBoxContainer/SignupUsernameInput
@onready var signup_password_input = $TabContainer/SignupTab/VBoxContainer/SignupPasswordInput
@onready var signup_email_input = $TabContainer/SignupTab/VBoxContainer/SignupEmailInput
@onready var signup_button = $TabContainer/SignupTab/VBoxContainer/SignupButton
@onready var signup_status = $TabContainer/SignupTab/VBoxContainer/SignupStatusLabel

# Forgot tab
@onready var forgot_username_input = $TabContainer/ForgotTab/VBoxContainer/ForgotUsernameInput
@onready var recovery_code_input = $TabContainer/ForgotTab/VBoxContainer/RecoveryCodeInput
@onready var new_password_input = $TabContainer/ForgotTab/VBoxContainer/NewPasswordInput
@onready var reset_button = $TabContainer/ForgotTab/VBoxContainer/ResetPasswordButton
@onready var forgot_status = $TabContainer/ForgotTab/VBoxContainer/ForgotStatusLabel
```

**IMPORTANT:** Make sure your node names match exactly! If you named something differently, update the script.

---

## 📋 STEP 6: ADD LOGIN SCREEN TO PROJECT

### Update MainMenu.gd:

The MainMenu already has code to open LoginScreen. Make sure it looks like this:

```gdscript
func _on_play_button_pressed():
    get_tree().change_scene_to_file("res://LoginScreen.tscn")

func _on_online_button_pressed():
    get_tree().change_scene_to_file("res://LoginScreen.tscn")
```

---

## 📋 STEP 7: SAVE YOUR SCENE

1. **Press Ctrl+S** (or Cmd+S on Mac)
2. **Save as**: `LoginScreen.tscn`
3. **Save in**: Root of SpaceShooterWeb/Spaceshooters/

---

## 🎮 TESTING

1. **Run the game** (F5)
2. **Click "Play" or "Online" in main menu**
3. **LoginScreen should open with 4 tabs**
4. **Test each tab:**
   - **Guest**: Enter name (or leave blank) → Click PLAY AS GUEST
   - **Login**: Enter King_davez / Peaguyxx300 → Click LOGIN
   - **Signup**: Create new account
   - **Forgot**: Enter username and recovery code

---

## 🔧 TROUBLESHOOTING

### "Invalid get index" errors:

**Problem:** Node paths don't match
**Solution:** 
1. Check Scene tree node names match script exactly
2. Make sure all nodes are inside VBoxContainer
3. Verify TabContainer has 4 Panel children

### Buttons don't work:

**Problem:** Signals not connected
**Solution:**
1. Select button in Scene tree
2. Go to Node tab
3. Check if "pressed()" has green arrow (connected)
4. If not, reconnect it

### Scene won't save:

**Problem:** Unsaved changes or missing nodes
**Solution:**
1. Make sure all required nodes exist
2. Check Inspector for errors (red ! icons)
3. Try Scene → Save Scene As

### Can't find TabContainer:

**Solution:**
1. Make sure you selected "User Interface" when creating scene
2. If not, change root node: Scene → Change Root Node → Control

---

## 📸 VISUAL REFERENCE

### Your Scene Tree Should Look Like This:

```
LoginScreen (Control) [LoginScreen.gd attached]
└── TabContainer
    ├── GuestTab (Panel)
    │   └── VBoxContainer
    │       ├── TitleLabel (Label)
    │       ├── GuestNameInput (LineEdit)
    │       └── GuestPlayButton (Button) [connected to _on_guest_play_pressed]
    │
    ├── LoginTab (Panel)
    │   └── VBoxContainer
    │       ├── TitleLabel (Label)
    │       ├── LoginUsernameInput (LineEdit)
    │       ├── LoginPasswordInput (LineEdit)
    │       ├── LoginButton (Button) [connected to _on_login_pressed]
    │       └── LoginStatusLabel (Label)
    │
    ├── SignupTab (Panel)
    │   └── VBoxContainer
    │       ├── TitleLabel (Label)
    │       ├── SignupUsernameInput (LineEdit)
    │       ├── SignupPasswordInput (LineEdit)
    │       ├── SignupEmailInput (LineEdit)
    │       ├── SignupButton (Button) [connected to _on_signup_pressed]
    │       └── SignupStatusLabel (Label)
    │
    └── ForgotTab (Panel)
        └── VBoxContainer
            ├── TitleLabel (Label)
            ├── ForgotUsernameInput (LineEdit)
            ├── RecoveryCodeInput (LineEdit)
            ├── NewPasswordInput (LineEdit)
            ├── ResetPasswordButton (Button) [connected to _on_reset_password_pressed]
            └── ForgotStatusLabel (Label)
```

---

## ✅ CHECKLIST

Before testing, verify:

- [ ] LoginScreen.tscn saved in root directory
- [ ] LoginScreen.gd attached to root Control node
- [ ] TabContainer fills entire screen (Full Rect anchor)
- [ ] 4 Panel nodes inside TabContainer (Guest, Login, Signup, Forgot)
- [ ] Each Panel has VBoxContainer with correct children
- [ ] All buttons connected to their signals
- [ ] All node names match script exactly
- [ ] Password LineEdits have "Secret" enabled
- [ ] MainMenu.gd points to LoginScreen.tscn
- [ ] AccountManager in Autoloads

**Your LoginScreen is now complete and ready to use! 🎮**
