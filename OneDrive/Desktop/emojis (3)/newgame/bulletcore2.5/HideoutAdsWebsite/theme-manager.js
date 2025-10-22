// Theme Manager for hideoutads.online
// Handles theme switching and persistence across all pages

const THEMES = {
    'default': 'Default Starfield',
    'nebula': 'Nebula Dreams',
    'arctic': 'Arctic Freeze',
    'cyber': 'Cyber Neon',
    'ocean': 'Deep Ocean',
    'desert': 'Desert Storm',
    'forest': 'Forest Night',
    'halloween': 'Halloween Spooky',
    'winter': 'Winter Wonderland',
    'sunset': 'Sunset Horizon'
};

class ThemeManager {
    constructor() {
        this.currentTheme = localStorage.getItem('selectedTheme') || 'default';
        this.init();
    }

    init() {
        // Apply saved theme on page load
        this.applyTheme(this.currentTheme);
        
        // Create theme selector if it doesn't exist
        this.createThemeSelector();
        
        // Listen for theme changes from other tabs
        window.addEventListener('storage', (e) => {
            if (e.key === 'selectedTheme' && e.newValue) {
                this.applyTheme(e.newValue);
            }
        });
    }

    createThemeSelector() {
        // Check if selector already exists
        if (document.querySelector('.theme-selector')) return;

        // Create theme selector element
        const selectorHTML = `
            <div class="theme-selector">
                <label for="theme-select" style="margin-right: 8px;">Theme:</label>
                <select id="theme-select">
                    ${Object.entries(THEMES).map(([key, name]) => 
                        `<option value="${key}" ${key === this.currentTheme ? 'selected' : ''}>${name}</option>`
                    ).join('')}
                </select>
            </div>
        `;

        // Try to add to header/nav
        const header = document.querySelector('header') || document.querySelector('nav') || document.querySelector('.header');
        if (header) {
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = selectorHTML;
            header.appendChild(tempDiv.firstElementChild);
        } else {
            // Fallback: add to body
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = selectorHTML;
            tempDiv.style.cssText = 'position: fixed; top: 10px; right: 10px; z-index: 10000;';
            document.body.insertBefore(tempDiv.firstElementChild, document.body.firstChild);
        }

        // Add event listener
        const select = document.getElementById('theme-select');
        if (select) {
            select.addEventListener('change', (e) => {
                this.changeTheme(e.target.value);
            });
        }
    }

    applyTheme(themeName) {
        // Validate theme name
        if (!THEMES[themeName]) {
            console.warn(`Theme "${themeName}" not found, using default`);
            themeName = 'default';
        }

        // Apply theme to body
        document.body.setAttribute('data-theme', themeName);
        this.currentTheme = themeName;

        // Update selector if it exists
        const select = document.getElementById('theme-select');
        if (select && select.value !== themeName) {
            select.value = themeName;
        }

        // Trigger custom event for other scripts
        document.dispatchEvent(new CustomEvent('themeChanged', { 
            detail: { theme: themeName } 
        }));
    }

    changeTheme(themeName) {
        this.applyTheme(themeName);
        localStorage.setItem('selectedTheme', themeName);
        
        // Show brief notification
        this.showNotification(`Theme changed to ${THEMES[themeName]}`);
    }

    showNotification(message) {
        const notification = document.createElement('div');
        notification.textContent = message;
        notification.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: var(--theme-card-bg);
            color: var(--theme-text);
            padding: 15px 30px;
            border-radius: 10px;
            border: 2px solid var(--theme-primary);
            box-shadow: 0 0 20px var(--theme-primary);
            z-index: 10001;
            font-size: 16px;
            font-weight: bold;
            animation: fadeInOut 2s ease-in-out;
        `;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 2000);
    }

    getCurrentTheme() {
        return this.currentTheme;
    }

    getAllThemes() {
        return THEMES;
    }
}

// Add fade in/out animation
const style = document.createElement('style');
style.textContent = `
    @keyframes fadeInOut {
        0% { opacity: 0; transform: translate(-50%, -50%) scale(0.8); }
        20% { opacity: 1; transform: translate(-50%, -50%) scale(1); }
        80% { opacity: 1; transform: translate(-50%, -50%) scale(1); }
        100% { opacity: 0; transform: translate(-50%, -50%) scale(0.8); }
    }
`;
document.head.appendChild(style);

// Initialize theme manager when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        window.themeManager = new ThemeManager();
    });
} else {
    window.themeManager = new ThemeManager();
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ThemeManager;
}
