
#!/usr/bin/env bash
# Setup Slurm accounting DB in MariaDB (idempotent; run as normal user, use sudo for MariaDB commands)
# - Generates 16-char random password (hex), saves to password file (chmod 600)
# - Creates database (default: slurm_acct_db) if not exists
# - Creates DB user (default: slurm) for localhost and $(hostname -s) if not exists; updates password if exists
# - Grants privileges to both host variants
# - Shows grants and InnoDB capability flag
# - Updates slurmdbd.conf:
#     * Normalize StoragePass: keep one active StoragePass=<pass>, comment duplicates (#StoragePass=<old>)
#     * Normalize StorageLoc: keep one active StorageLoc=<DB_NAME>, comment duplicates (#StorageLoc=<old>), append if missing
#
# Usage:
#   ./setup_slurm_mariadb.sh [--rotate] [--pwd-file /path/to/file] [--db-name NAME] [--user NAME] [--conf-file PATH] [--dry-run] [--debug] [-h|--help]
#
# Options:
#   --rotate          Force rotate the managed password (regenerate file and update MariaDB users)
#   --pwd-file PATH   Path to the password file (default: ./slurm_db_password.txt)
#   --db-name NAME    Database name to create/manage (default: slurm_acct_db)
#   --user NAME       DB username to create/grant (default: slurm)
#   --conf-file PATH  Path to slurmdbd.conf to update (default: ./slurmdbd.conf)
#   --dry-run         Print all intended actions and SQL without changing anything
#   --debug           Enable shell tracing (set -x) for troubleshooting
#   -h|--help         Show this help message
#
# Notes:
#   - All MariaDB invocations use: sudo mariadb --protocol=socket (heredoc-fed SQL)
#   - Idempotent: safe to re-run without errors or duplicate grants
#   - No eval; avoids heredoc-in-command-substitution to prevent syntax errors.

set -euo pipefail

