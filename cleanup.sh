#!/bin/bash

# ============================================================
#  🧹 Full Office Machine Wipe Script (Linux)
#  Clears ALL personal data: browsers, IDEs, cloud CLIs,
#  credentials, tokens, shell history, and more.
#  Usage: bash cleanup.sh
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[✔]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
info() { echo -e "${CYAN}[~]${NC} $1"; }

echo -e "\n${BOLD}${CYAN}============================================${NC}"
echo -e "${BOLD}${CYAN}   🧹 Full Office Machine Wipe — Linux${NC}"
echo -e "${BOLD}${CYAN}============================================${NC}\n"
echo -e "${RED}  This will permanently delete all personal data.${NC}"
echo -e "${RED}  Make sure you have saved anything you need!${NC}\n"
read -rp "$(echo -e ${YELLOW}"  Continue? [y/N]: "${NC})" confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
echo ""

# ─────────────────────────────────────────────────────
# HELPER: safely remove a list of paths
# ─────────────────────────────────────────────────────
wipe() {
    local label="$1"; shift
    local found=0
    for p in "$@"; do
        if [ -e "$p" ]; then
            rm -rf "$p" && found=1
        fi
    done
    [ $found -eq 1 ] && ok "$label" || warn "$label: nothing found, skipped"
}

# ══════════════════════════════════════════════════════
# 1. BROWSERS
# ══════════════════════════════════════════════════════
info "──── Browsers ────"

# Shared function to wipe a Chromium-based profile
wipe_chromium_profile() {
    local dir="$1" name="$2"
    [ -d "$dir" ] || { warn "$name: not installed"; return; }
    rm -rf \
        "$dir/Default/Cookies" \
        "$dir/Default/Login Data" \
        "$dir/Default/Login Data For Account" \
        "$dir/Default/Web Data" \
        "$dir/Default/History" \
        "$dir/Default/Sessions" \
        "$dir/Default/Extension Cookies" \
        "$dir/Default/Cache" \
        "$dir/Default/Code Cache" \
        "$dir/Default/GPUCache" \
        "$dir/Default/Local Storage" \
        "$dir/Default/IndexedDB" \
        "$dir/Default/Service Worker" \
        "$dir/Default/Storage" \
        "$dir/Default/Extension State" \
        "$dir/Default/Sync Data" \
        "$dir/Default/Sync Extension Settings" \
        "$dir/GrShaderCache" \
        "$dir/ShaderCache" 2>/dev/null
    ok "$name: cookies, passwords, history, cache, sessions, sync data"
}

wipe_chromium_profile "$HOME/.config/google-chrome"              "Chrome"
wipe_chromium_profile "$HOME/.config/chromium"                   "Chromium"
wipe_chromium_profile "$HOME/.config/BraveSoftware/Brave-Browser" "Brave"
wipe_chromium_profile "$HOME/.config/microsoft-edge"             "Edge"
wipe_chromium_profile "$HOME/.config/vivaldi"                    "Vivaldi"
wipe_chromium_profile "$HOME/.config/opera"                      "Opera"

