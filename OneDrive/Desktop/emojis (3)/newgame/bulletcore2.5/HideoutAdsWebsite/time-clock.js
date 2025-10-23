// Local Time & Date Display Widget for HideoutAds.online
// Lightweight, real-time clock with 12/24 hour format toggle

class LocalTimeClock {
    constructor(containerId, options = {}) {
        this.container = document.getElementById(containerId);
        this.is24Hour = localStorage.getItem('clockFormat24') === 'true' || false;
        this.position = options.position || 'header'; // 'header' or 'corner'
        this.showDate = options.showDate !== false;
        this.showSeconds = options.showSeconds !== false;
        this.intervalId = null;
        
        if (!this.container && this.position === 'auto') {
            this.createAutoContainer();
        }
        
        if (this.container) {
            this.init();
        }
    }
    
    createAutoContainer() {
        // Create container in top-right corner if not exists
        const container = document.createElement('div');
        container.id = 'local-time-clock';
        container.style.cssText = `
            position: fixed;
            top: 15px;
            right: 15px;
            z-index: 9999;
            font-family: 'Orbitron', sans-serif;
        `;
        document.body.appendChild(container);
        this.container = container;
    }
    
    init() {
        this.container.innerHTML = `
            <div class="time-clock-widget" style="
                background: rgba(0, 0, 0, 0.7);
                backdrop-filter: blur(10px);
                border: 1px solid rgba(0, 198, 255, 0.3);
                border-radius: 8px;
                padding: 8px 12px;
                display: flex;
                align-items: center;
                gap: 10px;
                font-size: 0.85rem;
                color: #00C6FF;
                box-shadow: 0 0 10px rgba(0, 198, 255, 0.2);
                transition: all 0.3s;
                cursor: pointer;
                user-select: none;
            ">
                <div style="display: flex; flex-direction: column; gap: 2px;">
                    <div id="time-display" style="
                        font-weight: bold;
                        letter-spacing: 1px;
                        font-size: 0.95rem;
                    ">00:00:00</div>
                    <div id="date-display" style="
                        font-size: 0.7rem;
                        color: #888;
                        text-align: center;
                    ">Mon, Jan 1</div>
                </div>
                <div id="format-toggle" style="
                    font-size: 0.65rem;
                    padding: 2px 6px;
                    background: rgba(0, 198, 255, 0.2);
                    border-radius: 4px;
                    color: #00C6FF;
                    transition: all 0.2s;
                ">24H</div>
            </div>
            <style>
                .time-clock-widget:hover {
                    border-color: #00C6FF;
                    box-shadow: 0 0 20px rgba(0, 198, 255, 0.4);
                    transform: scale(1.02);
                }
                #format-toggle:hover {
                    background: rgba(0, 198, 255, 0.4);
                    color: white;
                }
                @media (max-width: 768px) {
                    .time-clock-widget {
                        font-size: 0.75rem;
                        padding: 6px 10px;
                    }
                    #time-display {
                        font-size: 0.85rem !important;
                    }
                    #date-display {
                        font-size: 0.65rem !important;
                    }
                }
            </style>
        `;
        
        // Set up toggle click handler
        const toggleBtn = document.getElementById('format-toggle');
        if (toggleBtn) {
            toggleBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                this.toggleFormat();
            });
        }
        
        // Update immediately and start interval
        this.updateTime();
        this.startClock();
    }
    
    toggleFormat() {
        this.is24Hour = !this.is24Hour;
        localStorage.setItem('clockFormat24', this.is24Hour.toString());
        
        const toggleBtn = document.getElementById('format-toggle');
        if (toggleBtn) {
            toggleBtn.innerText = this.is24Hour ? '24H' : '12H';
            
            // Flash animation
            toggleBtn.style.background = 'rgba(0, 198, 255, 0.6)';
            toggleBtn.style.color = 'white';
            setTimeout(() => {
                toggleBtn.style.background = 'rgba(0, 198, 255, 0.2)';
                toggleBtn.style.color = '#00C6FF';
            }, 200);
        }
        
        this.updateTime();
    }
    
    formatTime(date) {
        let hours = date.getHours();
        let minutes = date.getMinutes();
        let seconds = date.getSeconds();
        let period = '';
        
        if (!this.is24Hour) {
            period = hours >= 12 ? ' PM' : ' AM';
            hours = hours % 12 || 12;
        }
        
        const h = String(hours).padStart(2, '0');
        const m = String(minutes).padStart(2, '0');
        const s = String(seconds).padStart(2, '0');
        
        if (this.showSeconds) {
            return `${h}:${m}:${s}${period}`;
        }
        return `${h}:${m}${period}`;
    }
    
    formatDate(date) {
        const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        
        const dayName = days[date.getDay()];
        const monthName = months[date.getMonth()];
        const dayNum = date.getDate();
        
        return `${dayName}, ${monthName} ${dayNum}`;
    }
    
    updateTime() {
        const now = new Date();
        
        const timeDisplay = document.getElementById('time-display');
        const dateDisplay = document.getElementById('date-display');
        
        if (timeDisplay) {
            timeDisplay.innerText = this.formatTime(now);
        }
        
        if (dateDisplay && this.showDate) {
            dateDisplay.innerText = this.formatDate(now);
        }
    }
    
    startClock() {
        // Update every second
        this.intervalId = setInterval(() => {
            this.updateTime();
        }, 1000);
    }
    
    stopClock() {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    }
    
    destroy() {
        this.stopClock();
        if (this.container) {
            this.container.innerHTML = '';
        }
    }
}

// Easy initialization function
window.initLocalTimeClock = function(containerId, options) {
    return new LocalTimeClock(containerId, options);
};

// Auto-initialize in top-right corner if no container specified
if (typeof window !== 'undefined') {
    window.addEventListener('DOMContentLoaded', () => {
        // Check if container exists, if not create in corner
        let container = document.getElementById('local-time-clock');
        if (!container) {
            container = document.createElement('div');
            container.id = 'local-time-clock';
            container.style.cssText = `
                position: fixed;
                top: 70px;
                right: 15px;
                z-index: 9998;
                font-family: 'Orbitron', sans-serif;
            `;
            document.body.appendChild(container);
        }
        window.localClock = new LocalTimeClock('local-time-clock');
    });
}

// Export for module systems
if (typeof module !== 'undefined' && module.exports) {
    module.exports = LocalTimeClock;
}
