Multi-language script for **multi-layer adult site blocking** on **Fedora Atomic** (Silverblue/Kinoite 43+). Automatically configures `/etc/hosts` + policies for **Brave, Firefox, Chrome Flatpak, and Zen Browser**, bypassing immutable system limitations (read-only /usr).

## Features

- **Local DNS blocking** via `/etc/hosts` using StevenBlack + PaulBrandie lists
- **Disables private mode** across 4 browsers simultaneously
- **Multi-language**: Portuguese (pt_BR) / English (en_US) via `locale`
- **100% compatible** with Fedora Atomic rpm-ostree (no symlinks to read-only /usr)
- **Automatic backup** + effectiveness test + DNS cache clearing
- **Persistent** after `rpm-ostree upgrade`

## Prerequisites

```bash
# Fedora Atomic 43+ (Silverblue/Kinoite/Sericea)
# Browsers installed:
# - Brave (rpm-ostree layer)
# - Firefox (rpm-ostree or base)
# - Chrome (flatpak com.google.Chrome)
# - Zen Browser (flatpak app.zen_browser.zen)
```

## Installation & Usage

```bash
# 1. Download
curl -sL https://raw.githubusercontent.com/YOURUSERNAME/block-porn-hosts/main/block-porn-hosts-multi.sh -o ~/block-porn-hosts.sh

# 2. Execute
chmod +x ~/block-porn-hosts.sh
~/block-porn-hosts.sh
```

**Expected output (en_US):**
```
🔒 Setting up multi-layer blocking on Fedora Atomic...
Updating /etc/hosts with anti-porn lists...
Clearing DNS cache...
Test: ping pornhub.com should fail. ✓ Blocked OK
Backup created: /etc/hosts.backup.20260313
Creating browser policies...
✅ All set!
Check: Firefox/Zen: about:policies | Brave/Chrome: chrome://policy/
```

## Verification

| Browser | Verification URL | Expected Result |
|---------|------------------|-----------------|
| **Firefox/Zen** | `about:policies` | `"DisablePrivateBrowsing": true` |
| **Brave/Chrome** | `chrome://policy/` | `"IncognitoModeAvailability": 1` |
| **Hosts** | `ping pornhub.com` | `0.0.0.0` / fails |

**Private mode removed** from menus (Ctrl+Shift+P fails).

## Maintenance

```bash
# Update hosts lists (weekly)
~/block-porn-hosts.sh

# Revert hosts
sudo mv /etc/hosts.backup.20260313 /etc/hosts

# Check rpm-ostree status
rpm-ostree status
```

## Created Files Structure

```
/etc/hosts                              # +10k blocked domains
/etc/hosts.backup.20260313              # Original backup
/etc/firefox/policies/policies.json     # Firefox/Zen
/etc/brave/policies/managed/disable-private.json  # Brave
~/.var/app/com.google.Chrome/.../disable-private.json  # Chrome Flatpak
~/.var/app/app.zen_browser.zen/.../policies.json     # Zen Flatpak
```

## Supported Languages

| Code | Language | Detection |
|------|----------|-----------|
| `pt_BR` | Brazilian Portuguese | `LANG=pt_BR.UTF-8` |
| `en_US` | English | `LANG=en_US.UTF-8` |
| `C` | English (fallback) | `LANG=C.UTF-8` |

## Important Notes

- **Automatic backup** created every run
- **Safe append** to `/etc/hosts` only
- **Persists** through `rpm-ostree upgrade` (/etc is writable)
- **Intentional ping failure** confirms blocking
- **Flatpaks** need restart after execution

## Blocklists Used

| Source | Domains | URL |
|--------|---------|-----|
| StevenBlack | ~10k | [porn variant](https://github.com/StevenBlack/hosts) |
| PaulBrandie | ~500 | [Pi-Hole Porn List](https://github.com/paulbrandie/Pi-Hole-Porn-Blocking) |

## Contributions

1. Add new languages to the `case "$LANG_ID"` statement
2. Suggest additional hosts lists
3. Test on other Atomic distros (openSUSE MicroOS, VanillaOS)

## License

[MIT](LICENSE) - Free for personal/business use.
