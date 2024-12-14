#!/bin/bash

# Název: Aktualizace konfigurace Postfix
# Popis: Tento skript aktualizuje konfiguraci Postfixu, včetně nastavení relay hosta
#        a přihlašovacích údajů. Po provedení změn ověří úspěšnost aktualizace
#        a odešle výsledek na zadaný e-mail.
#
# Použití: Tento skript lze stáhnout a spustit jedním příkazem:
#   curl -sSL https://raw.githubusercontent.com/janfai/postfix_satellite/main/wks_update_postfix.sh | sudo bash
#
# Poznámka: Ujistěte se, že máte nainstalovaný curl a spouštíte příkaz s právy sudo.

# Nastavení proměnných
ADMIN_EMAIL="jan@faix.cz"
PASSWORD_URL="https://pwpush.com/p/ht5hwdh4dmpjw_r-"
RELAY_HOST="mail.faix.cz"
USERNAME="mail@faix.cz"

# Stažení hesla z pwpush.com
PASSWORD=$(curl -sSL "$PASSWORD_URL" | grep -o '<div id="text_payload".*</div>' | sed -E 's/.*>([^<]+)<.*/\1/')
echo $PASSWORD

# Aktualizace souboru relay_passwd
echo "$RELAY_HOST $USERNAME:$PASSWORD" | sudo tee /etc/postfix/relay_passwd > /dev/null

# Vytvoření databáze
sudo postmap /etc/postfix/relay_passwd

# Restart Postfixu
sudo systemctl restart postfix

# Funkce pro ověření změny
check_relay_passwd() {
    if grep -q "$USERNAME" /etc/postfix/relay_passwd; then
        return 0
    else
        return 1
    fi
}

# Funkce pro odeslání výsledku emailem
send_result_email() {
    local subject="Výsledek změny konfigurace Postfixu"
    local body="$1"
    echo "$body" | mail -s "$subject" $ADMIN_EMAIL
}

# Ověření změny a odeslání výsledku
if check_relay_passwd; then
    send_result_email "Změna konfigurace Postfixu byla úspěšná."
    echo "Přihlašovací údaje pro Postfix byly úspěšně aktualizovány."
else
    send_result_email "Změna konfigurace Postfixu nebyla úspěšná. Uživatelské jméno '$USERNAME' nebylo nalezeno v souboru /etc/postfix/relay_passwd."
    echo "Chyba: Aktualizace přihlašovacích údajů pro Postfix se nezdařila."
fi
