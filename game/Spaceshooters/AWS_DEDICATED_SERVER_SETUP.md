# AWS Dedicated Game Server Setup Guide

## 🌐 Running Your Multiplayer Game on AWS

Perfect! You have an AWS database - now let's set up dedicated game servers on AWS EC2 to run your multiplayer game online!

---

## 📋 What You'll Need

- ✅ AWS Account (you have this)
- ✅ AWS Database (you have this - DynamoDB or RDS)
- ✅ Godot game exported for Linux
- ✅ Basic AWS knowledge (EC2, Security Groups)

---

## 🏗️ Architecture Overview

```
Players → AWS Load Balancer → EC2 Game Servers → AWS Database
                                      ↓
                              Player Data/Stats
```

---

## 🚀 Step 1: Create Godot Headless Server Build

### Export Server Version:

1. **In Godot**, go to: Project → Export
2. **Add Linux/X11 64-bit template**
3. **Export settings:**
   - Name: `GalacticCombatServer`
   - Features: Remove `client`, add `server`
   - Export Mode: `Executable`

### Create Server Script (ServerMain.gd):

```gdscript
extends Node

# AWS Database connection
var db_endpoint: String = ""
var api_key: String = ""

func _ready():
	# Load AWS credentials from environment
	db_endpoint = OS.get_environment("AWS_DB_ENDPOINT")
	api_key = OS.get_environment("AWS_API_KEY")
	
	# Start headless server
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	
	# Create game server
	var peer = ENetMultiplayerPeer.new()
	var port = int(OS.get_environment("SERVER_PORT")) if OS.get_environment("SERVER_PORT") else 7000
	peer.create_server(port, 32)  # 32 max players
	multiplayer.multiplayer_peer = peer
	
	print("Game Server Started on port: ", port)
	print("Database endpoint: ", db_endpoint)
	
	# Connect to database
	connect_to_database()
	
	# Setup multiplayer signals
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)

func connect_to_database():
	# Connect to AWS database
	print("Connecting to AWS Database...")
	# Add your database connection logic here

func _on_player_connected(id: int):
	print("Player connected: ", id)
	# Save player connection to database
	save_player_login(id)

func _on_player_disconnected(id: int):
	print("Player disconnected: ", id)
	# Update player status in database
	save_player_logout(id)

func save_player_login(player_id: int):
	# HTTP request to AWS API Gateway → Lambda → Database
	var http = HTTPRequest.new()
	add_child(http)
	
	var url = db_endpoint + "/player/login"
	var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
	var body = JSON.stringify({
		"player_id": player_id,
		"server_id": OS.get_environment("SERVER_ID"),
		"timestamp": Time.get_unix_time_from_system()
	})
	
	http.request(url, headers, HTTPClient.METHOD_POST, body)

func save_player_logout(player_id: int):
	var http = HTTPRequest.new()
	add_child(http)
	
	var url = db_endpoint + "/player/logout"
	var headers = ["Authorization: Bearer " + api_key, "Content-Type: application/json"]
	var body = JSON.stringify({
		"player_id": player_id,
		"timestamp": Time.get_unix_time_from_system()
	})
	
	http.request(url, headers, HTTPClient.METHOD_POST, body)
```

---

## 🖥️ Step 2: Launch AWS EC2 Instance

### 1. **Go to AWS Console** → EC2 → Launch Instance

### 2. **Choose AMI:**
- Select: **Ubuntu Server 22.04 LTS**
- Architecture: **64-bit (x86)**

### 3. **Choose Instance Type:**
- **t3.medium** (for testing - $0.0416/hour)
- **t3.large** (for production - $0.0832/hour)
- **c5.large** (for high performance - $0.085/hour)

### 4. **Configure Security Group:**

Create new security group with these rules:

| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| Custom UDP | UDP | 7000 | 0.0.0.0/0 | Game Server |
| SSH | TCP | 22 | Your IP | Admin Access |
| HTTP | TCP | 80 | 0.0.0.0/0 | Health Check |