# Firefox
if [ -d "$HOME/.mozilla/firefox" ]; then
    for profile in "$HOME/.mozilla/firefox"/*.default* \
                   "$HOME/.mozilla/firefox"/*.default-release; do
        [ -d "$profile" ] || continue
        rm -rf \
            "$profile/cookies.sqlite" \
            "$profile/key4.db" \
            "$profile/logins.json" \
            "$profile/places.sqlite" \
            "$profile/formhistory.sqlite" \
            "$profile/sessionstore.jsonlz4" \
            "$profile/sessionstore-backups" \
            "$profile/cache2" \
            "$profile/startupCache" \
            "$profile/storage" \
            "$profile/indexedDB" \
            "$profile/storage.sqlite" \
            "$profile/webappsstore.sqlite" \
            "$profile/signedInUser.json" 2>/dev/null
    done
    ok "Firefox: cookies, passwords, history, cache, sessions, Firefox Account sign-in"
else
    warn "Firefox: not installed"
fi
echo ""

# ══════════════════════════════════════════════════════
# 2. VS CODE & FORKS
# ══════════════════════════════════════════════════════
info "──── VS Code & Forks ────"

wipe_vscode() {
    local config_dir="$1" cache_dir="$2" name="$3"
    # Auth tokens & credentials stored by extensions
    rm -rf \
        "$config_dir/User/globalStorage/github.vscode-pull-requests-github" \
        "$config_dir/User/globalStorage/github.remotehub" \
        "$config_dir/User/globalStorage/github.codespaces" \
        "$config_dir/User/globalStorage/github.vscode-github-actions" \
        "$config_dir/User/globalStorage/gitlab.gitlab-workflow" \
        "$config_dir/User/globalStorage/eamodio.gitlens" \
        "$config_dir/User/globalStorage/ms-vscode.remote-repositories" \
        "$config_dir/User/globalStorage/vscode.github-authentication" \
        "$config_dir/User/globalStorage/vscode.microsoft-authentication" \
        "$config_dir/User/globalStorage/ms-vscode-remote.remote-ssh" \
        "$config_dir/User/globalStorage/ms-python.python" \
        "$config_dir/User/globalStorage/ms-toolsai.jupyter" \
        "$config_dir/User/globalStorage/redhat.vscode-redhat-account" \
        "$config_dir/User/syncedSettings.json" \
        "$config_dir/User/settings.json" \
        "$cache_dir" 2>/dev/null
    # Clear secrets DB used by VS Code for token storage
    rm -f "$config_dir/User/globalStorage/state.vscdb" \
          "$config_dir/User/globalStorage/state.vscdb.backup" 2>/dev/null
    ok "$name: auth tokens, extension credentials, sync settings, cache"
}

[ -d "$HOME/.config/Code" ] && \
    wipe_vscode "$HOME/.config/Code" "$HOME/.cache/vscode" "VS Code" || \
    warn "VS Code: not installed"

[ -d "$HOME/.config/Code - Insiders" ] && \
    wipe_vscode "$HOME/.config/Code - Insiders" "$HOME/.cache/vscode-insiders" "VS Code Insiders" || \
    warn "VS Code Insiders: not installed"

[ -d "$HOME/.config/VSCodium" ] && \
    wipe_vscode "$HOME/.config/VSCodium" "$HOME/.cache/VSCodium" "VSCodium" || \
    warn "VSCodium: not installed"

# Cursor (AI IDE based on VS Code)
[ -d "$HOME/.config/Cursor" ] && \
    wipe_vscode "$HOME/.config/Cursor" "$HOME/.cache/Cursor" "Cursor IDE" || \
    warn "Cursor IDE: not installed"
echo ""

# ══════════════════════════════════════════════════════
# 3. JETBRAINS IDEs (IntelliJ, PyCharm, WebStorm, etc.)
# ══════════════════════════════════════════════════════
info "──── JetBrains IDEs ────"
JBFOUND=0
for jb_config in "$HOME/.config/JetBrains"/*/; do
    [ -d "$jb_config" ] || continue
    rm -rf \
        "$jb_config/options/account.xml" \
        "$jb_config/options/ide.features.trainer.xml" \
        "$jb_config/options/other.xml" \
        "$jb_config/options/github.xml" \
        "$jb_config/options/gitlab.xml" \
        "$jb_config/options/savedSettings.xml" \
        "$jb_config/port" \
        "$jb_config/ssl" 2>/dev/null
    JBFOUND=1
done
# Also wipe older-style ~/.IntelliJIdeaXXXX, ~/.PyCharmXXXX, etc.
for old_jb in "$HOME"/.{IntelliJIdea,PyCharm,WebStorm,GoLand,CLion,DataGrip,PhpStorm,RubyMine,Rider}*/; do
    [ -d "$old_jb" ] || continue
    rm -rf "$old_jb/config/options/"*account* \
           "$old_jb/config/options/"*github* \
           "$old_jb/config/options/"*gitlab* \
           "$old_jb/config/port" 2>/dev/null
    JBFOUND=1
done
[ $JBFOUND -eq 1 ] && ok "JetBrains: account/GitHub/GitLab tokens cleared" || warn "JetBrains IDEs: not installed"

# JetBrains Toolbox
wipe "JetBrains Toolbox session" "$HOME/.local/share/JetBrains/Toolbox"
echo ""

