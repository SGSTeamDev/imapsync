# imapsync-migration

Bash scripts for migrating multiple IMAP email accounts using [imapsync](https://imapsync.lamiral.info/), designed to run on an Ubuntu VPS with tmux session management and email notifications.

## Features

- One script per account — run and monitor each migration independently
- tmux sessions — jobs survive SSH disconnects
- Email notifications on start, completion, and failure
- Credentials stored in `.env` — safe to push the repo to GitHub
- `start`, `status`, `log`, `attach`, `stop` commands per account

## Requirements

- Ubuntu VPS (or any Linux with bash)
- `imapsync`, `tmux`, `curl`

**Install tmux and curl:**
```bash
apt update && apt install -y tmux curl
```

**Install imapsync** (not in default apt repos — install via official script):
```bash
# 1. Install Perl dependencies
apt install -y \
  libauthen-ntlm-perl libcgi-pm-perl libcrypt-openssl-rsa-perl \
  libdata-uniqid-perl libencode-imaputf7-perl libfile-copy-recursive-perl \
  libfile-tail-perl libio-socket-inet6-perl libio-socket-ssl-perl \
  libio-tee-perl libhtml-parser-perl libjson-webtoken-perl \
  libmail-imapclient-perl libparse-recdescent-perl libmodule-scandeps-perl \
  libreadonly-perl libregexp-common-perl libsys-meminfo-perl \
  libterm-readkey-perl libtest-mockobject-perl libtest-pod-perl \
  libunicode-string-perl liburi-perl libwww-perl make cpanminus

# 2. Download and install imapsync
wget -N https://raw.githubusercontent.com/imapsync/imapsync/master/imapsync
chmod +x imapsync
mv imapsync /usr/local/bin/imapsync

# 3. Verify
imapsync --version
```

## Setup

**1. Clone the repo**

```bash
git clone https://github.com/your-username/imapsync-migration.git
cd imapsync-migration
```

**2. Configure credentials**

```bash
cp .env.example .env
nano .env
```

Fill in your SMTP settings (for email notifications) and IMAP credentials for each account.

**3. Make scripts executable**

```bash
chmod +x accounts/*.sh scripts/*.sh
```

## Usage

### Single account

```bash
bash accounts/user1.sh            # start migration
bash accounts/user1.sh status     # check if running + last 10 log lines
bash accounts/user1.sh log        # live log tail (Ctrl+C to exit)
bash accounts/user1.sh attach     # attach to tmux session (Ctrl+B D to detach)
bash accounts/user1.sh stop       # kill the session
```

### All accounts at once

```bash
bash scripts/run-all.sh           # start all
bash scripts/run-all.sh status    # check all
```

### Test email notifications

```bash
bash scripts/notify.sh "test" "hello from VPS"
```

## Email notifications

Each account emails you when it **starts** and when it **finishes** (or fails with an exit code).

Configure SMTP credentials in `.env`. Gmail users must use an [App Password](https://myaccount.google.com/apppasswords) — your regular password won't work over SMTP.

## Logs

Logs are written to `~/imapsync-logs/` on the VPS, one file per account session.

## Adding accounts

See [docs/adding-accounts.md](docs/adding-accounts.md) for a step-by-step guide.

## Project structure

```
imapsync-migration/
├── accounts/          # one script per email account
│   ├── user1.sh
│   ├── user2.sh
│   └── user3.sh
├── docs/
│   └── adding-accounts.md
├── scripts/
│   ├── notify.sh      # SMTP email sender
│   └── run-all.sh     # launch/check all accounts
├── .env.example       # credential template
├── CHANGELOG.md
├── CONTRIBUTING.md
└── LICENSE
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
