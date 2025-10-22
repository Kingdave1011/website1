#!/bin/bash
# Space Shooter V2 - Linux Installation Script
# Created by NEXO GAMES

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# App information
APP_NAME="Space Shooter V2"
APP_VERSION="1.0"
PUBLISHER="NEXO GAMES"
EXECUTABLE="Space Shooter V2.x86_64"

# Installation paths
INSTALL_DIR="$HOME/.local/share/spaceshooter"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Space Shooter V2 Installer${NC}"
echo -e "${BLUE}  Created by NEXO GAMES${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run this installer as root/sudo${NC}"
    echo -e "${YELLOW}Run it as your regular user: ./SpaceShooter_Linux_Installer.sh${NC}"
    exit 1
fi

# Create directories
echo -e "${YELLOW}Creating installation directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"

# Copy game files
echo -e "${YELLOW}Installing game files...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$SCRIPT_DIR/SpaceShooterLinux" ]; then
    cp -r "$SCRIPT_DIR/SpaceShooterLinux/"* "$INSTALL_DIR/"
elif [ -f "$SCRIPT_DIR/$EXECUTABLE" ]; then
    cp -r "$SCRIPT_DIR/"* "$INSTALL_DIR/"
else
    echo -e "${RED}Error: Game files not found!${NC}"
    echo -e "${YELLOW}Please make sure this script is in the same directory as the game files.${NC}"
    exit 1
fi

# Make executable runnable
echo -e "${YELLOW}Setting permissions...${NC}"
chmod +x "$INSTALL_DIR/$EXECUTABLE"

# Create launcher script
echo -e "${YELLOW}Creating launcher script...${NC}"
cat > "$BIN_DIR/spaceshooter" << 'EOF'
#!/bin/bash
cd "$HOME/.local/share/spaceshooter"
exec "./$EXECUTABLE" "$@"
EOF

chmod +x "$BIN_DIR/spaceshooter"

# Create desktop entry
echo -e "${YELLOW}Creating desktop shortcut...${NC}"
cat > "$DESKTOP_DIR/spaceshooter.desktop" << EOF
[Desktop Entry]
Type=Application
Name=$APP_NAME
Comment=A thrilling space shooter game
Exec=$BIN_DIR/spaceshooter
Path=$INSTALL_DIR
Terminal=false
Categories=Game;ArcadeGame;
Keywords=game;shooter;space;arcade;
StartupNotify=true
EOF

chmod +x "$DESKTOP_DIR/spaceshooter.desktop"

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

# Create uninstaller
echo -e "${YELLOW}Creating uninstaller...${NC}"
cat > "$INSTALL_DIR/uninstall.sh" << 'UNINSTALL_EOF'
#!/bin/bash
echo "Uninstalling Space Shooter V2..."
rm -rf "$HOME/.local/share/spaceshooter"
rm -f "$HOME/.local/bin/spaceshooter"
rm -f "$HOME/.local/share/applications/spaceshooter.desktop"
echo "Space Shooter V2 has been uninstalled."
echo "Thank you for playing!"
UNINSTALL_EOF

chmod +x "$INSTALL_DIR/uninstall.sh"

# Installation complete
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${BLUE}How to play:${NC}"
echo -e "  • Launch from application menu: '$APP_NAME'"
echo -e "  • Or run from terminal: ${YELLOW}spaceshooter${NC}"
echo ""
echo -e "${BLUE}Controls:${NC}"
echo -e "  • Arrow Keys/WASD - Move ship"
echo -e "  • Space/Click - Shoot"
echo -e "  • ESC - Pause menu"
echo ""
echo -e "${BLUE}Installation location:${NC} $INSTALL_DIR"
echo -e "${BLUE}To uninstall:${NC} $INSTALL_DIR/uninstall.sh"
echo ""
echo -e "${GREEN}Thank you for playing Space Shooter V2!${NC}"
echo -e "${GREEN}Created by NEXO GAMES${NC}"
echo ""

# Offer to launch the game
read -p "Would you like to launch the game now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Launching Space Shooter V2...${NC}"
    cd "$INSTALL_DIR"
    "./$EXECUTABLE" &
    exit 0
fi