# ══════════════════════════════════════════════════════
# 4. GIT
# ══════════════════════════════════════════════════════
info "──── Git ────"
rm -f "$HOME/.git-credentials" && ok "Git credentials file: removed" || warn "Git credentials file: not found"
if command -v git &>/dev/null; then
    git config --global --unset user.name       2>/dev/null || true
    git config --global --unset user.email      2>/dev/null || true
    git config --global --unset user.signingkey 2>/dev/null || true
    git config --global --unset credential.helper 2>/dev/null || true
    ok "Git global identity: name, email, signing key, credential helper cleared"
fi
# GitHub CLI (gh)
wipe "GitHub CLI (gh) auth" "$HOME/.config/gh"
# GitLab CLI (glab)
wipe "GitLab CLI (glab) auth" "$HOME/.config/glab-cli"
echo ""

# ══════════════════════════════════════════════════════
# 5. SSH
# ══════════════════════════════════════════════════════
info "──── SSH ────"
if [ -d "$HOME/.ssh" ]; then
    rm -f "$HOME/.ssh"/id_rsa* \
          "$HOME/.ssh"/id_ed25519* \
          "$HOME/.ssh"/id_ecdsa* \
          "$HOME/.ssh"/id_dsa* \
          "$HOME/.ssh"/config 2>/dev/null
    > "$HOME/.ssh/known_hosts" 2>/dev/null || true
    ssh-add -D 2>/dev/null || true
    ok "SSH: private/public keys, config, known_hosts cleared; agent flushed"
else
    warn "SSH: ~/.ssh not found"
fi
echo ""

# ══════════════════════════════════════════════════════
# 6. CLOUD CLIs
# ══════════════════════════════════════════════════════
info "──── Cloud CLIs ────"

# AWS CLI
wipe "AWS CLI credentials" "$HOME/.aws/credentials" "$HOME/.aws/config"

# Google Cloud SDK
wipe "gcloud credentials" \
    "$HOME/.config/gcloud/credentials.db" \
    "$HOME/.config/gcloud/access_tokens.db" \
    "$HOME/.config/gcloud/application_default_credentials.json" \
    "$HOME/.config/gcloud/legacy_credentials"

# Azure CLI
wipe "Azure CLI credentials" \
    "$HOME/.azure/msal_token_cache.json" \
    "$HOME/.azure/accessTokens.json" \
    "$HOME/.azure/azureProfile.json"

# Heroku CLI
wipe "Heroku CLI auth" "$HOME/.netrc" "$HOME/.config/heroku/netrc"
rm -f "$HOME/.config/heroku/netrc" 2>/dev/null || true

# DigitalOcean CLI (doctl)
wipe "doctl auth" "$HOME/.config/doctl/config.yaml"

# Vercel CLI
wipe "Vercel CLI auth" "$HOME/.local/share/com.vercel.cli" "$HOME/.vercel"

# Netlify CLI
wipe "Netlify CLI auth" "$HOME/.netlify/config.json"

# Fly.io CLI
wipe "Fly.io CLI auth" "$HOME/.fly/config.yml"
echo ""

# ══════════════════════════════════════════════════════
# 7. DOCKER
# ══════════════════════════════════════════════════════
info "──── Docker ────"
wipe "Docker credentials" "$HOME/.docker/config.json"
if command -v docker &>/dev/null; then
    docker logout 2>/dev/null && ok "Docker: logged out from registry" || true
fi
echo ""

# ══════════════════════════════════════════════════════
# 8. NODE / NPM / YARN / PNPM
# ══════════════════════════════════════════════════════
info "──── Node Package Managers ────"
# npm auth token
NPM_RC="$HOME/.npmrc"
if [ -f "$NPM_RC" ]; then
    # Remove lines with auth tokens but keep other config
    grep -v "authToken\|_auth\|password\|email" "$NPM_RC" > /tmp/_npmrc_clean 2>/dev/null && \
        mv /tmp/_npmrc_clean "$NPM_RC"
    ok "npm: auth tokens removed from .npmrc"
fi
# yarn
YARN_RC="$HOME/.yarnrc.yml"
[ -f "$YARN_RC" ] && grep -v "npmAuthToken\|npmAuthIdent" "$YARN_RC" > /tmp/_yarnrc_clean 2>/dev/null && \
    mv /tmp/_yarnrc_clean "$YARN_RC" && ok "yarn: auth tokens removed from .yarnrc.yml"

# pnpm
wipe "pnpm auth" "$HOME/.pnpm-store"
echo ""

