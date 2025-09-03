#!/bin/bash
#Pentesting Toolkit Framework_lol

set -Eeuo pipefail

# force-brute.sh – Wrapper de Hydra con salida en vivo, paralelo y reporte CSV (sin duplicados)
# Archivos en el cwd:
#   - salidas.log                 (append; cabecera por ejecución con fecha/usuario)
#   - report_YYYYmmdd-HHMMSS.csv  (IP,User,Password; sin repetidos)
# Servicios: ssh | ftp | mysql | rdp | http-post-form | https-post-form
# Autor: https://github.com/kp01aj

# -------------------- Defaults --------------------
SERVICE="ssh"
PORT=""
THREADS=4
PARALLEL_N=5
WAIT_TIME=6
FIRSTHIT=true          # -f por host
SHOW_ATTEMPTS=true     # -V
VERBOSE=false          # -vV (además de -V)
IGNORE_RESTORE=true    # -I
DEFAULT_LIB="./lib"
EXAMPLES=false         # -e / --examples

SINGLE_PAIR=""         # --single "user:pass"
HOST_MAP=""            # --host-map host,user,pass (CSV)
ZIP_MODE=false         # --zip (empareja user-list/pass-list por índice con -C)
HYDRA_EXTRA="${HYDRA_EXTRA:-}"

# HTTP helpers
HTTP_FORM=""           # --http-form 'ruta:datos:condiciones'
HTTP_PATH=""           # --http-path '/login'
HTTP_DATA=""           # --http-data 'user=^USER^&pass=^PASS^'
HTTP_SUCCESS=""        # --http-success 'Bienvenido'
HTTP_FAIL=""           # --http-fail 'Error'
HTTP_HEADERS=()        # --http-header 'Header: Valor' (repetible)

# -------------------- UI helpers --------------------
if [ -t 1 ]; then
  B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; Z=$'\033[0m'
else
  B=""; G=""; Y=""; R=""; Z=""
fi

say() {
  echo -e "${B}[*]${Z} $*"
}
ok() {
  echo -e "${G}[✓]${Z} $*"
}
warn() {
  echo -e "${Y}[!]${Z} $*"
}
err() {
  echo -e "${R}[x]${Z} $*" >&2
}

usage() {
  cat <<'EOF'
force-brute.sh – Salida en vivo (prefijo [IP]), paralelo (5) y reporte CSV.

Genera SOLO:
  - salidas.log                 (append; cabecera con fecha/usuario)
  - report_YYYYmmdd-HHMMSS.csv  (IP,User,Password; sin repetidos)

MODO AUTO: usa ./lib/user.txt ./lib/pass.txt ./lib/hosts.txt y servicio ssh.

MODOS (opcionales):
  --single user:pass        Un intento por host con ese par
  --host-map archivo.csv    CSV "host,user,pass" (un intento por host)
  --zip                     Empareja user-list y pass-list por índice (-C)

SERVICIOS:
  -s, --service <svc>       ssh|ftp|mysql|rdp|http-post-form|https-post-form  (default: ssh)
      --port <n>            Puerto (por defecto: ssh:22, ftp:21, mysql:3306, rdp:3389, http:80, https:443)

TARGETS:
  -i, --ip <host>           Host único (repetible)
      --ip-list <file>      Lista de hosts (default: ./lib/hosts.txt)

CREDENCIALES:
  -u, --user <name>         Usuario (repetible) [normal o --zip]
      --user-list <file>    Lista de usuarios (default: ./lib/user.txt)
  -p, --pass <pwd|csv>      Una contraseña o CSV "a,b,c" [normal o --zip]
      --pass-list <file>    Lista de contraseñas (default: ./lib/pass.txt)

HTTP/HTTPS (elige una forma):
  --http-form "ruta:datos:cond"           (p.ej. "/login.php:u=^USER^&p=^PASS^:F=Error")
  --http-path "/login" --http-data "u=^USER^&p=^PASS^" \
      [--http-success "OK"] [--http-fail "Error"] [--http-header "H: V"]...

OTROS:
      --threads <n>         Hilos por host (Hydra -t). Default: 4
      --parallel <n>        Jobs simultáneos. Default: 5
      --no-first            No detener al primer acierto por host
      --quiet               No mostrar cada intento (quita -V)
      --very-verbose        Añade -vV (además de -V si aplica)
      --no-ignore-restore   No pasar -I a Hydra
      --wait <sec>          Hydra -w (timeout intento). Default: 6
  -e,  --examples           Mostrar ejemplos y salir
      --help                Ayuda

REFERENCIAS
  - Autor:  Angel - Framework_lol https://github.com/kp01aj
  - Web:    https://www.newplain.com
  - Hydra:  https://github.com/vanhauser-thc/thc-hydra

EOF
}

