# EC2 Password Reset Guide (Without .pem Key)

## Current Situation
- **EC2 Instance**: ec2-18-116-64-173.us-east-2.compute.amazonaws.com
- **Username**: Administrator
- **Problem**: Cannot retrieve password without the original .pem key file

## Why You Can't Access
When you created the EC2 Windows instance, AWS encrypted the Administrator password with a key pair (.pem file). Without this file, you cannot decrypt the password through normal means.

## Solution: Reset the Password Using AWS Console

### Step 1: Stop the Instance (IMPORTANT)
1. Go to AWS Console → EC2 Dashboard
2. Select your instance (ec2-18-116-64-173.us-east-2.compute.amazonaws.com)
3. Click **Instance State** → **Stop Instance**
4. Wait until status shows "Stopped"

### Step 2: Create Password Reset Script
1. While instance is stopped, select it
2. Click **Actions** → **Instance Settings** → **Edit User Data**
3. Paste this script:

```xml
<powershell>
$NewPassword = "YourNewPassword123!"
$Username = "Administrator"
$SecurePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force
Set-LocalUser -Name $Username -Password $SecurePassword
Write-Host "Password has been reset to: $NewPassword"
</powershell>
```

4. **IMPORTANT**: Replace `YourNewPassword123!` with a strong password you'll remember
   - Must be at least 8 characters
   - Include uppercase, lowercase, numbers, and special characters
   - Example: `SpaceShooter2025!@#`

5. Click **Save**

### Step 3: Start Instance and Reset
1. Click **Instance State** → **Start Instance**
2. Wait 2-3 minutes for the instance to fully boot
3. The User Data script will automatically reset the password

### Step 4: Clean Up User Data (Security)
1. Stop the instance again
2. **Actions** → **Instance Settings** → **Edit User Data**
3. Delete the password reset script (leave it blank)
4. Click **Save**
5. Start the instance again

### Step 5: Connect via RDP
1. Open Remote Desktop Connection
2. Computer: `ec2-18-116-64-173.us-east-2.compute.amazonaws.com`
3. Username: `Administrator`
4. Password: The new password you set in the script
5. Click **Connect**

## Important Notes

⚠️ **CRITICAL**: Your matchmaking server (PM2) will be stopped when you stop the instance. After logging in via RDP, you'll need to restart it:

```bash
pm2 start matchmaking-server.cjs
pm2 save
```

## Alternative: Use AWS Systems Manager (If Configured)

If your instance has SSM Agent installed and IAM role configured:

1. Go to AWS Console → Systems Manager → Session Manager
2. Click **Start Session**
3. Select your instance
4. Run password reset commands directly

**However**, based on previous testing, your SSM Agent appears not to be registered, so the User Data method above is your best option.

## Prevention for Future

1. **Save Your Credentials**: After resetting, save the password in a secure password manager
2. **Create New Key Pair**: For future instances, download and save the .pem key immediately
3. **Enable SSM**: Configure IAM roles and SSM Agent for easier access without RDP

## Current Server Status

Your matchmaking server is running via PM2 on this instance:
- **Port**: 3001
- **Status**: Online (24/7 with PM2)
- **Type**: WebSocket server

Once you regain RDP access, you can verify the server with:
```bash
pm2 status
pm2 logs matchmaking-server
```

## Need Help?

If you encounter issues:
1. Ensure the instance is fully stopped before editing User Data
2. Wait at least 2-3 minutes after starting for the script to execute
3. Check the password meets complexity requirements
4. Make sure you're using the correct DNS name

## Your AWS Account Info

You'll need your AWS Console credentials to perform these steps:
- **URL**: https://console.aws.amazon.com/
- **Region**: US East (Ohio) - us-east-2
- Your AWS account email and password (not EC2 credentials)

If you don't remember your AWS Console login, you'll need to reset it through AWS's password recovery.
