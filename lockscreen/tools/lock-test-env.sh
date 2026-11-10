#!/bin/sh
# PAM test double for the shell's lock screen, for YOUR OWN headless test session only (scripts/smoke.sh).
# Writes DIR/login, a PAM service that accepts exactly the password "hyprk-test-pass" (pam_exec runs DIR/check.sh)
# and rejects anything else, and prints the two variables that make the lock read it instead of /etc/pam.d/login:
#   eval "$(lockscreen/tools/lock-test-env.sh /some/scratch/dir)"
#   HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh out.png
# The shell logs "hyprk lock: TEST MODE" while it is on. Never export these in a real session.
set -eu
DIR=${1:?usage: lock-test-env.sh DIR}
mkdir -p "$DIR"
DIR=$(cd "$DIR" && pwd)
cat > "$DIR/check.sh" <<'EOF'
#!/bin/sh
IFS= read -r pw || true
pw=$(printf '%s' "$pw" | tr -d '\000')
[ "$pw" = "hyprk-test-pass" ]
EOF
chmod +x "$DIR/check.sh"
printf 'auth required pam_exec.so expose_authtok quiet %s\n' "$DIR/check.sh" > "$DIR/login"
echo "export HYPRK_LOCK_TEST=1 HYPRK_LOCK_PAMDIR=$DIR"