# ══════════════════════════════════════════════════════
# 9. PYTHON PACKAGE MANAGERS
# ══════════════════════════════════════════════════════
info "──── Python Tools ────"
wipe "pip credentials" "$HOME/.config/pip/pip.conf"
wipe "poetry auth" "$HOME/.config/pypoetry/auth.toml"
wipe "twine credentials" "$HOME/.pypirc"
echo ""

# ══════════════════════════════════════════════════════
# 10. COMMUNICATION APPS
# ══════════════════════════════════════════════════════
info "──── Communication Apps ────"
wipe "Slack"   "$HOME/.config/Slack"   "$HOME/.local/share/Slack"
wipe "Discord" "$HOME/.config/discord" "$HOME/.local/share/discord"
wipe "Zoom"    "$HOME/.config/zoom"    "$HOME/.local/share/Zoom"
wipe "Teams"   "$HOME/.config/Microsoft/Microsoft Teams" \
               "$HOME/.local/share/Microsoft/Microsoft Teams"
wipe "Thunderbird" "$HOME/.thunderbird" "$HOME/.local/share/thunderbird"
wipe "Signal"  "$HOME/.config/Signal"
echo ""

# ══════════════════════════════════════════════════════
# 11. PASSWORD MANAGERS (desktop clients)
# ══════════════════════════════════════════════════════
info "──── Password Managers ────"
wipe "Bitwarden desktop" "$HOME/.config/Bitwarden" "$HOME/.local/share/Bitwarden"
wipe "1Password"         "$HOME/.config/1Password" "$HOME/.local/share/1Password"
wipe "KeePassXC"         "$HOME/.config/keepassxc"
echo ""

# ══════════════════════════════════════════════════════
# 12. GNOME / KDE CREDENTIAL STORES
# ══════════════════════════════════════════════════════
info "──── System Credential Stores ────"
# GNOME Keyring
wipe "GNOME Keyring"        "$HOME/.local/share/keyrings"
# GNOME Online Accounts
wipe "GNOME Online Accounts" "$HOME/.local/share/gnome-online-accounts" \
                              "$HOME/.config/goa-1.0"
# KWallet
wipe "KDE KWallet"          "$HOME/.local/share/kwalletd" \
                             "$HOME/.local/share/kwallet"
echo ""

# ══════════════════════════════════════════════════════
# 13. SHELL HISTORY
# ══════════════════════════════════════════════════════
info "──── Shell History ────"
> "$HOME/.bash_history"   && ok "Bash history: cleared"
> "$HOME/.zsh_history"    && ok "Zsh history: cleared"  || true
> "$HOME/.history"        2>/dev/null || true
> "$HOME/.local/share/fish/fish_history" 2>/dev/null && ok "Fish history: cleared" || true
history -c 2>/dev/null || true
echo ""

# ══════════════════════════════════════════════════════
# 14. MISC PERSONAL TRACES
# ══════════════════════════════════════════════════════
info "──── Misc Traces ────"
# Recently used files
RECENT="$HOME/.local/share/recently-used.xbel"
if [ -f "$RECENT" ]; then
    cat > "$RECENT" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<xbel version="1.0"
      xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks"
      xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info">
</xbel>
EOF
    ok "Recently used files list: cleared"
fi
# Thumbnail cache
wipe "Thumbnail cache" "$HOME/.cache/thumbnails"
# Trash
rm -rf "$HOME/.local/share/Trash/files/"* "$HOME/.local/share/Trash/info/"* 2>/dev/null
ok "Trash: emptied"
# Netrc (additional credential source)
[ -f "$HOME/.netrc" ] && grep -v "password\|login" "$HOME/.netrc" > /tmp/_netrc_clean && \
    mv /tmp/_netrc_clean "$HOME/.netrc" && ok ".netrc: credentials removed"
echo ""

# ══════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════
echo -e "${GREEN}${BOLD}============================================${NC}"
echo -e "${GREEN}${BOLD}  ✅ Full wipe complete!${NC}"
echo -e "${GREEN}${BOLD}============================================${NC}"
echo ""
echo -e "  ${YELLOW}Final step:${NC} Log out of your desktop session."
echo -e "  This flushes any remaining in-memory tokens,"
echo -e "  active web sessions, and keyring unlocks.\n"