print_examples() {
  cat <<'EXS'
# SSH
# Listas por defecto (lib/hosts.txt, lib/user.txt, lib/pass.txt)
./force-brute.sh -s ssh

# Un par específico para un host (una sola prueba por host)
./force-brute.sh -s ssh --ip 10.200.6.28 --single root:abcd1234

# Puerto no estándar
./force-brute.sh -s ssh --ip 10.0.0.10 --port 2222 --user-list lib/user.txt --pass-list lib/pass.txt


# FTP
# FTP estándar (21)
./force-brute.sh -s ftp --ip-list lib/hosts.txt --user-list lib/user.txt --pass-list lib/pass.txt

# Puerto personalizado (2121)
./force-brute.sh -s ftp --ip 10.0.0.20 --port 2121 --user-list lib/ftp_users.txt --pass-list lib/ftp_pass.txt


# MySQL
# Diccionarios
./force-brute.sh -s mysql --ip 10.0.0.30 --user-list lib/mysql_users.txt --pass-list lib/mysql_pass.txt

# Par concreto
./force-brute.sh -s mysql --ip 10.0.0.30 --single root:toor


# RDP (Windows)
# Sugerencia: baja hilos para evitar lockouts
./force-brute.sh -s rdp --ip-list lib/win_hosts.txt --user-list lib/win_users.txt --pass-list lib/win_pass.txt --threads 2


# HTTP (http-post-form) – forma 1: triple directo
./force-brute.sh -s http-post-form --ip 10.0.0.40 \
  --http-form "/login.php:username=^USER^&password=^PASS^:F=Credenciales inválidas"

# HTTPS en puerto 8443 con texto de éxito (+ header User-Agent)
./force-brute.sh -s https-post-form --ip 10.0.0.41 --port 8443 \
  --http-form "/auth:usr=^USER^&pwd=^PASS^:S=Bienvenido:H=User-Agent\:\ Mozilla/5.0" \
  --user-list lib/users.txt --pass-list lib/pass.txt

# HTTP – forma 2 (amigable): el script arma el triple
./force-brute.sh -s http-post-form --ip 10.0.0.42 \
  --http-path "/login" \
  --http-data "user=^USER^&pass=^PASS^" \
  --http-fail "Login incorrecto" \
  --http-header "X-Requested-With: XMLHttpRequest" \
  --user-list lib/users.txt --pass-list lib/pass.txt
EXS
}

# -------------------- Parseo simple --------------------
USER_SINGLE=()
USER_LIST=""
PASS_SINGLE=""
PASS_LIST=""
IP_SINGLE=()
IP_LIST=""

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--service) SERVICE="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    -i|--ip) IP_SINGLE+=("$2"); shift 2 ;;
    --ip-list) IP_LIST="$2"; shift 2 ;;
    -u|--user) USER_SINGLE+=("$2"); shift 2 ;;
    --user-list) USER_LIST="$2"; shift 2 ;;
    -p|--pass) PASS_SINGLE="$2"; shift 2 ;;
    --pass-list) PASS_LIST="$2"; shift 2 ;;
    --threads) THREADS="$2"; shift 2 ;;
    --parallel) PARALLEL_N="$2"; shift 2 ;;
    --no-first) FIRSTHIT=false; shift ;;
    --quiet) SHOW_ATTEMPTS=false; shift ;;
    --very-verbose) VERBOSE=true; shift ;;
    --no-ignore-restore) IGNORE_RESTORE=false; shift ;;
    --wait) WAIT_TIME="$2"; shift 2 ;;
    --single) SINGLE_PAIR="$2"; shift 2 ;;
    --host-map) HOST_MAP="$2"; shift 2 ;;
    --zip) ZIP_MODE=true; shift ;;
    --http-form) HTTP_FORM="$2"; shift 2 ;;
    --http-path) HTTP_PATH="$2"; shift 2 ;;
    --http-data) HTTP_DATA="$2"; shift 2 ;;
    --http-success) HTTP_SUCCESS="$2"; shift 2 ;;
    --http-fail) HTTP_FAIL="$2"; shift 2 ;;
    --http-header) HTTP_HEADERS+=("$2"); shift 2 ;;
    -e|--examples) EXAMPLES=true; shift ;;
    --help) usage; exit 0 ;;
    *) err "Opción inválida: $1"; usage; exit 1 ;;
  esac
