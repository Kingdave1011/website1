# 🎯 FINISH THE REMAINING 3 TABS - SIMPLE STEPS

You have the GuestTab done! Now just repeat the same process for the other 3 tabs.

---

## ✅ WHAT YOU ALREADY HAVE:

```
LoginScreen (Control) [LoginScreen.gd attached]
└── TabContainer
    ├── GuestTab (Panel) ✅ DONE
    │   └── VBoxContainer
    │       ├── TitleLabel
    │       ├── GuestNameInput
    │       └── GuestPlayButton
    ├── LoginTab (Panel) ❌ NEEDS CHILDREN
    ├── SignupTab (Panel) ❌ NEEDS CHILDREN
    └── ForgotTab (Panel) ❌ NEEDS CHILDREN
```

---

## 📋 STEP 1: ADD CHILDREN TO LoginTab

### In Godot:

1. **Right-click LoginTab** → Add Child Node → **VBoxContainer**
2. **Right-click VBoxContainer** (the one under LoginTab) → Add Child Node → **Label**
   - Rename to: **TitleLabel**
   - In Inspector → Text: **"Login"**
3. **Right-click VBoxContainer** → Add Child Node → **LineEdit**
   - Rename to: **LoginUsernameInput**
   - In Inspector → Placeholder Text: **"Username"**
4. **Right-click VBoxContainer** → Add Child Node → **LineEdit**
   - Rename to: **LoginPasswordInput**
   - In Inspector → Placeholder Text: **"Password"**
   - In Inspector → Secret: **☑ CHECK THIS BOX** (makes password dots)
5. **Right-click VBoxContainer** → Add Child Node → **Button**
   - Rename to: **LoginButton**
   - In Inspector → Text: **"LOGIN"**
6. **Right-click VBoxContainer** → Add Child Node → **Label**
   - Rename to: **LoginStatusLabel**
   - In Inspector → Text: **""** (leave empty)

### Connect LoginButton:
1. Click **LoginButton**
2. Node tab (right side) → Double-click **"pressed()"**
3. In popup → Receiver Method: **_on_login_pressed**
4. Click **Connect**

### Set VBoxContainer Position:
1. Click **VBoxContainer** (under LoginTab)
2. In Inspector → Anchor Preset button → Click **"Center"**

**LoginTab is now done!** ✅

---

## 📋 STEP 2: ADD CHILDREN TO SignupTab

### In Godot:

1. **Right-click SignupTab** → Add Child Node → **VBoxContainer**
2. **Right-click VBoxContainer** (the one under SignupTab) → Add Child Node → **Label**
   - Rename to: **TitleLabel**
   - In Inspector → Text: **"Create Account"**
3. **Right-click VBoxContainer** → Add Child Node → **LineEdit**
   - Rename to: **SignupUsernameInput**
   - In Inspector → Placeholder Text: **"Username"**
4. **Right-click VBoxContainer** → Add Child Node → **LineEdit**
   - Rename to: **SignupPasswordInput**
   - In Inspector → Placeholder Text: **"Password"**
   - In Inspector → Secret: **☑ CHECK THIS BOX**
5. **Right-click VBoxContainer** → Add Child Node → **LineEdit**
   - Rename to: **SignupEmailInput**
   - In Inspector → Placeholder Text: **"Email (optional)"**
6. **Right-click VBoxContainer** → Add Child Node → **Button**
   - Rename to: **SignupButton**
   - In Inspector → Text: **"CREATE ACCOUNT"**
7. **Right-click VBoxContainer** → Add Child Node → **Label**
   - Rename to: **SignupStatusLabel**
   - In Inspector → Text: **""** (leave empty)

### Connect SignupButton:
1. Click **SignupButton**
2. Node tab → Double-click **"pressed()"**
3. Receiver Method: **_on_signup_pressed**
4. Click **Connect**

### Set VBoxContainer Position:
1. Click **VBoxContainer** (under SignupTab)
2. In Inspector → Anchor Preset button → Click **"Center"**

**SignupTab is now done!** ✅

---

## 📋 STEP 3: ADD CHILDREN TO ForgotTab

### In Godot:

