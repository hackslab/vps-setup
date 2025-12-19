#!/bin/bash

set -e

echo "🚀 Starting system setup..."
echo "Updating package lists..."
apt-get update -y

echo "Upgrading installed packages..."
apt-get upgrade -y

echo "Installing essential packages..."
apt-get install -y nano fish curl zip unzip nginx ufw

echo "Configuring Firewall (UFW)..."
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 22
sudo ufw allow 22/tcp
echo "✅ Firewall enabled and SSH allowed."

echo "Setting Fish as the default shell for the current user and root..."

FISH_PATH=$(which fish)

if [ -n "$FISH_PATH" ]; then
    chsh -s "$FISH_PATH" "$USER"
    echo "✅ Default shell for user '$USER' set to Fish."
else
    echo "⚠️ Could not find fish shell executable. Skipping default shell setup."
fi

echo "Configuring Fish shell aliases and interactive session settings..."

mkdir -p "/root/.config/fish"
cat <<EOF > /root/.config/fish/config.fish
if status is-interactive
    alias cls='clear'
    alias lsa='ls -a'
    alias myip='curl api.myip.com'
    alias rma='rm -rf'
    alias pyser="python3 -m http.server"
    alias fishls="cat ~/.config/fish/config.fish"
    alias nodeports="sudo lsof -i -P -n | grep node | grep -E ':(441[0-9]|44[2-9][0-9]|4[5-9][0-9]{2}|5000)\b'"
end
EOF

echo "✅ Fish configuration updated for root."

echo "Installing the latest version of Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_current.x | bash -
apt-get install -y nodejs
echo "✅ Node.js and npm installed successfully."
node -v
npm -v

echo "Installing the latest Python 3 and pip..."
apt-get install -y python3 python3-pip python-is-python3
echo "✅ Python 3 and pip installed successfully."
python --version
pip --version

echo "Installing PM2 process manager globally..."
npm install -g pm2
echo "✅ PM2 installed successfully."
pm2 --version

echo -e "\n\n"
echo -e "    \e[1;32m****************************************************\e[0m"
echo -e "    \e[1;32m* *\e[0m"
echo -e "    \e[1;32m* 🎉 SERVER SETUP COMPLETE! 🎉           *\e[0m"
echo -e "    \e[1;32m* *\e[0m"
echo -e "    \e[1;32m****************************************************\e[0m"
echo -e "\n\e[1;34mEverything is ready for you. Here's a summary:\e[0m"
echo "    - System is fully updated and upgraded."
echo "    - Nano, Zip, Unzip, and Nginx are installed."
echo "    - UFW Firewall is active (SSH allowed)."
echo "    - Fish is your new default shell with custom aliases."
echo "    - Node.js (Latest), npm, and PM2 are ready."
echo "    - Python 3 and Pip are installed."
echo -e "\n\e[1;33mIMPORTANT: To start using the Fish shell, you must log out and log back in.\e[0m"
echo -e "\nEnjoy your new, powerful development environment! 🚀\n"

# Self-destruct: Delete this script after completion
rm -- "$0"
