# AWS Security Group Configuration for Port 3001
## Enable WebSocket Connections for Your Game

Your Windows Firewall is now configured! Now we need to configure AWS to allow traffic through port 3001.

---

## Your Server Information
- **Public IP:** 18.116.64.173
- **Instance ID:** i-0b45bbd8105d85e19
- **Region:** us-east-2 (Ohio)

---

## Quick Guide: Add Port 3001 to Security Group

### Step 1: Log in to AWS Console
1. Go to https://console.aws.amazon.com
2. Sign in with your AWS credentials
3. Make sure you're in the **us-east-2 (Ohio)** region (top-right corner)

### Step 2: Navigate to EC2 Security Groups
1. In the AWS Console, search for **"EC2"** in the top search bar
2. Click on **EC2** to open the EC2 Dashboard
3. In the left sidebar, scroll down and click **"Security Groups"** under "Network & Security"

### Step 3: Find Your Instance's Security Group
1. Look for the security group attached to instance **i-0b45bbd8105d85e19**
2. It's usually named something like `launch-wizard-1` or similar
3. Select it by clicking the checkbox next to it

### Step 4: Add Inbound Rule for Port 3001
1. Click the **"Inbound rules"** tab at the bottom
2. Click **"Edit inbound rules"** button
3. Click **"Add rule"** button

### Step 5: Configure the Rule
Fill in the following details:

```
Type: Custom TCP
Protocol: TCP
Port range: 3001
Source: 0.0.0.0/0 (Anywhere IPv4)
Description: WebSocket Port 3001 for hideoutads.online
```

**Detailed Settings:**
- **Type:** Select "Custom TCP" from the dropdown
- **Protocol:** TCP (automatically selected)
- **Port range:** Enter `3001`
- **Source:** Select "Anywhere-IPv4" OR enter `0.0.0.0/0`
- **Description:** Enter `WebSocket Port 3001 for hideoutads.online`

### Step 6: Save the Rule
1. Click **"Save rules"** button at the bottom
2. Wait for confirmation message: "Successfully modified security group rules"

---

## Visual Guide with Screenshots

### What You Should See:

**Before Adding Rule:**
```
Inbound rules tab shows existing rules like:
- SSH (22)
- RDP (3389)
- HTTP (80)
- HTTPS (443)
- Custom TCP (3000, 7777)
```

**After Adding Rule:**
```
Your new rule should appear:
Type         Protocol  Port Range  Source      Description
Custom TCP   TCP       3001        0.0.0.0/0   WebSocket Port 3001 for hideoutads.online
```

---

## Verify Configuration

### Test from Your Computer:

Open PowerShell or Command Prompt and run:

```powershell
# Test if port 3001 is accessible
Test-NetConnection -ComputerName 18.116.64.173 -Port 3001
```

**Expected Output:**
```
ComputerName     : 18.116.64.173
RemoteAddress    : 18.116.64.173
RemotePort       : 3001
InterfaceAlias   : Ethernet
SourceAddress    : [Your IP]
TcpTestSucceeded : True
```

### Test with curl (if you have a service running):
```bash
curl http://18.116.64.173:3001
```

---

## Complete Security Group Configuration

Your security group should now have these inbound rules:

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| RDP | TCP | 3389 | Your IP | Remote Desktop |
| HTTP | TCP | 80 | 0.0.0.0/0 | Web traffic |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Secure web traffic |
| Custom TCP | TCP | 3000 | 0.0.0.0/0 | Matchmaking server |
| **Custom TCP** | **TCP** | **3001** | **0.0.0.0/0** | **WebSocket for game** |
| Custom TCP | TCP | 7777 | 0.0.0.0/0 | Game server |
| Custom UDP | UDP | 7777 | 0.0.0.0/0 | Game server UDP |

---

## Alternative Method: Using AWS CLI

If you prefer command line:

```bash
# Get your security group ID first
aws ec2 describe-instances --instance-ids i-0b45bbd8105d85e19 --region us-east-2 --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text

# Add the rule (replace sg-xxxxx with your actual security group ID)
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxx \
    --protocol tcp \
    --port 3001 \
    --cidr 0.0.0.0/0 \
    --region us-east-2
```

---

## Troubleshooting

### Port Still Not Accessible?

**1. Check Windows Firewall on EC2 Instance**
```powershell
# RDP into your EC2 instance and run:
netsh advfirewall firewall show rule name="WebSocket Port 3001"
```

**2. Verify Security Group Assignment**
```
AWS Console → EC2 → Instances → Select your instance
Check "Security" tab → Verify security group is correct
```

**3. Check if Service is Running**
```powershell
# On your EC2 instance:
netstat -an | findstr :3001
```

**4. Test from EC2 Instance Itself**
```powershell
# RDP into EC2 and test locally:
Test-NetConnection -ComputerName localhost -Port 3001
```

---

## Security Considerations

### Current Configuration (0.0.0.0/0):
✅ **Pros:** Anyone can connect to your game  
⚠️ **Cons:** Port is open to the entire internet

### More Secure Options:

**Option 1: Restrict to Specific Countries**
Use AWS WAF to block traffic from specific countries

**Option 2: Use CloudFront**
Put CloudFront in front of your server for DDoS protection

**Option 3: Rate Limiting**
Implement rate limiting in your application code

**Option 4: Authentication**
Require tokens/authentication before accepting connections

---

## Next Steps After Configuration

1. ✅ **Windows Firewall:** Configured (port 3001 open)
2. ✅ **AWS Security Group:** Configured (port 3001 open)
3. ⬜ **Start Your Game Server:** Make sure service is running on port 3001
4. ⬜ **Update Game Client:** Point to `ws://18.116.64.173:3001`
5. ⬜ **Test Connection:** Have players try connecting

---

## Quick Reference Commands

### Check Security Group Status:
```bash
aws ec2 describe-security-groups --group-ids sg-xxxxx --region us-east-2
```

### Remove Rule (if needed):
```bash
aws ec2 revoke-security-group-ingress \
    --group-id sg-xxxxx \
    --protocol tcp \
    --port 3001 \
    --cidr 0.0.0.0/0 \
    --region us-east-2
```

### List All Rules:
```bash
aws ec2 describe-security-groups --group-ids sg-xxxxx --region us-east-2 --query 'SecurityGroups[0].IpPermissions'
```

---

## Common Errors and Solutions

### Error: "You do not have permission to access this resource"
**Solution:** Make sure you're logged in as a user with EC2 admin permissions

### Error: "The specified rule already exists"
**Solution:** The rule is already added. Check existing rules in the console.

### Error: "VPC limit exceeded"
**Solution:** Delete unused security group rules or contact AWS support

### Connection Timeout
**Solution:** 
1. Verify both Windows Firewall AND Security Group are configured
2. Check that your service is actually running on port 3001
3. Try from a different network to rule out ISP blocking

---

## Support

If you encounter issues:

1. **Check AWS Service Health:** https://status.aws.amazon.com
2. **Review Security Group Logs:** CloudWatch Logs
3. **Test Locally First:** Before testing externally
4. **Use VPC Flow Logs:** To see if traffic is reaching your instance

---

**Configuration Complete! 🎉**

Your port 3001 is now open on both:
- ✅ Windows Firewall (local machine)
- ✅ AWS Security Group (EC2 instance)

Players can now connect to your game at **hideoutads.online** through port **3001**!

---

**Last Updated:** October 2025  
**Server:** 18.116.64.173  
**Instance:** i-0b45bbd8105d85e19  
**Port:** 3001
