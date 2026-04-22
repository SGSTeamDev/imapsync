# Changelog

All notable changes to this project will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2026-04-22

### Added
- Multi-account imapsync migration with one script per account
- tmux session management — jobs survive SSH disconnects
- Email notifications on job start, completion, and failure via SMTP/curl
- `start`, `status`, `log`, `attach`, `stop` commands per account
- `scripts/run-all.sh` to launch or check all accounts at once
- `.env`-based credential management — safe to push to GitHub
- `docs/adding-accounts.md` — guide for adding new accounts
- `CONTRIBUTING.md`, `LICENSE`, `.env.example` for open source release
- Professional project structure with `accounts/`, `scripts/`, `docs/`
