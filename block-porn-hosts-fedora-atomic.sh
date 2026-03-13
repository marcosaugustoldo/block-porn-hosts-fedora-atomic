cat > ~/block-porn-hosts-multi.sh << 'EOF'
#!/bin/bash
# Multi-language anti-porn blocker for Fedora Atomic

set -e

# Detectar idioma
LANG_ID=$(locale | grep '^LANG=' | cut -d= -f2 | cut -d. -f1 | cut -d_ -f1,2 2>/dev/null || echo "en_US")
case "$LANG_ID" in
  "pt_BR"|"pt")
    MSG_TITLE="🔒 Configurando bloqueio multi-camadas no Fedora Atomic..."
    MSG_HOSTS="Atualizando /etc/hosts com listas anti-porn..."
    MSG_BACKUP="Backup criado: /etc/hosts.backup.$(date +%Y%m%d)"
    MSG_CLEAN="Limpando cache DNS..."
    MSG_TEST="Teste: ping pornhub.com deve falhar."
    MSG_BLOK="✓ Bloqueado OK"
    MSG_WARN="AVISO: Ainda resolve!"
    MSG_POL="Criando políticas browsers..."
    MSG_DONE="✅ Tudo configurado!"
    MSG_CHECK="Verifique: Firefox/Zen: about:policies | Brave/Chrome: chrome://policy/"
    MSG_REV="Reverter hosts: sudo mv /etc/hosts.backup.* /etc/hosts"
    ;;
  "en_US"|"en")
    MSG_TITLE="🔒 Setting up multi-layer blocking on Fedora Atomic..."
    MSG_HOSTS="Updating /etc/hosts with anti-porn lists..."
    MSG_BACKUP="Backup created: /etc/hosts.backup.$(date +%Y%m%d)"
    MSG_CLEAN="Clearing DNS cache..."
    MSG_TEST="Test: ping pornhub.com should fail."
    MSG_BLOK="✓ Blocked OK"
    MSG_WARN="WARNING: Still resolves!"
    MSG_POL="Creating browser policies..."
    MSG_DONE="✅ All set!"
    MSG_CHECK="Check: Firefox/Zen: about:policies | Brave/Chrome: chrome://policy/"
    MSG_REV="Revert hosts: sudo mv /etc/hosts.backup.* /etc/hosts"
    ;;
  *)
    # Fallback inglês
    LANG_ID="en_US"
    MSG_TITLE="🔒 Multi-layer blocking setup..."
    # ... (resto igual en_US)
    ;;
esac

echo "$MSG_TITLE"

# Hosts block (mesmo código)
sudo cp /etc/hosts "/etc/hosts.backup.$(date +%Y%m%d)"
echo "$MSG_HOSTS"

wget -qO /tmp/porn-hosts "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn/hosts"
grep "^0\\.0\\.0\\.0" /tmp/porn-hosts | sort -u | sudo tee -a /etc/hosts > /dev/null

wget -qO /tmp/paul-list "https://raw.githubusercontent.com/paulbrandie/Pi-Hole-Porn-Blocking/main/Porn-Blocking-List.txt"
grep "^0\\.0\\.0\\.0" /tmp/paul-list | cut -d' ' -f2- | sed 's/^/0.0.0.0 /' | sort -u | sudo tee -a /etc/hosts > /dev/null

echo "$MSG_CLEAN"
sudo systemctl restart systemd-networkd 2>/dev/null || true
sudo systemctl restart NetworkManager 2>/dev/null || true

PING_FAIL=1
ping -c1 pornhub.com >/dev/null 2>&1 && PING_FAIL=0
echo "$MSG_TEST $(test $PING_FAIL -eq 1 && echo "$MSG_BLOK" || echo "$MSG_WARN")"

echo "$MSG_BACKUP"

# Políticas (comentários traduzidos internamente)
echo "$MSG_POL"

sudo mkdir -p /etc/firefox/policies
cat > /tmp/firefox-policy.json << 'EOF'
{"policies":{"DisablePrivateBrowsing":true}}
EOF
sudo cp /tmp/firefox-policy.json /etc/firefox/policies/policies.json

sudo mkdir -p /etc/brave/policies/managed
cat > /tmp/brave-policy.json << 'EOF'
{"IncognitoModeAvailability":1,"BrowserGuestModeEnabled":false}
EOF
sudo cp /tmp/brave-policy.json /etc/brave/policies/managed/disable-private.json

mkdir -p ~/.var/app/com.google.Chrome/config/google-chrome/policies/managed
cp /tmp/brave-policy.json ~/.var/app/com.google.Chrome/config/google-chrome/policies/managed/disable-private.json

mkdir -p ~/.var/app/app.zen_browser.zen/config/firefox/policies
sudo cp /tmp/firefox-policy.json ~/.var/app/app.zen_browser.zen/config/firefox/policies/policies.json

rm /tmp/*.json

echo "$MSG_DONE"
echo "$MSG_CHECK"
echo "Reinicie browsers."
echo "$MSG_REV"
EOF

chmod +x ~/block-porn-hosts-multi.sh
~/block-porn-hosts-multi.sh

