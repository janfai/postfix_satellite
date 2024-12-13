#!/bin/bash

# Stažení hesla z pwpush.com
PASSWORD=$(curl -sSL https://pwpush.com/p/8hviagnkymw/r | grep -o '<div class="payload">[^<]*' | sed 's/<div class="payload">//')

# Nastavení proměnných
RELAY_HOST="mail.faix.cz"
USERNAME="mail@faix.cz"

# Aktualizace souboru relay_passwd
echo "$RELAY_HOST $USERNAME:$PASSWORD" | sudo tee /etc/postfix/relay_passwd > /dev/null

# Vytvoření databáze
sudo postmap /etc/postfix/relay_passwd

# Restart Postfixu
sudo systemctl restart postfix

echo "Přihlašovací údaje pro Postfix byly úspěšně aktualizovány."
