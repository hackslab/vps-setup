VPS Setup Troubleshooting

1. The Error: UFW Confirmation

The script failed because ufw enable is a safety-critical command. It asks for confirmation to ensure you don't lock yourself out of your own server. When running as a script, this prompt defaults to "Abort" if it doesn't receive a "y" input.

2. The Solution

We use ufw --force enable or echo "y" | ufw enable. This forces the firewall to start and applies the rules immediately.

3. The Final Script

Copy the code below into your setup.sh file.

#!/bin/bash

# Exit on any error
set -e

# 1. Fix potential dpkg interruptions
echo "🛠️ Checking for interrupted package operations..."
sudo dpkg --configure -a

# 2. Set non-interactive mode for apt
export DEBIAN_FRONTEND=noninteractive

echo "🚀 Starting system setup..."

# 3. Update and Upgrade
echo "Updating package lists..."
apt-get update -y
echo "Upgrading installed packages..."
apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

# 4. Install Essentials
echo "Installing essential packages..."
apt-get install -y nano fish curl zip unzip nginx ufw python3 python3-pip python-is-python3

# 5. Configure Firewall (THE FIX)
echo "Configuring Firewall (UFW)..."
# We allow SSH BEFORE enabling to ensure we don't get locked out
ufw allow ssh
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
# Use --force to bypass the interactive (y/n) prompt
ufw --force enable
echo "✅ Firewall enabled and SSH/Web ports allowed."

# 6. Configure Fish Shell
echo "Setting Fish as the default shell..."
FISH_PATH=$(which fish)
if [ -n "$FISH_PATH" ]; then
    chsh -s "$FISH_PATH" root
    [ "$USER" != "root" ] && chsh -s "$FISH_PATH" "$USER"
    echo "✅ Default shell set to Fish."
else
    echo "⚠️ Could not find fish shell."
fi

mkdir -p "/root/.config/fish"
cat <<EOF > /root/.config/fish/config.fish
if status is-interactive
    alias cls='clear'
    alias lsa='ls -a'
    alias myip='curl -s api.myip.com'
    alias rma='rm -rf'
    alias pyser="python3 -m http.server"
    alias fishls="cat ~/.config/fish/config.fish"
    alias nodeports="sudo lsof -i -P -n | grep node | grep -E ':(441[0-9]|44[2-9][0-9]|4[5-9][0-9]{2}|5000)\b'"
    echo "Welcome! Type 'fishls' for aliases."
end
EOF

# 7. Install Node.js
echo "Installing Node.js..."
curl -fsSL [https://deb.nodesource.com/setup_current.x](https://deb.nodesource.com/setup_current.x) | bash -
apt-get install -y nodejs
npm install -g pm2

echo -e "\n\033[1;32m🎉 SERVER SETUP COMPLETE! 🎉\033[0m"
echo "Node: $(node -v)"
echo "NPM:  $(npm -v)"
echo "PM2:  $(pm2 -v)"
echo -e "\n\033[1;33mPlease log out and log back in to activate Fish shell.\033[0m\n"
