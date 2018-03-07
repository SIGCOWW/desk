#!/bin/bash
ORG="SIGCOWW"
SERVER_USER="sigcoww"
TOKEN="$1"

file="/home/${SERVER_USER}/.ssh/authorized_keys"
rm -f $file

uri="https://api.github.com/orgs/${ORG}/members"
if [ "$TOKEN" != "" ]; then uri="${uri}?access_token=${TOKEN}"; fi
curl -s "$uri" | jq -r '.[] | select(.type == "User") | .login' | while read -r user; do
	sleep 1
	curl -s "https://api.github.com/users/${user}/keys" | jq -r '.[] | .key' | while read -r key; do
		line="command=\"/home/${SERVER_USER}/.ssh/allowed-commands.sh\",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ${key}"
		echo "$line" >> $file
	done
done

chmod 600 $file
chown "${SERVER_USER}:${SERVER_USER}" $file
