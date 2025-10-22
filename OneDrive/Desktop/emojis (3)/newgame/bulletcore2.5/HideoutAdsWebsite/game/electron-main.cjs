const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1280,
        height: 720,
        minWidth: 800,
        minHeight: 600,
        title: 'Space Shooter V5 - Halloween Edition',
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            enableRemoteModule: false,
            devTools: false
        },
        backgroundColor: '#000000',
        autoHideMenuBar: true,
        fullscreenable: true
    });

    // Load the game
    if (app.isPackaged) {
        mainWindow.loadFile(path.join(__dirname, 'dist/index.html'));
    } else {
        mainWindow.loadFile('dist/index.html');
    }

    // Remove menu in production
    if (app.isPackaged) {
        Menu.setApplicationMenu(null);
    }

    mainWindow.on('closed', () => {
        mainWindow = null;
    });

    mainWindow.maximize();
}

app.whenReady().then(() => {
    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});
