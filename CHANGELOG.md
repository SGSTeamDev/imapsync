# Changelog

All notable changes to this project will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.2.0] - 2026-04-22

### Fixed
- SMTP protocol now correctly uses `smtps://` for port 465 and `smtp://` + `--ssl-reqd` for port 587
- Added proper email headers: `MIME-Version` and `Content-Type` to prevent silent rejection
- Replaced `--silent` with `--show-error --fail` for visible SMTP error output
- Fixed line endings to use `\r\n` for SMTP compliance
- Added `--connect-timeout 10 --max-time 30` to prevent notify.sh from hanging
- Updated `.env.example` to document port/protocol relationship

## [1.1.0] - 2026-04-22

### Fixed
- Variables inside tmux command now expand correctly using double quotes and `bash -lc`
- Removed unnecessary `source .env` re-run inside tmux session
- Removed `read` that kept tmux session hanging after job completion
- `stop` command no longer errors when session is not running
- Added `set -euo pipefail` to all account scripts for stricter failure handling

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
