// Simple Cookie Manager for HideoutAds.online
// Non-intrusive cookie management for better user experience

const CookieManager = {
    // Set a cookie with optional expiry days (default 365 days)
    set(name, value, days = 365) {
        const date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        const expires = "expires=" + date.toUTCString();
        document.cookie = name + "=" + value + ";" + expires + ";path=/;SameSite=Lax";
    },

    // Get a cookie value by name
    get(name) {
        const nameEQ = name + "=";
        const ca = document.cookie.split(';');
        for (let i = 0; i < ca.length; i++) {
            let c = ca[i];
            while (c.charAt(0) === ' ') c = c.substring(1, c.length);
            if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
        }
        return null;
    },

    // Delete a cookie
    delete(name) {
        document.cookie = name + "=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
    },

    // Check if user has accepted cookies
    hasConsent() {
        return this.get('cookiesAccepted') === 'true';
    },

    // Set cookie consent
    setConsent(accepted) {
        this.set('cookiesAccepted', accepted ? 'true' : 'false', 365);
    },

    // Save user preferences
    savePreferences(prefs) {
        this.set('userPreferences', JSON.stringify(prefs), 365);
    },

    // Load user preferences
    loadPreferences() {
        const prefs = this.get('userPreferences');
        return prefs ? JSON.parse(prefs) : null;
    },

    // Save language preference
    saveLanguage(lang) {
        this.set('preferredLanguage', lang, 365);
    },

    // Load language preference
    loadLanguage() {
        return this.get('preferredLanguage') || 'en';
    },

    // Save theme preference
    saveTheme(theme) {
        this.set('preferredTheme', theme, 365);
    },

    // Load theme preference
    loadTheme() {
        return this.get('preferredTheme') || 'dark';
    },

    // Remember user login
    rememberUser(username) {
        this.set('rememberedUser', username, 30); // 30 days
    },

    // Get remembered user
    getRememberedUser() {
        return this.get('rememberedUser');
    },

    // Clear remembered user
    forgetUser() {
        this.delete('rememberedUser');
    }
};

// Simple cookie banner (non-intrusive)
function initCookieBanner() {
    // Only show if user hasn't made a choice
    if (CookieManager.hasConsent() === null || CookieManager.get('cookiesAccepted') === null) {
        const banner = document.createElement('div');
        banner.id = 'cookie-banner';
        banner.style.cssText = `
            position: fixed;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(0, 0, 0, 0.95);
            color: white;
            padding: 20px 30px;
            border-radius: 10px;
            box-shadow: 0 4px 20px rgba(0, 200, 255, 0.3);
            border: 2px solid #00C6FF;
            z-index: 10000;
            max-width: 90%;
            width: 500px;
            font-family: 'Orbitron', sans-serif;
            animation: slideUp 0.5s ease-out;
        `;
        
        banner.innerHTML = `
            <p style="margin: 0 0 15px 0; font-size: 0.95rem;">
                🍪 We use cookies to enhance your experience and save your preferences. 
                By continuing, you accept our use of cookies.
            </p>
            <div style="display: flex; gap: 10px; justify-content: center;">
                <button id="accept-cookies" style="
                    padding: 10px 20px;
                    background: linear-gradient(135deg, #00C6FF, #0072FF);
                    border: none;
                    border-radius: 5px;
                    color: white;
                    cursor: pointer;
                    font-family: 'Orbitron', sans-serif;
                    font-weight: bold;
                    transition: all 0.3s;
                ">Accept</button>
                <button id="decline-cookies" style="
                    padding: 10px 20px;
                    background: rgba(255, 255, 255, 0.1);
                    border: 2px solid rgba(255, 255, 255, 0.3);
                    border-radius: 5px;
                    color: white;
                    cursor: pointer;
                    font-family: 'Orbitron', sans-serif;
                    transition: all 0.3s;
                ">Decline</button>
            </div>
        `;
        
        document.body.appendChild(banner);
        
        // Add animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideUp {
                from {
                    opacity: 0;
                    transform: translateX(-50%) translateY(100px);
                }
                to {
                    opacity: 1;
                    transform: translateX(-50%) translateY(0);
                }
            }
            #accept-cookies:hover {
                transform: scale(1.05);
                box-shadow: 0 0 20px rgba(0, 198, 255, 0.5);
            }
            #decline-cookies:hover {
                background: rgba(255, 255, 255, 0.2);
            }
        `;
        document.head.appendChild(style);
        
        // Handle accept
        document.getElementById('accept-cookies').addEventListener('click', () => {
            CookieManager.setConsent(true);
            banner.remove();
            console.log('✅ Cookies accepted');
        });
        
        // Handle decline
        document.getElementById('decline-cookies').addEventListener('click', () => {
            CookieManager.setConsent(false);
            banner.remove();
            console.log('❌ Cookies declined - Essential functions only');
        });
    }
}

// Initialize on page load
if (typeof window !== 'undefined') {
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initCookieBanner);
    } else {
        initCookieBanner();
    }
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CookieManager;
}
