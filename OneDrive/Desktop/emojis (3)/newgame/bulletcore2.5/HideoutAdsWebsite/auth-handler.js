// Authentication Handler for Space Shooter Website
// This script manages user authentication state and UI updates

(function() {
    'use strict';

    // Check authentication status on page load
    function checkAuthStatus() {
        const authData = localStorage.getItem('space_shooter_auth');
        
        if (authData) {
            try {
                const auth = JSON.parse(authData);
                const now = Date.now();
                const hoursSinceLogin = (now - auth.timestamp) / (1000 * 60 * 60);
                
                // Keep session active for 24 hours
                if (hoursSinceLogin < 24) {
                    showUserProfile(auth);
                    showWelcomeNotification(auth);
                    
                    // Show admin panel for developers
                    if (auth.isAdmin || auth.username === 'King_davez' || auth.username === 'YourDailybrick') {
                        showAdminPanel();
                    }
                } else {
                    // Session expired
                    clearAuth();
                }
            } catch (e) {
                console.error('Auth parse error:', e);
                clearAuth();
            }
        }
    }

    // Show user profile in top-right corner
    function showUserProfile(auth) {
        const signInLink = document.querySelector('a[href="user-auth.html"]');
        if (!signInLink) return;

        // Replace sign-in link with profile dropdown
        const profileHTML = `
            <div class="user-profile" style="position: relative; display: inline-block;">
                <button id="profile-btn" style="padding: 8px 15px; background: rgba(0, 255, 0, 0.2); border: 2px solid #00FF00; border-radius: 8px; color: #00FF00; cursor: pointer; font-family: 'Rajdhani', sans-serif; display: flex; align-items: center; gap: 8px; font-size: 0.9rem; transition: all 0.3s;">
                    <span>👤</span>
                    <span>${auth.username}</span>
                    ${auth.isAdmin ? '<span style="color: #FFD700;">⚡</span>' : ''}
                </button>
                <div id="profile-menu" style="display: none; position: absolute; top: 100%; right: 0; margin-top: 10px; background: rgba(5, 5, 10, 0.95); border: 2px solid #00C6FF; border-radius: 8px; min-width: 200px; box-shadow: 0 0 20px rgba(0, 198, 255, 0.5); z-index: 1000;">
                    <div style="padding: 15px; border-bottom: 1px solid rgba(0, 198, 255, 0.3);">
                        <div style="color: #00C6FF; font-weight: 600; margin-bottom: 5px;">${auth.username}</div>
                        <div style="color: #8A2BE2; font-size: 0.85rem;">${auth.isGuest ? 'Guest Account' : 'Member'}</div>
                        ${auth.isAdmin ? '<div style="color: #FFD700; font-size: 0.85rem;">⚡ Developer</div>' : ''}
                    </div>
                    <div style="padding: 10px;">
                        <a href="profile.html" style="display: block; padding: 10px; color: #E0E0E0; text-decoration: none; border-radius: 5px; transition: background 0.3s; font-family: 'Rajdhani', sans-serif;" onmouseover="this.style.background='rgba(0, 198, 255, 0.2)'" onmouseout="this.style.background='transparent'">
                            ⚙️ Settings
                        </a>
                        <a href="leaderboard.html" style="display: block; padding: 10px; color: #E0E0E0; text-decoration: none; border-radius: 5px; transition: background 0.3s; font-family: 'Rajdhani', sans-serif;" onmouseover="this.style.background='rgba(0, 198, 255, 0.2)'" onmouseout="this.style.background='transparent'">
                            🏆 Leaderboard
                        </a>
                        <a href="https://space-shooter-634206651593.us-west1.run.app" target="_blank" style="display: block; padding: 10px; color: #00FF00; text-decoration: none; border-radius: 5px; transition: background 0.3s; font-family: 'Rajdhani', sans-serif; font-weight: 600;" onmouseover="this.style.background='rgba(0, 255, 0, 0.2)'" onmouseout="this.style.background='transparent'">
                            🎮 Launch Game
                        </a>
                        <button onclick="window.authHandler.signOut()" style="display: block; width: 100%; padding: 10px; background: transparent; border: none; color: #FF007F; text-align: left; cursor: pointer; border-radius: 5px; transition: background 0.3s; font-family: 'Rajdhani', sans-serif;" onmouseover="this.style.background='rgba(255, 0, 127, 0.2)'" onmouseout="this.style.background='transparent'">
                            🚪 Sign Out
                        </button>
                    </div>
                </div>
            </div>
        `;

        signInLink.outerHTML = profileHTML;

        // Add event listener to toggle profile menu
        setTimeout(() => {
            const profileBtn = document.getElementById('profile-btn');
            const profileMenu = document.getElementById('profile-menu');
            
            if (profileBtn && profileMenu) {
                profileBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    profileMenu.style.display = profileMenu.style.display === 'none' ? 'block' : 'none';
                });

                // Close menu when clicking outside
                document.addEventListener('click', () => {
                    profileMenu.style.display = 'none';
                });
            }
        }, 100);
    }

    // Show welcome notification
    function showWelcomeNotification(auth) {
        // Check if notification was already shown in this session
        const notificationShown = sessionStorage.getItem('welcome_shown');
        if (notificationShown) return;

        sessionStorage.setItem('welcome_shown', 'true');

        const notification = document.createElement('div');
        notification.style.cssText = `
            position: fixed;
            top: 100px;
            right: 20px;
            background: linear-gradient(135deg, #00C6FF 0%, #8A2BE2 100%);
            color: #fff;
            padding: 20px 30px;
            border-radius: 12px;
            box-shadow: 0 0 30px rgba(0, 198, 255, 0.8);
            z-index: 10001;
            font-family: 'Orbitron', sans-serif;
            animation: slideIn 0.5s ease-out;
            max-width: 350px;
        `;

        const welcomeMessages = [
            `Welcome back, ${auth.username}! 🚀`,
            `Ready for action, ${auth.username}? 🎮`,
            `Good to see you, ${auth.username}! ⭐`,
            `Welcome to the game, ${auth.username}! 🌌`
        ];

        const message = auth.isAdmin 
            ? `Welcome, Developer ${auth.username}! ⚡` 
            : welcomeMessages[Math.floor(Math.random() * welcomeMessages.length)];

        notification.innerHTML = `
            <div style="font-size: 1.2rem; font-weight: 700; margin-bottom: 10px;">${message}</div>
            <div style="font-size: 0.9rem; font-family: 'Rajdhani', sans-serif; opacity: 0.9;">
                You're automatically authenticated for the game!
            </div>
            ${getRewardMessage(auth)}
        `;

        document.body.appendChild(notification);

        // Auto-remove after 5 seconds
        setTimeout(() => {
            notification.style.opacity = '0';
            notification.style.transition = 'opacity 0.5s ease-out';
            setTimeout(() => notification.remove(), 500);
        }, 5000);
    }

    // Get reward message if user has rewards
    function getRewardMessage(auth) {
        const starterBundle = localStorage.getItem(`starter_bundle_${auth.username}`);
        const referralBonus = localStorage.getItem(`referral_bonus_${auth.username}`);

        if (starterBundle) {
            const bundle = JSON.parse(starterBundle);
            if (bundle.message) {
                localStorage.removeItem(`starter_bundle_${auth.username}`); // Clear after showing
                return `<div style="margin-top: 10px; padding: 10px; background: rgba(255, 215, 0, 0.2); border-radius: 8px; font-family: 'Rajdhani', sans-serif;">${bundle.message}</div>`;
            }
        }

        if (referralBonus) {
            const bonus = JSON.parse(referralBonus);
            if (bonus.message) {
                localStorage.removeItem(`referral_bonus_${auth.username}`); // Clear after showing
                return `<div style="margin-top: 10px; padding: 10px; background: rgba(255, 215, 0, 0.2); border-radius: 8px; font-family: 'Rajdhani', sans-serif;">${bonus.message}</div>`;
            }
        }

        return '';
    }

    // Show admin panel button for developer
    function showAdminPanel() {
        const adminBtn = document.createElement('button');
        adminBtn.id = 'admin-panel-btn';
        adminBtn.style.cssText = `
            position: fixed;
            bottom: 20px;
            right: 20px;
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, #8A2BE2 0%, #FF007F 100%);
            border: 2px solid #FFD700;
            border-radius: 50%;
            color: #FFD700;
            font-size: 1.8rem;
            cursor: pointer;
            box-shadow: 0 0 20px rgba(138, 43, 226, 0.6);
            z-index: 10000;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
        `;
        adminBtn.innerHTML = '⚡';
        adminBtn.title = 'Admin Panel';

        adminBtn.addEventListener('mouseenter', () => {
            adminBtn.style.transform = 'scale(1.1) rotate(15deg)';
            adminBtn.style.boxShadow = '0 0 30px rgba(255, 215, 0, 0.8)';
        });

        adminBtn.addEventListener('mouseleave', () => {
            adminBtn.style.transform = 'scale(1) rotate(0deg)';
            adminBtn.style.boxShadow = '0 0 20px rgba(138, 43, 226, 0.6)';
        });

        adminBtn.addEventListener('click', () => {
            window.location.href = 'admin-panel.html';
        });

        document.body.appendChild(adminBtn);
    }

    // Show admin modal
    function showAdminModal() {
        const modal = document.createElement('div');
        modal.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.9);
            z-index: 10002;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: fadeIn 0.3s;
        `;

        modal.innerHTML = `
            <div style="background: rgba(5, 5, 10, 0.95); border: 3px solid #FFD700; border-radius: 15px; padding: 30px; max-width: 600px; width: 90%; box-shadow: 0 0 40px rgba(255, 215, 0, 0.5);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                    <h2 style="color: #FFD700; font-family: 'Orbitron', sans-serif; margin: 0;">⚡ Admin Panel</h2>
                    <button onclick="this.closest('div').parentElement.remove()" style="background: transparent; border: none; color: #FFD700; font-size: 2rem; cursor: pointer; padding: 0; width: 40px; height: 40px;">×</button>
                </div>
                
                <div style="color: #E0E0E0; font-family: 'Rajdhani', sans-serif;">
                    <div style="background: rgba(138, 43, 226, 0.2); border-left: 3px solid #8A2BE2; padding: 15px; margin-bottom: 20px; border-radius: 5px;">
                        <strong style="color: #00C6FF;">Developer Access</strong><br>
                        Welcome to the admin panel. This is only visible to you.
                    </div>
                    
                    <div style="display: grid; gap: 15px;">
                        <button onclick="window.location.href='leaderboard.html'" style="padding: 15px; background: rgba(0, 198, 255, 0.2); border: 2px solid #00C6FF; border-radius: 8px; color: #00C6FF; cursor: pointer; font-family: 'Rajdhani', sans-serif; font-size: 1rem; transition: all 0.3s;">
                            📊 View Leaderboard
                        </button>
                        
                        <button onclick="window.authHandler.viewUsers()" style="padding: 15px; background: rgba(138, 43, 226, 0.2); border: 2px solid #8A2BE2; border-radius: 8px; color: #8A2BE2; cursor: pointer; font-family: 'Rajdhani', sans-serif; font-size: 1rem; transition: all 0.3s;">
                            👥 View All Users
                        </button>
                        
                        <button onclick="window.authHandler.clearAllData()" style="padding: 15px; background: rgba(255, 0, 127, 0.2); border: 2px solid #FF007F; border-radius: 8px; color: #FF007F; cursor: pointer; font-family: 'Rajdhani', sans-serif; font-size: 1rem; transition: all 0.3s;">
                            🗑️ Clear All Data
                        </button>
                    </div>
                </div>
            </div>
        `;

        document.body.appendChild(modal);

        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.remove();
            }
        });
    }

    // View all users (admin only)
    function viewUsers() {
        const users = [];
        for (let i = 0; i < localStorage.length; i++) {
            const key = localStorage.key(i);
            if (key.startsWith('acct_')) {
                const username = key.replace('acct_', '');
                const data = JSON.parse(localStorage.getItem(key));
                users.push({ username, email: data.email, created: new Date(data.created).toLocaleString() });
            }
        }

        alert(`Total Users: ${users.length}\n\n` + users.map(u => `${u.username} (${u.email})\nCreated: ${u.created}`).join('\n\n'));
    }

    // Clear all data (admin only)
    function clearAllData() {
        if (confirm('Are you sure you want to clear ALL user data? This cannot be undone!')) {
            if (confirm('FINAL WARNING: This will delete all accounts and progress!')) {
                localStorage.clear();
                sessionStorage.clear();
                alert('All data cleared!');
                window.location.reload();
            }
        }
    }

    // Clear authentication
    function clearAuth() {
        localStorage.removeItem('space_shooter_auth');
        sessionStorage.removeItem('space_shooter_auth');
        sessionStorage.removeItem('welcome_shown');
    }

    // Sign out
    function signOut() {
        if (confirm('Are you sure you want to sign out?')) {
            clearAuth();
            window.location.reload();
        }
    }

    // Expose public methods
    window.authHandler = {
        checkAuthStatus,
        signOut,
        viewUsers,
        clearAllData
    };

    // Initialize on page load
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', checkAuthStatus);
    } else {
        checkAuthStatus();
    }
})();
