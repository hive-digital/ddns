#!/bin/bash

set -e

DYNAMIC_CONFIG_FILE="/etc/bind/dynamic/${SERVER_DOMAIN}"
CONFIG_FILE="/etc/bind/named.conf"
KEY_FILE="/etc/bind/${SERVER_DOMAIN}.key"
LOG_DIRECTORY="/var/log/bind"

# Initialize default DNS config
if [[ -f "/etc/bind/dynamic/domain.tld" ]];
    then
        printf "Initializing DNS configuration...\n"

        # Rename default DNS config
        mv /etc/bind/dynamic/domain.tld "$DYNAMIC_CONFIG_FILE"

        # Replace default DNS config variables
        sed -i -e "s/\$SERVER_EMAIL/${SERVER_EMAIL}/" "$DYNAMIC_CONFIG_FILE"
        sed -i -e "s/\$NAMESERVER_DOMAIN/${NAMESERVER_DOMAIN}/" "$DYNAMIC_CONFIG_FILE"
        sed -i -e "s/\$SERVER_DOMAIN/${SERVER_DOMAIN}/" "$DYNAMIC_CONFIG_FILE"
        sed -i -e "s/\$SERVER_IP/${SERVER_IP}/" "$DYNAMIC_CONFIG_FILE"
        sed -i -e "s/\$DATE/$(date +'%Y%m%d')01/" "$DYNAMIC_CONFIG_FILE"
        sed -i -e "s/\$SERVER_DOMAIN/${SERVER_DOMAIN}/" "$CONFIG_FILE"

        # Create log folder
        mkdir -p "$LOG_DIRECTORY"

        # Create TSIG key
        tsig-keygen -a HMAC-SHA256 "${SERVER_DOMAIN}" >> "$KEY_FILE"

        # Set directory permissions
        chown -R bind:bind "$LOG_DIRECTORY"
        chown -R bind:bind /etc/bind /var/cache/bind
        printf "Done.\n\n"
fi

# Start DNS service
printf "Starting DNS service...\n"
exec /usr/sbin/named -u "bind" -4 -c "$CONFIG_FILE" &
printf "Done.\n\n"

# Install development dependencies
printf "Installing development dependencies...\n"
bun install --no-save
printf "Done.\n\n"

# Start development service
printf "Starting API endpoint...\n"
DOMAIN=$SERVER_DOMAIN TSIG_KEY="$(cat "$KEY_FILE")" bun run dev