done

if $EXAMPLES; then
  print_examples
  exit 0
fi

# -------------------- Utilidades --------------------
abspath() {
  local p="${1:-}"
  if [ -z "$p" ]; then
    echo ""
    return 0
  fi
  if command -v readlink >/dev/null 2>&1; then
    readlink -f -- "$p"
  else
    local dir base
    dir="$(cd "$(dirname -- "$p")" && pwd -P)"
    base="$(basename -- "$p")"
    echo "${dir}/${base}"
  fi
}

port_for_service() {
  case "$SERVICE" in
    ssh) echo "${PORT:-22}";;
    ftp) echo "${PORT:-21}";;
    mysql) echo "${PORT:-3306}";;
    rdp) echo "${PORT:-3389}";;
    http-post-form) echo "${PORT:-80}";;
    https-post-form) echo "${PORT:-443}";;
    *) echo "${PORT:-}";;
  esac
}

sanitize() {
  echo "${1//[^A-Za-z0-9_.-]/_}"
}

precheck() {
  local host="$1" port="$2"
  if command -v nc >/dev/null 2>&1 && [ -n "$port" ]; then
    nc -z -w 2 "$host" "$port" >/dev/null 2>&1
    return $?
  fi
  return 0
}

if ! command -v hydra >/dev/null 2>&1; then
  err "hydra no está instalado."
  exit 1
fi