### 5. **Create Key Pair:**
- Download the `.pem` file
- Save it securely (you'll need it to SSH)

### 6. **Launch Instance!**

---

## 🔧 Step 3: Set Up the Server

### Connect to Your Server:

```bash
# Make key pair private
chmod 400 your-key.pem

# Connect via SSH
ssh -i "your-key.pem" ubuntu@your-ec2-public-ip
```

### Install Dependencies:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y wget unzip

# Install screen (to keep server running)
sudo apt install -y screen
```

### Upload Your Game Server:

**From your local machine:**
```bash
# Upload server files to EC2
scp -i "your-key.pem" GalacticCombatServer.x86_64 ubuntu@your-ec2-ip:~/
scp -i "your-key.pem" GalacticCombatServer.pck ubuntu@your-ec2-ip:~/
```

### Make Server Executable:

```bash
chmod +x ~/GalacticCombatServer.x86_64
```

---

## 🗄️ Step 4: Connect to AWS Database

### Option A: Using DynamoDB

```gdscript
# In your ServerMain.gd
func save_player_data(player_id: int, data: Dictionary):
	var http = HTTPRequest.new()
	add_child(http)
	
	var url = "https://YOUR_API_GATEWAY_URL/player/save"
	var headers = [
		"Authorization: Bearer " + api_key,
		"Content-Type: application/json"
	]
	var body = JSON.stringify({
		"player_id": str(player_id),
		"score": data.get("score", 0),
		"level": data.get("level", 1),
		"timestamp": Time.get_unix_time_from_system()
	})
	
	http.request(url, headers, HTTPClient.METHOD_POST, body)
```

### Option B: Using RDS (MySQL/PostgreSQL)

Install database connector on your EC2:

```bash
sudo apt install -y mysql-client
# or
sudo apt install -y postgresql-client
```

**Connection from Godot:**
You'll need to use HTTP API Gateway → Lambda → Database
(Direct database connections from Godot are not recommended for security)

---

## 🚀 Step 5: Run Your Server

### Create Server Startup Script:

```bash
# Create start_server.sh
nano start_server.sh
```

**Add this content:**
```bash
#!/bin/bash
export AWS_DB_ENDPOINT="https://your-api-gateway-url"
export AWS_API_KEY="your-api-key"
export SERVER_PORT="7000"
export SERVER_ID="server-1"

cd ~
./GalacticCombatServer.x86_64 --headless --server
```

### Make it executable:
```bash
chmod +x start_server.sh
```

### Run in Screen (keeps running after disconnect):
```bash
screen -S gameserver
./start_server.sh

# Detach with: Ctrl+A then D
# Reattach with: screen -r gameserver
```

---

## 🔄 Step 6: Create AWS Lambda Functions for Database

### Create Lambda Function (Python):

```python
import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('GalacticCombatPlayers')

def lambda_handler(event, context):
    action = event.get('action')
    
    if action == 'login':
        return handle_login(event)
    elif action == 'logout':
        return handle_logout(event)
    elif action == 'save_score':
        return save_score(event)
    
    return {
        'statusCode': 400,
        'body': json.dumps({'error': 'Unknown action'})
    }

def handle_login(event):
    player_id = event['player_id']
    
    response = table.update_item(
        Key={'player_id': player_id},
        UpdateExpression='SET online = :val, last_login = :time',
        ExpressionAttributeValues={
            ':val': True,
            ':time': Decimal(str(event['timestamp']))
        },
        ReturnValues='ALL_NEW'
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Login successful', 'player': response['Attributes']})
    }

def handle_logout(event):
    player_id = event['player_id']
    
    table.update_item(
        Key={'player_id': player_id},
        UpdateExpression='SET online = :val, last_logout = :time',
        ExpressionAttributeValues={
            ':val': False,
            ':time': Decimal(str(event['timestamp']))
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Logout successful'})
    }

def save_score(event):
    player_id = event['player_id']
    score = event['score']
    
    table.update_item(
        Key={'player_id': player_id},
        UpdateExpression='SET score = :score, updated_at = :time',
        ExpressionAttributeValues={
            ':score': Decimal(str(score)),
            ':time': Decimal(str(event['timestamp']))
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Score saved'})
    }
```

---

## 📊 Step 7: Create DynamoDB Table

### AWS Console → DynamoDB → Create Table:

**Table Name:** `GalacticCombatPlayers`

**Primary Key:** `player_id` (String)

**Attributes to add:**
- player_name (String)
- score (Number)
- level (Number)
- online (Boolean)
- last_login (Number - timestamp)
- last_logout (Number - timestamp)

---

## 🌍 Step 8: Set Up API Gateway

### AWS Console → API Gateway → Create API:

1. **Choose REST API**
2. **Create endpoints:**
   - `POST /player/login`
   - `POST /player/logout`
   - `POST /player/save`
   - `GET /player/{id}`

3. **Connect to Lambda functions**
4. **Deploy API** → Get your endpoint URL
5. **Enable CORS** if needed

---

## 💰 Cost Estimation (Monthly)

### Game Server (EC2):
- **t3.medium:** ~$30/month (24/7)
- **t3.large:** ~$60/month (24/7)

### Database (DynamoDB):
- **Free tier:** 25 GB storage, 25 WCU, 25 RCU
- **Beyond free:** ~$1/month per 10k players

### API Gateway:
- **Free tier:** 1 million API calls/month
- **Beyond free:** $3.50 per million calls

### Data Transfer:
- First 1 GB free
- ~$0.09/GB after

**Total Estimated Cost:** $30-70/month for small-medium game

---

## 🎯 Step 9: Connect Your Game to AWS Server

### Update Client Code:

```gdscript
# In your MainMenu.gd
func join_aws_server():
	var aws_server_ip = "YOUR_EC2_PUBLIC_IP"
	var port = 7000
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(aws_server_ip, port)
	
	if error != OK:
		print("Failed to connect to AWS server")
		return
	
	multiplayer.multiplayer_peer = peer
	print("Connecting to AWS server: ", aws_server_ip)
```

---

## 🔒 Security Best Practices

1. **Use IAM roles** for EC2 → Database access
2. **Enable encryption** for data in transit (SSL/TLS)
3. **Rotate API keys** regularly
4. **Use VPC** for internal communication
5. **Enable CloudWatch** for monitoring
6. **Set up Auto Scaling** for multiple servers
7. **Use Elastic IP** for static IP address

---

## 📈 Monitoring Your Server

### Install CloudWatch Agent:

```bash
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i amazon-cloudwatch-agent.deb
```

### Monitor:
- CPU usage
- Network traffic
- Active players
- Database queries

---

## 🚀 Auto-Start Server on Reboot

```bash
# Create systemd service
sudo nano /etc/systemd/system/gameserver.service
```

**Add:**
```ini
[Unit]
Description=Galactic Combat Game Server
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/home/ubuntu/start_server.sh
Restart=always

[Install]
WantedBy=multi-user.target
```

**Enable:**
```bash
sudo systemctl enable gameserver
sudo systemctl start gameserver
sudo systemctl status gameserver
```

---

## ✅ Testing Your Setup

1. **Test locally:** Connect to EC2 public IP from your game
2. **Check logs:** `tail -f server.log`
3. **Monitor CloudWatch:** See active connections
4. **Test database:** Verify player data is saving
5. **Load test:** Use multiple clients to test capacity

---

Your AWS dedicated server is now ready to handle online multiplayer! 🎮☁️
