# Contributing

Contributions are welcome — bug fixes, improvements, and new features.

## Getting started

1. Fork the repo and clone it
2. Create a branch: `git checkout -b my-fix`
3. Make your changes
4. Open a pull request with a clear description

## Guidelines

- Keep scripts POSIX-compatible where possible; bash-specific features are fine but document them
- Never commit credentials or `.env` files
- Update `CHANGELOG.md` under `[Unreleased]` with a summary of your change
- Test your changes on a real or test IMAP server before submitting

## Adding a new account script

See [docs/adding-accounts.md](docs/adding-accounts.md) for the step-by-step guide.

## Reporting issues

Open a GitHub issue with:
- What you ran
- What you expected
- What actually happened
- Relevant log output (redact any passwords)
