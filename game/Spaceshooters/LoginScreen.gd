extends Control

# Login Screen matching the node structure from HOW_TO_CONNECT_LOGIN_SCREEN.md
# Handles guest play, login, signup, and forgot password

# Guest tab
@onready var guest_name_input = $TabContainer/GuestTab/VBoxContainer/GuestNameInput if has_node("TabContainer/GuestTab/VBoxContainer/GuestNameInput") else null
@onready var guest_play_button = $TabContainer/GuestTab/VBoxContainer/GuestPlayButton if has_node("TabContainer/GuestTab/VBoxContainer/GuestPlayButton") else null

# Login tab
@onready var login_username_input = $TabContainer/LoginTab/VBoxContainer/LoginUsernameInput if has_node("TabContainer/LoginTab/VBoxContainer/LoginUsernameInput") else null
@onready var login_password_input = $TabContainer/LoginTab/VBoxContainer/LoginPasswordInput if has_node("TabContainer/LoginTab/VBoxContainer/LoginPasswordInput") else null
@onready var login_button = $TabContainer/LoginTab/VBoxContainer/LoginButton if has_node("TabContainer/LoginTab/VBoxContainer/LoginButton") else null
@onready var login_status = $TabContainer/LoginTab/VBoxContainer/LoginStatusLabel if has_node("TabContainer/LoginTab/VBoxContainer/LoginStatusLabel") else null

# Signup tab
@onready var signup_username_input = $TabContainer/SignupTab/VBoxContainer/SignupUsernameInput if has_node("TabContainer/SignupTab/VBoxContainer/SignupUsernameInput") else null
@onready var signup_password_input = $TabContainer/SignupTab/VBoxContainer/SignupPasswordInput if has_node("TabContainer/SignupTab/VBoxContainer/SignupPasswordInput") else null
@onready var signup_email_input = $TabContainer/SignupTab/VBoxContainer/SignupEmailInput if has_node("TabContainer/SignupTab/VBoxContainer/SignupEmailInput") else null
@onready var signup_button = $TabContainer/SignupTab/VBoxContainer/SignupButton if has_node("TabContainer/SignupTab/VBoxContainer/SignupButton") else null
@onready var signup_status = $TabContainer/SignupTab/VBoxContainer/SignupStatusLabel if has_node("TabContainer/SignupTab/VBoxContainer/SignupStatusLabel") else null

# Forgot tab
@onready var forgot_username_input = $TabContainer/ForgotTab/VBoxContainer/ForgotUsernameInput if has_node("TabContainer/ForgotTab/VBoxContainer/ForgotUsernameInput") else null
@onready var recovery_code_input = $TabContainer/ForgotTab/VBoxContainer/RecoveryCodeInput if has_node("TabContainer/ForgotTab/VBoxContainer/RecoveryCodeInput") else null
@onready var new_password_input = $TabContainer/ForgotTab/VBoxContainer/NewPasswordInput if has_node("TabContainer/ForgotTab/VBoxContainer/NewPasswordInput") else null
@onready var reset_button = $TabContainer/ForgotTab/VBoxContainer/ResetPasswordButton if has_node("TabContainer/ForgotTab/VBoxContainer/ResetPasswordButton") else null
@onready var forgot_status = $TabContainer/ForgotTab/VBoxContainer/ForgotStatusLabel if has_node("TabContainer/ForgotTab/VBoxContainer/ForgotStatusLabel") else null

func _ready():
	print("LoginScreen ready!")
	
	# Connect button signals (these should be connected in Godot Editor, but we connect them here as backup)
	# The methods _on_guest_play_pressed, _on_login_pressed, _on_signup_pressed, _on_reset_password_pressed
	# should already be connected via the Editor, but this ensures they work
	
	# Connect AccountManager signals
	if has_node("/root/AccountManager"):
		AccountManager.login_successful.connect(_on_login_success)
		AccountManager.login_failed.connect(_on_login_failed)
		AccountManager.account_created.connect(_on_account_created)
	else:
		print("WARNING: AccountManager not found in Autoloads!")

