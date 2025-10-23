/**
 * Vercel Serverless Function - AI Bot Player
 * Endpoint: /api/ai-bot
 * Method: POST
 * 
 * Provides AI bot moves/actions for single player gameplay
 */

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle OPTIONS request for CORS
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { gameState, difficulty = 'medium', botId = 'AI_Bot_1' } = req.body || {};

    if (!gameState) {
      return res.status(400).json({
        success: false,
        error: 'gameState is required'
      });
    }

    // AI Bot difficulty settings
    const difficultySettings = {
      easy: {
        reactionTime: 300,
        accuracy: 0.6,
        moveSpeed: 0.7,
        aggressiveness: 0.4
      },
      medium: {
        reactionTime: 150,
        accuracy: 0.75,
        moveSpeed: 0.85,
        aggressiveness: 0.6
      },
      hard: {
        reactionTime: 50,
        accuracy: 0.9,
        moveSpeed: 1.0,
        aggressiveness: 0.85
      },
      expert: {
        reactionTime: 20,
        accuracy: 0.95,
        moveSpeed: 1.0,
        aggressiveness: 0.95
      }
    };

    const settings = difficultySettings[difficulty] || difficultySettings.medium;

    // Generate AI bot action based on game state
    const botAction = generateBotAction(gameState, settings);

    return res.status(200).json({
      success: true,
      bot: {
        id: botId,
        name: `AI Player (${difficulty.toUpperCase()})`,
        difficulty,
        action: botAction,
        stats: {
          accuracy: settings.accuracy * 100,
          reactionTime: settings.reactionTime,
          moveSpeed: settings.moveSpeed
        }
      }
    });

  } catch (error) {
    console.error('AI Bot API Error:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to generate AI bot action',
      message: error.message
    });
  }
}

/**
 * Generate bot action based on current game state
 */
function generateBotAction(gameState, settings) {
  const { player, enemies, powerups, botPosition } = gameState;

  // Decision making logic
  const action = {
    move: null,
    shoot: false,
    target: null,
    timestamp: Date.now()
  };

  // 1. Dodge incoming threats
  if (enemies && enemies.length > 0) {
    const nearestEnemy = findNearestThreat(botPosition, enemies);
    
    if (nearestEnemy && nearestEnemy.distance < 100) {
      // Evasive maneuver
      action.move = calculateEvasiveMove(botPosition, nearestEnemy.position, settings);
    }
  }

  // 2. Collect nearby powerups
  if (powerups && powerups.length > 0) {
    const nearestPowerup = findNearestPowerup(botPosition, powerups);
    
    if (nearestPowerup && nearestPowerup.distance < 150) {
      action.move = calculateMoveTowards(botPosition, nearestPowerup.position, settings);
    }
  }

  // 3. Attack enemies
  if (enemies && enemies.length > 0) {
    const targetEnemy = selectTarget(botPosition, enemies, settings);
    
    if (targetEnemy) {
      // Shoot based on accuracy setting
      const shouldShoot = Math.random() < settings.accuracy;
      
      if (shouldShoot) {
        action.shoot = true;
        action.target = targetEnemy;
      }

      // Move towards target if aggressive
      if (settings.aggressiveness > 0.6 && !action.move) {
        action.move = calculateMoveTowards(botPosition, targetEnemy.position, settings);
      }
    }
  }

  // 4. Default patrol behavior
  if (!action.move) {
    action.move = calculatePatrolMove(botPosition, settings);
  }

  return action;
}

/**
 * Find nearest threat to bot
 */
function findNearestThreat(botPos, enemies) {
  if (!botPos || !enemies || enemies.length === 0) return null;

  let nearest = null;
  let minDistance = Infinity;

  enemies.forEach(enemy => {
    const distance = calculateDistance(botPos, enemy.position);
    if (distance < minDistance) {
      minDistance = distance;
      nearest = { ...enemy, distance };
    }
  });

  return nearest;
}

/**
 * Find nearest powerup
 */
function findNearestPowerup(botPos, powerups) {
  if (!botPos || !powerups || powerups.length === 0) return null;

  let nearest = null;
  let minDistance = Infinity;

  powerups.forEach(powerup => {
    const distance = calculateDistance(botPos, powerup.position);
    if (distance < minDistance) {
      minDistance = distance;
      nearest = { ...powerup, distance };
    }
  });

  return nearest;
}

/**
 * Select best target to attack
 */
function selectTarget(botPos, enemies, settings) {
  if (!enemies || enemies.length === 0) return null;

  // Prioritize based on aggressiveness
  if (settings.aggressiveness > 0.7) {
    // Attack closest enemy
    return findNearestThreat(botPos, enemies);
  } else {
    // Attack weakest enemy
    return enemies.reduce((weakest, enemy) => {
      if (!weakest || enemy.health < weakest.health) {
        return enemy;
      }
      return weakest;
    }, null);
  }
}

/**
 * Calculate evasive movement
 */
function calculateEvasiveMove(botPos, threatPos, settings) {
  if (!botPos || !threatPos) return { x: 0, y: 0 };

  // Move perpendicular to threat direction
  const dx = botPos.x - threatPos.x;
  const dy = botPos.y - threatPos.y;
  const distance = Math.sqrt(dx * dx + dy * dy);

  if (distance === 0) return { x: 0, y: 0 };

  // Perpendicular movement
  return {
    x: (-dy / distance) * settings.moveSpeed * 100,
    y: (dx / distance) * settings.moveSpeed * 100
  };
}

/**
 * Calculate movement towards target
 */
function calculateMoveTowards(botPos, targetPos, settings) {
  if (!botPos || !targetPos) return { x: 0, y: 0 };

  const dx = targetPos.x - botPos.x;
  const dy = targetPos.y - botPos.y;
  const distance = Math.sqrt(dx * dx + dy * dy);

  if (distance === 0) return { x: 0, y: 0 };

  return {
    x: (dx / distance) * settings.moveSpeed * 100,
    y: (dy / distance) * settings.moveSpeed * 100
  };
}

/**
 * Calculate patrol movement
 */
function calculatePatrolMove(botPos, settings) {
  // Random patrol pattern
  const angle = Math.random() * Math.PI * 2;
  return {
    x: Math.cos(angle) * settings.moveSpeed * 50,
    y: Math.sin(angle) * settings.moveSpeed * 50
  };
}

/**
 * Calculate distance between two points
 */
function calculateDistance(pos1, pos2) {
  if (!pos1 || !pos2) return Infinity;
  const dx = pos1.x - pos2.x;
  const dy = pos1.y - pos2.y;
  return Math.sqrt(dx * dx + dy * dy);
}