# -------------------- Auto-modo ./lib/* --------------------
say "Auto-modo: usando ./lib/* si existen. (Tip: --help para opciones)"
if [ -z "$IP_LIST" ] && [ ${#IP_SINGLE[@]} -eq 0 ] && [ -f "$DEFAULT_LIB/hosts.txt" ]; then
  IP_LIST="$DEFAULT_LIB/hosts.txt"
fi

if [ -z "$SINGLE_PAIR" ] && [ -z "$HOST_MAP" ]; then
  if [ -z "$USER_LIST" ] && [ ${#USER_SINGLE[@]} -eq 0 ] && [ -f "$DEFAULT_LIB/user.txt" ]; then
    USER_LIST="$DEFAULT_LIB/user.txt"
  fi
  if [ -z "$PASS_LIST" ] && [ -z "$PASS_SINGLE" ] && [ -f "$DEFAULT_LIB/pass.txt" ]; then
    PASS_LIST="$DEFAULT_LIB/pass.txt"
  fi
fi

# -------------------- Hosts --------------------
declare -a TARGETS
if [ -n "$HOST_MAP" ]; then
  HOST_MAP="$(abspath "$HOST_MAP")"
  [ -f "$HOST_MAP" ] || { err "No existe --host-map: $HOST_MAP"; exit 1; }
  mapfile -t TARGETS < <(cut -d',' -f1 "$HOST_MAP" | sed 's/\r$//' | sed 's/^\s*//;s/\s*$//' | grep -v '^$' | awk '!seen[$0]++')
else
  if [ -n "$IP_LIST" ]; then
    IP_LIST="$(abspath "$IP_LIST")"
    [ -f "$IP_LIST" ] || { err "No existe --ip-list: $IP_LIST"; exit 1; }
    mapfile -t from_file < <(grep -v '^\s*$' "$IP_LIST" | sed 's/\r$//' | sed 's/^\s*//;s/\s*$//')
    TARGETS+=("${from_file[@]}")
  fi
  if [ ${#IP_SINGLE[@]} -gt 0 ]; then
    TARGETS+=("${IP_SINGLE[@]}")
  fi
fi
# dedup
declare -A seen
tmp=()
for h in "${TARGETS[@]}"; do
  if [ -n "$h" ] && [ -z "${seen[$h]:-}" ]; then
    tmp+=("$h"); seen["$h"]=1
  fi
done
TARGETS=("${tmp[@]}")
[ ${#TARGETS[@]} -eq 0 ] && { err "No hay hosts objetivo."; exit 1; }

# -------------------- Credenciales por modo --------------------
USER_OPT=(); PASS_OPT=()
TMP_USERFILE=""; TMP_PASSFILE=""; COMBO_FILE=""

if [ -n "$SINGLE_PAIR" ]; then
  IFS=':' read -r SP_USER SP_PASS <<<"$SINGLE_PAIR"
  if [ -z "${SP_USER:-}" ] || [ -z "${SP_PASS:-}" ]; then
    err "--single requiere user:pass"; exit 1
  fi
  USER_OPT=(-l "$SP_USER"); PASS_OPT=(-p "$SP_PASS")

elif [ -n "$HOST_MAP" ]; then
  : # se resuelve por host en run_one

elif $ZIP_MODE; then
  { [ -n "$USER_LIST" ] || [ ${#USER_SINGLE[@]} -gt 0 ]; } || { err "--zip requiere --user-list o -u"; exit 1; }
  { [ -n "$PASS_LIST" ] || [ -n "$PASS_SINGLE" ]; } || { err "--zip requiere --pass-list o -p"; exit 1; }
  # users
  if [ -n "$USER_LIST" ]; then
    USER_LIST="$(abspath "$USER_LIST")"; [ -f "$USER_LIST" ] || { err "No existe user-list: $USER_LIST"; exit 1; }
  else
    TMP_USERFILE="$(mktemp /tmp/force-users.XXXX)"; : >"$TMP_USERFILE"
    for u in "${USER_SINGLE[@]}"; do printf '%s\n' "$(echo -n "$u" | xargs)" >>"$TMP_USERFILE"; done
    USER_LIST="$TMP_USERFILE"
  fi
  # pass
  if [ -n "$PASS_LIST" ]; then
    PASS_LIST="$(abspath "$PASS_LIST")"; [ -f "$PASS_LIST" ] || { err "No existe pass-list: $PASS_LIST"; exit 1; }
  else
    TMP_PASSFILE="$(mktemp /tmp/force-pass.XXXX)"; : >"$TMP_PASSFILE"
    if [[ "$PASS_SINGLE" == *","* ]]; then IFS=',' read -r -a PARR <<<"$PASS_SINGLE"; else PARR=("$PASS_SINGLE"); fi
    for p in "${PARR[@]}"; do printf '%s\n' "$(echo -n "$p" | xargs)" >>"$TMP_PASSFILE"; done
    PASS_LIST="$TMP_PASSFILE"
  fi
  COMBO_FILE="$(mktemp /tmp/force-combos.XXXX)"; paste -d: "$USER_LIST" "$PASS_LIST" > "$COMBO_FILE"
  USER_OPT=(-C "$COMBO_FILE"); PASS_OPT=()

else
  # modo cartesiando: -L/-P
  if [ -n "$USER_LIST" ]; then
    USER_LIST="$(abspath "$USER_LIST")"; [ -f "$USER_LIST" ] || { err "No existe user-list: $USER_LIST"; exit 1; }
    USER_OPT=(-L "$USER_LIST")
  elif [ ${#USER_SINGLE[@]} -gt 0 ]; then
    TMP_USERFILE="$(mktemp /tmp/force-users.XXXX)"; : >"$TMP_USERFILE"
    for u in "${USER_SINGLE[@]}"; do printf '%s\n' "$(echo -n "$u" | xargs)" >>"$TMP_USERFILE"; done
    USER_OPT=(-L "$TMP_USERFILE")
  else
    err "Faltan usuarios (user-list o -u)"; exit 1
  fi

  if [ -n "$PASS_LIST" ]; then
    PASS_LIST="$(abspath "$PASS_LIST")"; [ -f "$PASS_LIST" ] || { err "No existe pass-list: $PASS_LIST"; exit 1; }
    PASS_OPT=(-P "$PASS_LIST")
  elif [ -n "$PASS_SINGLE" ]; then
    if [[ "$PASS_SINGLE" == *","* ]]; then
      TMP_PASSFILE="$(mktemp /tmp/force-pass.XXXX)"; : >"$TMP_PASSFILE"
      IFS=',' read -r -a PARR <<<"$PASS_SINGLE"
      for p in "${PARR[@]}"; do printf '%s\n' "$(echo -n "$p" | xargs)" >>"$TMP_PASSFILE"; done
      PASS_OPT=(-P "$TMP_PASSFILE")
    else
      PASS_OPT=(-p "$PASS_SINGLE")
    fi
  else
    err "Faltan contraseñas (pass-list o -p)"; exit 1
  fi
fi

# Verbosidad y flags Hydra
VERB_OPT=(); $SHOW_ATTEMPTS && VERB_OPT+=(-V); $VERBOSE && VERB_OPT=(-vV)
FIRST_OPT=(); $FIRSTHIT && FIRST_OPT=(-f)
PORT_OPT=();  [ -n "$PORT" ] && PORT_OPT=(-s "$PORT")
IR_OPT=();    $IGNORE_RESTORE && IR_OPT=(-I)

# -------------------- Archivos de salida --------------------
RUN_TS="$(date +%Y%m%d-%H%M%S)"
REPORT="report_${RUN_TS}.csv"
SALIDAS_LOG="salidas.log"
RUN_USER="$(id -un 2>/dev/null || whoami)"

{
  echo "===================================================================="
  echo "RUN: $(date -Is) | user: ${RUN_USER} | service: ${SERVICE} | hosts: ${#TARGETS[@]}"
  echo "===================================================================="
} >> "$SALIDAS_LOG"

echo "IP,User,Password" > "$REPORT"

say "Servicio: ${SERVICE}  |  Hilos/host: ${THREADS}  |  Paralelo: ${PARALLEL_N}  |  Mostrar intentos: ${SHOW_ATTEMPTS}"
say "Hosts: ${#TARGETS[@]}  |  Reporte: $REPORT  |  Log: $SALIDAS_LOG"
[ -n "$SINGLE_PAIR" ] && ok "--single $SINGLE_PAIR"
[ -n "$HOST_MAP" ] && ok "--host-map $HOST_MAP"
$ZIP_MODE && ok "--zip (índice -C)"

# Dedup global para CSV (IP|User|Password)
declare -A HITS_SEEN

# -------------------- HTTP helpers --------------------
escape_colons() {
  echo "$1" | sed 's/:/\\:/g'
}

http_build_triple() {
  local triple="$HTTP_FORM"
  if [ -z "$triple" ]; then
    [ -n "$HTTP_PATH" ] && [ -n "$HTTP_DATA" ] || { err "HTTP requiere --http-form o (--http-path y --http-data)"; exit 1; }
    local path data conds parts=()
    path="$(escape_colons "$HTTP_PATH")"
    data="$(escape_colons "$HTTP_DATA")"
    conds=""
    [ -n "$HTTP_SUCCESS" ] && parts+=("S=$(escape_colons "$HTTP_SUCCESS")")
    [ -n "$HTTP_FAIL" ] && parts+=("F=$(escape_colons "$HTTP_FAIL")")
    if [ ${#HTTP_HEADERS[@]} -gt 0 ]; then
      for h in "${HTTP_HEADERS[@]}"; do
        parts+=("H=$(escape_colons "$h")")
      done
    fi
    conds="$(IFS=:; echo "${parts[*]}")"
    [ -z "$conds" ] && { err "HTTP requiere al menos --http-success o --http-fail"; exit 1; }
    triple="${path}:${data}:${conds}"
  fi
  echo "$triple"
}

is_http_module() {
  [ "$SERVICE" = "http-post-form" ] || [ "$SERVICE" = "https-post-form" ]
}

# -------------------- Runner por host --------------------
run_one() {
  local host="$1"
  local tmphostlog="$2"
  local rundir
  rundir="$(mktemp -d /tmp/forcebrute.XXXXXX)"

  echo "[$host] inicio (threads=${THREADS}, wait=${WAIT_TIME}s)" | tee -a "$SALIDAS_LOG"

  local CMD=()
  CMD=(hydra -t "$THREADS" -w "$WAIT_TIME" "${FIRST_OPT[@]}" "${VERB_OPT[@]}" "${IR_OPT[@]}" "${PORT_OPT[@]}")
  if [ -n "$HYDRA_EXTRA" ]; then
    read -r -a EXTRA_ARR <<< "$HYDRA_EXTRA"
    CMD+=("${EXTRA_ARR[@]}")
  fi

  # Credenciales
  if [ -n "$HOST_MAP" ]; then
    local line u p
    line="$(grep -E "^${host}," "$HOST_MAP" | head -n1 || true)"
    if [ -z "$line" ]; then
      echo "[$host] sin entrada en host-map (omitido)" | tee -a "$SALIDAS_LOG"
      rmdir "$rundir"; return 0
    fi
    IFS=',' read -r _hm_host u p <<<"$line"
    CMD+=(-l "$u" -p "$p")
  else
    CMD+=("${USER_OPT[@]}")
    [ ${#PASS_OPT[@]} -gt 0 ] && CMD+=("${PASS_OPT[@]}")
  fi

  # Target según módulo
  if is_http_module; then
    local triple
    triple="$(http_build_triple)"
    # Orden Hydra HTTP: host [ -s port ] module "triple"
    CMD+=("$host" "$SERVICE" "$triple")
  else
    local uri="$SERVICE://$host"
    [ -n "$PORT" ] && uri="$SERVICE://$host:$PORT"
    CMD+=("$uri")
  fi

  (
    cd "$rundir"
    if command -v stdbuf >/dev/null 2>&1; then
      stdbuf -oL -eL "${CMD[@]}" 2>&1
    else
      "${CMD[@]}" 2>&1
    fi
  ) | awk -v H="$host" '
        /login:[[:space:]]+.*password:[[:space:]]+/ {
          u=""; p="";
          if (match($0, /login:[[:space:]]*([^[:space:]]+)/, m)) u=m[1];
          if (match($0, /password:[[:space:]]*([^[:space:]]+)/, n)) p=n[1];
          key=H "|" u "|" p;
          if (!seen[key]++) print;
          next
        }
        { print }
      ' | sed -u "s/^/[$host] /" \
        | tee -a "$SALIDAS_LOG" "$tmphostlog" >/dev/null

  echo "[$host] fin" | tee -a "$SALIDAS_LOG"
  rm -rf "$rundir"
}

parse_hits() {
  local host="$1"
  local tmphostlog="$2"
  # Extrae user y pass del log y guarda tuplas únicas (IP,User,Password)
  while IFS=, read -r u p; do
    [ -z "$u" ] || [ -z "$p" ] && continue
    local key="$host|$u|$p"
    if [ -z "${HITS_SEEN[$key]:-}" ]; then
      HITS_SEEN[$key]=1
      ok "HIT $host  ${B}$u${Z}:${G}$p${Z}"
      echo "$host,$u,$p" >> "$REPORT"
    fi
  done < <(
    awk -v H="$host" '
      match($0, /host:[[:space:]]*([0-9a-fA-F\.:]+)[[:space:]]+login:[[:space:]]*([^[:space:]]+)[[:space:]]+password:[[:space:]]*([^[:space:]]+)/, m) {
        if (m[1] == H) { print m[2] "," m[3]; }
      }
    ' "$tmphostlog"
  )
}

# -------------------- Ejecutar en paralelo --------------------
PORTNUM="$(port_for_service)"
pids=(); hosts_started=(); tmp_logs=()

for host in "${TARGETS[@]}"; do
  if [ -n "$PORTNUM" ] && ! precheck "$host" "$PORTNUM"; then
    warn "Puerto $PORTNUM no accesible en $host (saltado)." | tee -a "$SALIDAS_LOG"
    continue
  fi
  TMPHOSTLOG="$(mktemp /tmp/forcebrute.log.XXXXXX)"
  run_one "$host" "$TMPHOSTLOG" &
  pids+=("$!"); hosts_started+=("$host"); tmp_logs+=("$TMPHOSTLOG")
  while [ "$(jobs -rp | wc -l)" -ge "$PARALLEL_N" ]; do sleep 0.2; done
done

wait || true

# -------------------- Parsear resultados + limpiar tmp --------------------
for i in "${!tmp_logs[@]}"; do
  parse_hits "${hosts_started[$i]}" "${tmp_logs[$i]}"
  rm -f "${tmp_logs[$i]}"
done

say "Reporte listo: ${B}$REPORT${Z}"
ok  "Log (append): ${SALIDAS_LOG}"

