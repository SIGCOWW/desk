#!/bin/bash
ORG="SIGCOWW"
USER="sigcoww"

file="/home/${USER}/.ssh/authorized_keys"
rm -f $file
curl -s "https://api.github.com/orgs/${ORG}/members" | jq -r '.[] | select(.type == "User") | .login' | while read -r user; do
	sleep 1
	curl -s "https://api.github.com/users/${user}/keys" | jq -r '.[] | .key' | while read -r key; do
		line="command=\"build.sh\",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding ${key}"
		echo "$line" >> $file
	done
done

chmod 600 $file
chown "${USER}:${USER}" $file
