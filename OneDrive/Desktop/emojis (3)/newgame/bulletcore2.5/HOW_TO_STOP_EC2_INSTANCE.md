# How to Stop Your EC2 Instance - Super Simple

## Step 1: Open AWS Console
1. Open your web browser (Chrome, Edge, Firefox, etc.)
2. Go to: **https://console.aws.amazon.com/**
3. Sign in with your AWS account email and password

## Step 2: Go to EC2
1. After logging in, you'll see the AWS Console homepage
2. In the search bar at the top, type: **EC2**
3. Click on **EC2** (it will say "Virtual servers in the cloud")

## Step 3: Find Your Instance
1. On the left sidebar, click **Instances**
2. You'll see a list of your EC2 instances
3. Look for your instance with the address: **ec2-18-116-64-173.us-east-2.compute.amazonaws.com**
4. Click the **checkbox** next to it to select it

## Step 4: Stop the Instance
1. After selecting your instance (checkbox is checked)
2. Look at the top right area
3. Click the button that says **Instance state** (it's near the top)
4. A dropdown menu will appear
5. Click **Stop instance**
6. A popup will appear asking "Are you sure?"
7. Click **Stop** to confirm

## Step 5: Wait for It to Stop
1. The instance status will change to "Stopping"
2. Wait 1-2 minutes
3. When it's fully stopped, the status will say **Stopped**
4. The status indicator will turn from green to red/orange

---

## Visual Guide

```
AWS Console Homepage
    ↓
Type "EC2" in search bar → Click EC2
    ↓
Click "Instances" in left sidebar
    ↓
Find your instance: ec2-18-116-64-173.us-east-2.compute.amazonaws.com
    ↓
Click checkbox next to it
    ↓
Click "Instance state" button (top right)
    ↓
Click "Stop instance" in dropdown
    ↓
Click "Stop" in confirmation popup
    ↓
Wait until status shows "Stopped"
```

## What You'll See

**Before stopping:**
- Status: Running (green dot)
- Instance state: running

**While stopping:**
- Status: Stopping (orange dot)
- Instance state: stopping

**After stopped:**
- Status: Stopped (red/orange dot)
- Instance state: stopped

## Important Notes

⚠️ **When you stop the instance:**
- Your matchmaking server will stop running
- You won't be charged for compute hours while it's stopped
- The instance will keep its IP address and data

✅ **After you stop it:**
- You can edit User Data (for password reset)
- You can start it again anytime
- Your files and settings stay intact

## What's Next?

After the instance is **Stopped**, you can proceed to:
1. Edit User Data (to add password reset script)
2. Start the instance again
3. The password will be reset automatically

## Troubleshooting

**Can't find EC2 in search?**
- Make sure you're signed in to AWS Console
- Check that you're in the correct region (top-right, should show "US East (Ohio)")

**Instance not showing?**
- Check the region dropdown (top-right) - make sure it says "US East (Ohio) us-east-2"
- If you see "No instances", you might be in the wrong region

**Can't click Stop Instance?**
- Make sure the checkbox next to your instance is checked
- The instance might already be stopped or stopping

## Need Help?

If the instance won't stop after 5 minutes:
1. Refresh the page
2. Try stopping it again
3. If still stuck, you can use "Force Stop" (Actions → Instance Settings → Change instance state → Force stop)
