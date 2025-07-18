#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Get Ubuntu version as float (e.g., 24.05 becomes 24.05)
ubuntu_version=$(lsb_release -rs)
ubuntu_major=$(echo "$ubuntu_version" | cut -d. -f1)
ubuntu_minor=$(echo "$ubuntu_version" | cut -d. -f2)
ubuntu_float=$(printf "%.2f" "$ubuntu_major.$ubuntu_minor")

echo "[*] Detected Ubuntu version: $ubuntu_float"

# Determine the closest lower or equal Ubuntu base version Mint supports
if (( $(echo "$ubuntu_float >= 24.04" | bc -l) )); then
    mint_codename="xia"         # Mint 22 → Ubuntu 24.04
elif (( $(echo "$ubuntu_float >= 22.04" | bc -l) )); then
    mint_codename="vanessa"     # Mint 21.1 → Ubuntu 22.04
elif (( $(echo "$ubuntu_float >= 20.04" | bc -l) )); then
    mint_codename="ulyana"      # Mint 20 → Ubuntu 20.04
else
    echo "[-] No compatible Mint codename found for Ubuntu $ubuntu_float"
    exit 1
fi

echo "[+] Using Linux Mint codename: $mint_codename (for Ubuntu base <= $ubuntu_float)"

repo_file="/etc/apt/sources.list.d/linuxmint.list"
gpg_file="/etc/apt/trusted.gpg.d/linuxmint.gpg"
pin_file="/etc/apt/preferences.d/linuxmint"

# Only configure if not already done
if [[ -f "$repo_file" && -f "$gpg_file" && -f "$pin_file" ]]; then
    echo "[*] Mint repo, GPG key, and pinning already configured — skipping setup."
else
    echo "[+] Configuring Linux Mint repo and pinning..."

    #Downloading Linux Mint key or just exiting if failed:
    echo "Adding linuxmint GPG key to your system"
    # Add Mint GPG key
    if ! sudo wget -q https://raw.githubusercontent.com/PhoenixStormJr/remove-snap-from-ubuntu/main/linuxmint-keyring.gpg -O /etc/apt/trusted.gpg.d/linuxmint.gpg; then
        echo "❌ Failed to download Mint GPG key. Exiting."
        exit 1
    fi

    # Add Mint repo for chosen codename
    echo "Adding linuxmint repo to your system with codename $mint_codename"
    echo "deb http://packages.linuxmint.com $mint_codename main upstream import backport" | sudo tee "$repo_file"

    echo "Pinning firefox and chromium to apt"
    # Pin only firefox and chromium at top priority; block everything else
    sudo tee "/etc/apt/preferences.d/linuxmint" > /dev/null <<EOF
Package: firefox chromium
Pin: origin packages.linuxmint.com
Pin-Priority: 1001

Package: ubuntu-system-adjustments mintsystem mint-common mint-translations mint-info mint-info-xfce
Pin: origin packages.linuxmint.com
Pin-Priority: 501

Package: *
Pin: origin packages.linuxmint.com
Pin-Priority: -1
EOF

    echo "[+] Mint repo and pinning set up for codename '$mint_codename'."
fi


echo "Checking for Snap versions of Firefox/Chromium to remove..."
if command -v snap >/dev/null; then
    sudo snap remove --purge firefox || true
    sudo snap remove --purge chromium || true
    sudo snap remove --purge chromium-browser || true
fi


# Update and install Firefox and Chromium from Mint
echo "Installing DEB versions of firefox and chromium"
sudo apt update
sudo apt install -y firefox chromium

echo "[✓] Firefox and Chromium installed from Linux Mint '$mint_codename' repo."
