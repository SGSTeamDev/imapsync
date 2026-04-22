# Adding a new account

## 1. Add credentials to `.env`

Open `.env` and add a new block for your account:

```dotenv
# Account credentials: alice
ALICE_SRC=alice@olddomain.com
ALICE_SRC_PASS=her-source-password
ALICE_DST=alice@newdomain.com
ALICE_DST_PASS=her-dest-password
```

If the new account uses a different IMAP server, add host variables too:

```dotenv
IMAP_SRC_HOST2=imap.otherprovider.com
IMAP_DST_HOST2=imap.newprovider.com
```

## 2. Create the account script

Copy an existing account script and update the variables:

```bash
cp accounts/user1.sh accounts/alice.sh
```

Edit `accounts/alice.sh` — change these lines near the top:

```bash
SESSION="imap_alice"
ACCOUNT="$ALICE_SRC"
```

And update the imapsync credentials block inside the tmux command:

```bash
--host1 $IMAP_SRC_HOST  --user1 $ALICE_SRC  --password1 '$ALICE_SRC_PASS' \
--host2 $IMAP_DST_HOST  --user2 $ALICE_DST  --password2 '$ALICE_DST_PASS' \
```

## 3. Register it in `scripts/run-all.sh`

Add the new script to the `ACCOUNT_SCRIPTS` array:

```bash
ACCOUNT_SCRIPTS=(
  "$ROOT/accounts/user1.sh"
  "$ROOT/accounts/user2.sh"
  "$ROOT/accounts/alice.sh"   # ← add this
)
```

## 4. Test it

```bash
bash accounts/alice.sh start
bash accounts/alice.sh status
bash accounts/alice.sh log
```
