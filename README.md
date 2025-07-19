# remove-snap-from-ubuntu
This script removes snapd from Ubuntu, AND installs .debs of firefox and chromium, AND it works across updates

WARNING: This is mainly untested! It may break Ubuntu, as it uses Linux Mint repositories to install firefox and chromium! I DO NOT KNOW what this will cause. I put it on my main PC though, and it's working fine.

If you just want to install the .deb versions of firefox and chromium with apt, use [remove-snap.sh](https://github.com/PhoenixStormJr/remove-snap-from-ubuntu/blob/main/remove-snap.sh)

If you hate snap with a passion and want to nuke it entirely, use [completely-remove-snap.sh](https://github.com/PhoenixStormJr/remove-snap-from-ubuntu/blob/main/completely-remove-snap.sh)

After a SUCCESSFUL sudo apt update, and sudo apt upgrade, and restarting the PC, with no errors, I got the .deb versions on ubuntu:
<img width="1280" height="800" alt="Screenshot_20250719_003220" src="https://github.com/user-attachments/assets/b4b5670d-aa48-435a-9c1b-c18d0b916301" />
