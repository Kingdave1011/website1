# QUICK EC2 Password Reset - Step by Step

⚠️ **IMPORTANT**: `YourNewPassword123!` is just an EXAMPLE! You must replace it with YOUR OWN password.

## What To Do Right Now

### Step 1: Go to AWS Console
1. Open https://console.aws.amazon.com/
2. Sign in with your AWS account email and password
3. Make sure region is set to **US East (Ohio)** in top-right corner
4. Go to **EC2** service

### Step 2: Stop Your Instance
1. Find your instance: **ec2-18-116-64-173.us-east-2.compute.amazonaws.com**
2. Select it (checkbox)
3. Click **Instance State** → **Stop Instance**
4. Click **Stop** to confirm
5. Wait until it says **Stopped** (takes 1-2 minutes)

### Step 3: Add Password Reset Script
1. With instance still selected, click **Actions** (top)
2. Click **Instance Settings** → **Edit User Data**
3. Copy this ENTIRE script:

```xml
<powershell>
$NewPassword = "SpaceShooter2025!@#"
$Username = "Administrator"
$SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force
Set-LocalUser -Name $Username -Password $SecurePassword
Write-Host "Password has been reset successfully"
</powershell>
```

4. **CHANGE THE PASSWORD**: Replace `SpaceShooter2025!@#` with a password YOU will remember
   - Examples of good passwords:
     - `MyGame2025!!`
     - `BulletCore!2025`
     - `KingDave#2025!`
   - Must have:
     - At least 8 characters
     - Uppercase letters (A-Z)
     - Lowercase letters (a-z)
     - Numbers (0-9)
     - Special characters (!@#$%)

5. Click **Save** at bottom

### Step 4: Start Instance
1. Click **Instance State** → **Start Instance**
2. Wait 3 minutes for it to fully start
3. The script will automatically reset your password

### Step 5: Clean Up (Security)
1. **Actions** → **Instance Settings** → **Edit User Data**
2. DELETE everything (leave it empty)
3. Click **Save**

### Step 6: Connect via RDP
1. Open **Remote Desktop Connection** on your PC (search for "Remote Desktop")
2. Computer: `ec2-18-116-64-173.us-east-2.compute.amazonaws.com`
3. Click **Connect**
4. Username: `Administrator`
5. Password: The password YOU chose in Step 3
6. Click **OK**

### Step 7: Restart Your Matchmaking Server
Once logged in via RDP, open Command Prompt and run:
```bash
pm2 restart matchmaking-server
pm2 save
pm2 status
```

## Example

If you chose the password `MyGame2025!!`, your script would look like:

```xml
<powershell>
$NewPassword = "MyGame2025!!"
$Username = "Administrator"
$SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force
Set-LocalUser -Name $Username -Password $SecurePassword
Write-Host "Password has been reset successfully"
</powershell>
```

And when connecting via RDP, you would type `MyGame2025!!` as the password.

## Important Notes

- **DO NOT** use `YourNewPassword123!` - that's just a placeholder
- **DO** choose your own strong password
- **SAVE** your password somewhere safe after this
- Your server will be offline for about 5 minutes total during this process
- Your matchmaking server will need to be restarted after you log in

## Need Help?

If it doesn't work:
1. Make sure you waited 3 full minutes after starting the instance
2. Make sure your password meets the requirements (8+ chars, uppercase, lowercase, numbers, special chars)
3. Make sure you deleted the User Data after (security)
4. Try the process again with a different password