1. **Right-click ForgotTab** → Add Child Node → **VBoxContainer**
2. **Right-click VBoxContainer** (the one under ForgotTab) → Add Child Node → **Label**
   - Rename to: **TitleLabel**
   - In Inspector → Text: **"Forgot Password"**
3. **Right-click VBoxContainer** → Add Child Node → **LineEdit**
   - Rename to: **ForgotUsernameInput**
   - In Inspector → Placeholder Text: **"Username"**
4. **Right-click VBoxContainer** → Add Child Node → **LineEdit**
   - Rename to: **RecoveryCodeInput**
   - In Inspector → Placeholder Text: **"6-Digit Recovery Code"**
5. **Right-click VBoxContainer** → Add Child Node → **LineEdit**
   - Rename to: **NewPasswordInput**
   - In Inspector → Placeholder Text: **"New Password"**
   - In Inspector → Secret: **☑ CHECK THIS BOX**
6. **Right-click VBoxContainer** → Add Child Node → **Button**
   - Rename to: **ResetPasswordButton**
   - In Inspector → Text: **"RESET PASSWORD"**
7. **Right-click VBoxContainer** → Add Child Node → **Label**
   - Rename to: **ForgotStatusLabel**
   - In Inspector → Text: **""** (leave empty)

### Connect ResetPasswordButton:
1. Click **ResetPasswordButton**
2. Node tab → Double-click **"pressed()"**
3. Receiver Method: **_on_reset_password_pressed**
4. Click **Connect**

### Set VBoxContainer Position:
1. Click **VBoxContainer** (under ForgotTab)
2. In Inspector → Anchor Preset button → Click **"Center"**

**ForgotTab is now done!** ✅

---

## 🎯 FINAL SCENE TREE

Your complete scene should look like this:

```
LoginScreen (Control) [LoginScreen.gd attached]
└── TabContainer
    ├── GuestTab (Panel) ✅
    │   └── VBoxContainer
    │       ├── TitleLabel
    │       ├── GuestNameInput
    │       └── GuestPlayButton [connected]
    │
    ├── LoginTab (Panel) ✅
    │   └── VBoxContainer
    │       ├── TitleLabel
    │       ├── LoginUsernameInput
    │       ├── LoginPasswordInput
    │       ├── LoginButton [connected]
    │       └── LoginStatusLabel
    │
    ├── SignupTab (Panel) ✅
    │   └── VBoxContainer
    │       ├── TitleLabel
    │       ├── SignupUsernameInput
    │       ├── SignupPasswordInput
    │       ├── SignupEmailInput
    │       ├── SignupButton [connected]
    │       └── SignupStatusLabel
    │
    └── ForgotTab (Panel) ✅
        └── VBoxContainer
            ├── TitleLabel
            ├── ForgotUsernameInput
            ├── RecoveryCodeInput
            ├── NewPasswordInput
            ├── ResetPasswordButton [connected]
            └── ForgotStatusLabel
```

---

## 💾 SAVE AND TEST

1. **Press Ctrl+S** to save
2. **Press F5** to run the game
3. **Click "Play" in main menu**
4. **You should see 4 tabs: Guest, Login, Signup, Forgot**

### Test Each Tab:

**Guest Tab:**
- Enter a name (optional)
- Click "PLAY AS GUEST"
- Should start the game

**Login Tab:**
- Username: **King_davez**
- Password: **Peaguyxx300**
- Click "LOGIN"
- Should start the game (and say "Welcome owner!")

**Signup Tab:**
- Create a new account
- Click "CREATE ACCOUNT"
- Should switch to Login tab

**Forgot Tab:**
- Enter username
- Enter recovery code (shown when you signed up)
- Enter new password
- Click "RESET PASSWORD"

---

## ✅ CHECKLIST

Before testing:
- [ ] LoginTab has VBoxContainer with 5 children
- [ ] SignupTab has VBoxContainer with 6 children
- [ ] ForgotTab has VBoxContainer with 6 children
- [ ] All password LineEdits have "Secret" enabled (☑)
- [ ] All 4 buttons are connected to their methods
- [ ] All VBoxContainers are centered
- [ ] Scene is saved as LoginScreen.tscn

**That's it! Your login screen is complete! 🎮**