# --- Parse args ---
ROTATE="false"
PWD_FILE="./slurm_db_password.txt"
DB_NAME="slurm_acct_db"
DB_USER="slurm"
CONF_FILE="./slurmdbd.conf"
DRY_RUN="false"
DEBUG="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --rotate) ROTATE="true"; shift ;;
    --pwd-file)
      if [[ $# -lt 2 ]]; then
        echo "Error: --pwd-file requires a path argument." >&2
        exit 2
      fi
      PWD_FILE="$2"; shift 2 ;;
    --db-name)
      if [[ $# -lt 2 ]]; then
        echo "Error: --db-name requires a name argument." >&2
        exit 2
      fi
      DB_NAME="$2"; shift 2 ;;
    --user)
      if [[ $# -lt 2 ]]; then
        echo "Error: --user requires a name argument." >&2
        exit 2
      fi
      DB_USER="$2"; shift 2 ;;
    --conf-file)
      if [[ $# -lt 2 ]]; then
        echo "Error: --conf-file requires a path argument." >&2
        exit 2
      fi
      CONF_FILE="$2"; shift 2 ;;
    --dry-run) DRY_RUN="true"; shift ;;
    --debug) DEBUG="true"; shift ;;
    -h|--help)
      grep -E '^# ' "$0" | sed 's/^# //'
      exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2 ;;
  esac
done

# --- Enable debug tracing if requested ---
if [[ "$DEBUG" == "true" ]]; then
  set -x
fi

# --- Basic validation ---
if [[ -z "$DB_NAME" || -z "$DB_USER" ]]; then
  echo "Error: --db-name and --user must be non-empty." >&2
  exit 2
fi

HOST_SHORT="$(hostname -s)"

# --- Prepare password file path ---
PWD_DIR="$(dirname -- "$PWD_FILE")"
if [[ ! -d "$PWD_DIR" ]]; then
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY-RUN: would create directory: $PWD_DIR"
  else
    mkdir -p "$PWD_DIR"
  fi
fi

# --- Robust password generator (Option B) ---
# Prefer openssl (no SIGPIPE), fallback to od (safe under pipefail).
gen_pass() {
  if command -v openssl >/dev/null 2>&1; then
    # 32 hex chars; take first 16 to meet length requirement. Hex is safe for SQL and shell.
    openssl rand -hex 16 | head -c16
  else
    # Read 16 bytes, format as hex, strip spaces/newlines, trim to 16 chars.
    od -An -N16 -tx1 /dev/urandom | tr -d ' \n' | head -c16
  fi
}

# --- Generate or load password ---
if [[ "$ROTATE" == "true" ]]; then
  SLURM_DB_PASS="$(gen_pass)"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY-RUN: would rotate password and write to: $PWD_FILE (chmod 600)"
  else
    printf "%s\n" "$SLURM_DB_PASS" > "$PWD_FILE"
    chmod 600 "$PWD_FILE"
    echo "Rotated password and wrote to: $PWD_FILE"
  fi
else
  if [[ -s "$PWD_FILE" ]]; then
    SLURM_DB_PASS="$(cat "$PWD_FILE")"
    echo "Using existing password from: $PWD_FILE"
  else
    SLURM_DB_PASS="$(gen_pass)"
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "DRY-RUN: would generate password and write to: $PWD_FILE (chmod 600)"
    else
      printf "%s\n" "$SLURM_DB_PASS" > "$PWD_FILE"
      chmod 600 "$PWD_FILE"
      echo "Generated password and wrote to: $PWD_FILE"
    fi
  fi
fi

# --- Info banner ---
echo "Target DB name: ${DB_NAME}"
echo "Target DB user: ${DB_USER}"
echo "Granting to: '${DB_USER}'@'localhost' and '${DB_USER}'@'${HOST_SHORT}'"
echo "Password file: ${PWD_FILE}"
echo "slurmdbd.conf: ${CONF_FILE}"
[[ "$ROTATE" == "true" ]] && echo "Password rotation: ENABLED" || echo "Password rotation: DISABLED"
[[ "$DRY_RUN" == "true" ]] && echo "Dry-run mode: ENABLED (no changes will be made)" || echo "Dry-run mode: DISABLED"
[[ "$DEBUG" == "true" ]] && echo "Debug tracing: ENABLED (set -x)" || echo "Debug tracing: DISABLED"

# --- Update & normalize StoragePass and StorageLoc in slurmdbd.conf ---
update_conf() {
  local conf="$1"
  local pass="$2"
  local dbname="$3"

  local conf_dir
  conf_dir="$(dirname -- "$conf")"

  # Ensure directory exists
  if [[ ! -d "$conf_dir" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "DRY-RUN: would create directory: $conf_dir"
    else
      mkdir -p "$conf_dir"
    fi
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    if [[ -f "$conf" ]]; then
      if grep -Eq '^[[:space:]]*#?[[:space:]]*StoragePass[[:space:]]*=' "$conf"; then
        echo "DRY-RUN: would normalize StoragePass lines in ${conf}: keep one active, comment duplicates"
        echo "DRY-RUN: would set active StoragePass=${pass}"
      else
        echo "DRY-RUN: would append StoragePass=${pass} to ${conf}"
      fi
      if grep -Eq '^[[:space:]]*#?[[:space:]]*StorageLoc[[:space:]]*=' "$conf"; then
        echo "DRY-RUN: would normalize StorageLoc lines in ${conf}: keep one active, comment duplicates"
        echo "DRY-RUN: would set active StorageLoc=${dbname}"
      else
        echo "DRY-RUN: would append StorageLoc=${dbname} to ${conf}"
      fi
    else
      echo "DRY-RUN: would create ${conf} with StoragePass=${pass} and StorageLoc=${dbname}"
    fi
    return 0
  fi

  # Create file if missing, then normalize/replace StoragePass and StorageLoc
  if [[ ! -f "$conf" ]]; then
    printf "StoragePass=%s\nStorageLoc=%s\n" "$pass" "$dbname" > "$conf"
  else
    # Normalize both: first match becomes active; subsequent matches commented with original value preserved
    awk -v pass="$pass" -v dbname="$dbname" '
      BEGIN { pass_done = 0; loc_done = 0 }
      {
        # Normalize StoragePass
        if ($0 ~ /^[[:space:]]*#?[[:space:]]*StoragePass[[:space:]]*=/) {
          if (pass_done == 0) {
            print "StoragePass=" pass
            pass_done = 1
          } else {
            old = $0
            sub(/^[[:space:]]*#?[[:space:]]*StoragePass[[:space:]]*=[[:space:]]*/, "", old)
            print "#StoragePass=" old
          }
          next
        }
        # Normalize StorageLoc
        if ($0 ~ /^[[:space:]]*#?[[:space:]]*StorageLoc[[:space:]]*=/) {
          if (loc_done == 0) {
            print "StorageLoc=" dbname
            loc_done = 1
          } else {
            old = $0
            sub(/^[[:space:]]*#?[[:space:]]*StorageLoc[[:space:]]*=[[:space:]]*/, "", old)
            print "#StorageLoc=" old
          }
          next
        }
        # Default: pass through other lines untouched
        print
      }
      END {
        if (pass_done == 0) {
          print "StoragePass=" pass
        }
        if (loc_done == 0) {
          print "StorageLoc=" dbname
        }
      }
    ' "$conf" > "${conf}.tmp" && mv "${conf}.tmp" "$conf"
  fi

  chmod 600 "$conf" || true
  echo "Normalized StoragePass/StorageLoc in ${conf}: set active values, commented duplicates"
}

# Execute conf update now (before DB, so you can inspect the file if needed)
update_conf "$CONF_FILE" "$SLURM_DB_PASS" "$DB_NAME"

# --- Dry-run: print expanded SQL and exit ---
if [[ "$DRY_RUN" == "true" ]]; then
  echo
  echo "DRY-RUN: SQL to be executed (expanded):"
  echo "----------------------------------------"
  cat <<SQL_EOF
/* Create DB (idempotent) */
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

/* Ensure users exist (idempotent) */
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${SLURM_DB_PASS}';
CREATE USER IF NOT EXISTS '${DB_USER}'@'${HOST_SHORT}' IDENTIFIED BY '${SLURM_DB_PASS}';

/* Enforce/refresh password for both entries (supports --rotate) */
ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${SLURM_DB_PASS}';
ALTER USER '${DB_USER}'@'${HOST_SHORT}' IDENTIFIED BY '${SLURM_DB_PASS}';

/* Grants (safe to re-run) */
GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION;
GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'${HOST_SHORT}' WITH GRANT OPTION;

/* Diagnostics */
SHOW GRANTS FOR '${DB_USER}'@'localhost';
SHOW GRANTS FOR '${DB_USER}'@'${HOST_SHORT}';
SHOW VARIABLES LIKE 'have_innodb';
SQL_EOF
  echo "----------------------------------------"
  exit 0
fi

# --- Ensure sudo works (informational only) ---
if ! sudo -n true 2>/dev/null; then
  echo "Info: sudo requires a password or is restricted. You will be prompted as needed."
fi

# --- Check MariaDB client availability via sudo ---
if ! sudo mariadb --version >/dev/null 2>&1; then
  echo "Error: 'mariadb' client not found or not accessible via sudo. Install MariaDB client/server and ensure sudo permissions." >&2
  exit 3
fi

echo "Connecting via: sudo mariadb (local socket)"

# --- Execute SQL via heredoc (no eval, variables expand here) ---
sudo mariadb --protocol=socket <<SQL_EOF
/* Create DB (idempotent) */
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

/* Ensure users exist (idempotent) */
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${SLURM_DB_PASS}';
CREATE USER IF NOT EXISTS '${DB_USER}'@'${HOST_SHORT}' IDENTIFIED BY '${SLURM_DB_PASS}';

/* Enforce/refresh password for both entries (supports --rotate) */
ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${SLURM_DB_PASS}';
ALTER USER '${DB_USER}'@'${HOST_SHORT}' IDENTIFIED BY '${SLURM_DB_PASS}';

/* Grants (safe to re-run) */
GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION;
GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'${HOST_SHORT}' WITH GRANT OPTION;

/* Diagnostics */
SHOW GRANTS FOR '${DB_USER}'@'localhost';
SHOW GRANTS FOR '${DB_USER}'@'${HOST_SHORT}';
SHOW VARIABLES LIKE 'have_innodb';
SQL_EOF

echo "✅ Completed."
echo "Password stored in ${PWD_FILE} (permissions 600)."
echo "slurmdbd.conf normalized & updated at ${CONF_FILE} (permissions 600)."

