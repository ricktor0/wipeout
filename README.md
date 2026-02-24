# wipeout

A shell script to completely clear personal data from a shared or office Linux machine before you leave.

## What it clears

- **Browsers** — Chrome, Chromium, Brave, Firefox, Edge, Opera, Vivaldi (cookies, saved passwords, history, sessions, cache)
- **VS Code and forks** — auth tokens for GitHub, GitLab, and all extensions (VSCode, VSCodium, Cursor)
- **JetBrains IDEs** — IntelliJ, PyCharm, WebStorm, GoLand, etc. (account tokens, Toolbox)
- **Git** — saved credentials, global username, email, and signing key
- **Git CLIs** — GitHub CLI (`gh`) and GitLab CLI (`glab`) auth
- **SSH** — private/public keys, config file, known_hosts, SSH agent keys
- **Cloud CLIs** — AWS, gcloud, Azure, Heroku, DigitalOcean, Vercel, Netlify, Fly.io
- **Docker** — registry login credentials
- **Node / npm / yarn** — auth tokens from `.npmrc` and `.yarnrc.yml`
- **Python tools** — pip, poetry, twine/PyPI credentials
- **Communication apps** — Slack, Discord, Zoom, Teams, Thunderbird, Signal
- **System credential stores** — GNOME Keyring, GNOME Online Accounts, KDE KWallet
- **Shell history** — Bash, Zsh, Fish
- **Misc** — recently used files list, thumbnail cache, Trash

## Usage

```bash
bash cleanup.sh
```

The script will ask for confirmation before doing anything.

After it finishes, log out of your desktop session to flush any remaining in-memory tokens and active sessions.

## Notes

- The script skips anything it cannot find, so it is safe to run even if you do not have all of the listed apps installed.
- It does not touch system files or other users' data.
- Tested on Ubuntu/Debian-based distros. Should work on most Linux desktops.

## License

MIT
