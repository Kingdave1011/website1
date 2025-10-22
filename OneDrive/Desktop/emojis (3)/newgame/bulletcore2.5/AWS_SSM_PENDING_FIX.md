# AWS Systems Manager - Fix "Pending" Status

## Issue
The "Auto update SSM Agent" configuration shows "Pending" status in AWS Systems Manager console.

## What "Pending" Means
- The configuration has been saved but not yet applied to your EC2 instance
- The SSM Agent on the instance needs to check in with Systems Manager
- This can take 5-10 minutes after enabling the setting

## How to Fix

### Option 1: Wait for Automatic Check-in
The SSM Agent automatically checks in every 5 minutes. Simply wait 5-10 minutes and refresh the AWS console page.

### Option 2: Restart SSM Agent on EC2 Instance
Connect to your EC2 instance and restart the SSM Agent:

**For Windows Server:**
```powershell
Restart-Service AmazonSSMAgent
```

**For Linux:**
```bash
sudo systemctl restart amazon-ssm-agent
```

### Option 3: Verify IAM Role
Your EC2 instance needs the proper IAM role:

1. Go to EC2 Console → Instances
2. Select instance `i-0b45bbd8105d85e19`
3. Actions → Security → Modify IAM role
4. Attach role with policy: `AmazonSSMManagedInstanceCore`

### Option 4: Check SSM Agent Status via AWS CLI
```bash
aws ssm describe-instance-information --instance-id i-0b45bbd8105d85e19 --region us-east-2
```

This will show if the agent is online and communicating with Systems Manager.

### Option 5: Manually Apply Configuration
```bash
aws ssm update-service-setting --setting-id arn:aws:ssm:us-east-2:217558553462:servicesetting/ssm/managed-instance/default-ec2-instance-management-role --setting-value AWSSystemsManagerDefaultEC2InstanceManagementRole --region us-east-2
```

## Expected Result
After the agent checks in, status will change from "Pending" to one of:
- **Success** - Configuration applied successfully
- **Failed** - Check IAM role and agent status

## Common Issues
1. **No IAM role attached** - Attach `AmazonSSMManagedInstanceCore` policy
2. **SSM Agent not running** - Start/restart the agent
3. **Network issues** - Check security groups allow outbound HTTPS (port 443)
4. **Instance stopped** - Start the instance if it's stopped

## Your Instance Details
- Instance ID: `i-0b45bbd8105d85e19`
- Region: `us-east-2` (US East Ohio)
- Public IP: `18.116.64.173`

## Quick Check
Run this to see if SSM can communicate with your instance:
```bash
aws ssm send-command --instance-ids i-0b45bbd8105d85e19 --document-name "AWS-RunPowerShellScript" --parameters 'commands=["Get-Service AmazonSSMAgent"]' --region us-east-2
```

If this works, the "Pending" status should resolve within minutes.
