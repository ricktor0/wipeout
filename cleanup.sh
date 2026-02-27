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

# ------------------------------------------------------------
# HELPER: safely remove a list of paths
# ------------------------------------------------------------
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

# ============================================================
# 1. BROWSERS
# ============================================================
info "──── Browsers ────"

# ---- Chromium-based browsers (ALL profiles) ----
wipe_chromium_profile() {
    local dir="$1" name="$2"
    [ -d "$dir" ] || { warn "$name: not installed"; return; }

    for profile in "$dir"/*/; do
        [ -d "$profile" ] || continue
        rm -rf \
            "$profile/Cookies" \
            "$profile/Login Data" \
            "$profile/Login Data For Account" \
            "$profile/Web Data" \
            "$profile/History" \
            "$profile/Sessions" \
            "$profile/Extension Cookies" \
            "$profile/Cache" \
            "$profile/Code Cache" \
            "$profile/GPUCache" \
            "$profile/Local Storage" \
            "$profile/IndexedDB" \
            "$profile/Service Worker" \
            "$profile/Storage" \
            "$profile/Extension State" \
            "$profile/Sync Data" \
            "$profile/Sync Extension Settings" 2>/dev/null
    done

    rm -rf "$dir/GrShaderCache" "$dir/ShaderCache" 2>/dev/null
    ok "$name: all profiles wiped (cookies, sessions, passwords, cache)"
}

wipe_chromium_profile "$HOME/.config/google-chrome"              "Chrome"
wipe_chromium_profile "$HOME/.config/chromium"                   "Chromium"
wipe_chromium_profile "$HOME/.config/BraveSoftware/Brave-Browser" "Brave"
wipe_chromium_profile "$HOME/.config/microsoft-edge"             "Edge"
wipe_chromium_profile "$HOME/.config/vivaldi"                    "Vivaldi"
wipe_chromium_profile "$HOME/.config/opera"                      "Opera"

# ---- Firefox ----
if [ -d "$HOME/.mozilla/firefox" ]; then
    for profile in "$HOME/.mozilla/firefox"/*/; do
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
    ok "Firefox: all profiles wiped"
else
    warn "Firefox: not installed"
fi

# ---- Zen Browser (Firefox-based fork) ----
if [ -d "$HOME/.config/zen" ]; then
    for profile in "$HOME/.config/zen"/*/; do
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

    wipe "Zen cache" "$HOME/.cache/zen"
    ok "Zen Browser: all profiles wiped"
else
    warn "Zen Browser: not installed"
fi

echo ""

# ============================================================
# 2. VS CODE & FORKS
# ============================================================
info "──── VS Code & Forks ────"

wipe_vscode() {
    local config_dir="$1" cache_dir="$2" name="$3"
    rm -rf \
        "$config_dir/User/globalStorage" \
        "$config_dir/User/syncedSettings.json" \
        "$config_dir/User/settings.json" \
        "$cache_dir" 2>/dev/null
    ok "$name: auth tokens, secrets DB, cache cleared"
}

[ -d "$HOME/.config/Code" ] && \
    wipe_vscode "$HOME/.config/Code" "$HOME/.cache/vscode" "VS Code" || \
    warn "VS Code: not installed"

[ -d "$HOME/.config/Cursor" ] && \
    wipe_vscode "$HOME/.config/Cursor" "$HOME/.cache/Cursor" "Cursor IDE" || \
    warn "Cursor IDE: not installed"

echo ""

# ============================================================
# 3. SSH
# ============================================================
info "──── SSH ────"
if [ -d "$HOME/.ssh" ]; then
    rm -f "$HOME/.ssh"/id_* "$HOME/.ssh/config"
    > "$HOME/.ssh/known_hosts"
    ssh-add -D 2>/dev/null || true
    ok "SSH keys & agent cleared"
else
    warn "SSH: not found"
fi
echo ""

# ============================================================
# 4. GIT
# ============================================================
info "──── Git ────"
rm -f "$HOME/.git-credentials"
git config --global --unset-all user.name 2>/dev/null
git config --global --unset-all user.email 2>/dev/null
git config --global --unset-all credential.helper 2>/dev/null
wipe "GitHub CLI" "$HOME/.config/gh"
wipe "GitLab CLI" "$HOME/.config/glab-cli"
ok "Git identity & credentials cleared"
echo ""

# ============================================================
# 5. CLOUD CLIs
# ============================================================
info "──── Cloud CLIs ────"
wipe "AWS" "$HOME/.aws"
wipe "gcloud" "$HOME/.config/gcloud"
wipe "Azure" "$HOME/.azure"
wipe "Vercel" "$HOME/.vercel"
wipe "Netlify" "$HOME/.netlify"
wipe "Fly.io" "$HOME/.fly"
echo ""

# ============================================================
# 6. DOCKER
# ============================================================
info "──── Docker ────"
wipe "Docker credentials" "$HOME/.docker"
docker logout 2>/dev/null || true
echo ""

# ============================================================
# 7. SHELL HISTORY
# ============================================================
info "──── Shell History ────"
> "$HOME/.bash_history"
> "$HOME/.zsh_history" 2>/dev/null
> "$HOME/.local/share/fish/fish_history" 2>/dev/null
history -c 2>/dev/null || true
ok "Shell history cleared"
echo ""

# ============================================================
# DONE
# ============================================================
echo -e "${GREEN}${BOLD}============================================${NC}"
echo -e "${GREEN}${BOLD}  ✅ Full wipe complete!${NC}"
echo -e "${GREEN}${BOLD}============================================${NC}"
echo ""
echo -e "  ${YELLOW}Final step:${NC} Log out of your desktop session."
echo -e "  This flushes remaining in-memory tokens.\n"
