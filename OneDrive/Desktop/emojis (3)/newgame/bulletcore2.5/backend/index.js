require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Space Shooter Backend is running!' });
});

// Leaderboard endpoint (mock data - replace with database)
app.get('/api/leaderboard', (req, res) => {
    res.json({
        success: true,
        data: []  // Empty initially - will be populated by Supabase
    });
});

// Save player data endpoint
app.post('/api/save-player', (req, res) => {
    const playerData = req.body;
    // This will be handled by Supabase on frontend
    res.json({ success: true, message: 'Use Supabase for data persistence' });
});

// Start server
app.listen(PORT, () => {
    console.log(`✅ Space Shooter Backend running on port ${PORT}`);
    console.log(`📍 http://localhost:${PORT}/api/health`);
});
