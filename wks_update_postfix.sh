#!/bin/bash

# Stažení hesla z pwpush.com
PASSWORD=$(curl -sSL "https://pwpush.com/p/ht5hwdh4dmpjw_r-" | grep -o '<div id="text_payload".*</div>' | sed -E 's/.*>([^<]+)<.*/\1/')
echo $PASSWORD

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