# These methods match the signal connections from the guide
func _on_guest_play_pressed():
	print("Guest play button pressed")
	# Note: play_as_guest() generates its own random name, doesn't accept parameters
	
	if has_node("/root/AccountManager"):
		AccountManager.play_as_guest()  # Always generates random name
	else:
		print("ERROR: AccountManager not found!")

func _on_login_pressed():
	print("Login button pressed")
	
	if not login_username_input or not login_password_input:
		if login_status:
			login_status.text = "ERROR: Missing input fields"
		return
	
	var username = login_username_input.text
	var password = login_password_input.text
	
	if username.is_empty() or password.is_empty():
		if login_status:
			login_status.text = "Please enter username and password"
		return
	
	if has_node("/root/AccountManager"):
		if AccountManager.is_username_banned(username):
			if login_status:
				login_status.text = "This account has been banned"
			return
		
		AccountManager.login(username, password)
	else:
		print("ERROR: AccountManager not found!")
		if login_status:
			login_status.text = "ERROR: AccountManager not found"

func _on_signup_pressed():
	print("Signup button pressed")
	
	if not signup_username_input or not signup_password_input:
		if signup_status:
			signup_status.text = "ERROR: Missing input fields"
		return
	
	var username = signup_username_input.text
	var password = signup_password_input.text
	# Note: Email input exists but AccountManager.create_account() only takes username and password
	
	if username.is_empty() or password.is_empty():
		if signup_status:
			signup_status.text = "Please fill all fields"
		return
	
	# Validate username
	var username_regex = RegEx.new()
	username_regex.compile("^[a-zA-Z0-9_]{3,20}$")
	if not username_regex.search(username):
		if signup_status:
			signup_status.text = "Username: 3-20 characters, letters, numbers, underscore only"
		return
	
	# Validate password
	if password.length() < 8:
		if signup_status:
			signup_status.text = "Password must be at least 8 characters"
		return
	
	if has_node("/root/AccountManager"):
		if AccountManager.is_username_banned(username):
			if signup_status:
				signup_status.text = "This username is banned"
			return
		
		# create_account only takes 2 parameters: username and password
		AccountManager.create_account(username, password)
	else:
		print("ERROR: AccountManager not found!")
		if signup_status:
			signup_status.text = "ERROR: AccountManager not found"

func _on_reset_password_pressed():
	print("Reset password button pressed")
	
	if not forgot_username_input or not recovery_code_input or not new_password_input:
		if forgot_status:
			forgot_status.text = "ERROR: Missing input fields"
		return
	
	var username = forgot_username_input.text
	var code = recovery_code_input.text
	var new_password = new_password_input.text
	
	if username.is_empty() or code.is_empty() or new_password.is_empty():
		if forgot_status:
			forgot_status.text = "Please fill all fields"
		return
	
	if new_password.length() < 8:
		if forgot_status:
			forgot_status.text = "New password must be at least 8 characters"
		return
	
	if has_node("/root/AccountManager"):
		var success = AccountManager.reset_password(username, code, new_password)
		if success:
			if forgot_status:
				forgot_status.text = "✅ Password reset successfully! You can now login."
			print("Password reset successful for: ", username)
		else:
			if forgot_status:
				forgot_status.text = "❌ Invalid or expired recovery code"
			print("Password reset failed for: ", username)
	else:
		print("ERROR: AccountManager not found!")
		if forgot_status:
			forgot_status.text = "ERROR: AccountManager not found"

func _on_login_success(username: String, is_guest: bool):
	if is_guest:
		print("Playing as guest: ", username)
	else:
		print("Logged in: ", username)
	
	# Check if admin
	if AccountManager and AccountManager.check_admin():
		print("⭐ ADMIN ACCESS GRANTED ⭐")
	
	# Go to main menu or lobby
	if ResourceLoader.exists("res://Lobby.tscn"):
		get_tree().change_scene_to_file("res://Lobby.tscn")
	else:
		get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_login_failed(error: String):
	if login_status:
		login_status.text = error
	if signup_status:
		signup_status.text = error
	print("Login failed: ", error)

func _on_account_created(username: String):
	print("Account created: ", username)
	# Automatically proceeds to login_successful signal

func _on_back_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
