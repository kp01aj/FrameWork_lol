#!/bin/bash
# Creado por KernelPanicRD01
# kp01aj@gmail.com
# Este script contiene de opciones orientadas a NSE utilizadas con Nmap para hacer un proceso de enumeracion.
# Base en un MENU

#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ruta donde se encuentran los scripts NSE
NSE_PATH="/usr/share/nmap/scripts/"

# Ayuda
usage() {
    echo -e "${GREEN}Uso del script de Nmap:${NC}"
    echo -e "${YELLOW}-s${NC} <IP/domain>       Realiza un escaneo simple de nmap."
    echo -e "${YELLOW}-d${NC} <IP range>       Realiza un discovery de IPs en un rango de red."
    echo -e "${YELLOW}-v${NC} <IP/domain>       Realiza un escaneo detallado y busca vulnerabilidades."
    echo -e "${YELLOW}-n${NC} <keyword>         Busca y selecciona script NSE por palabra clave."
    echo -e "${YELLOW}-u${NC}                   Actualiza la base de datos de scripts NSE."
    echo -e "${YELLOW}-h${NC}                   Muestra este mensaje de ayuda."
    exit 1
}

# Comprobar si se proporcionaron parámetros
if [ $# -eq 0 ]; then
    usage
fi

# Manejar opciones de línea de comandos
while getopts ":s:d:v:n:uh" option; do
    case $option in
        s) # Escaneo simple
            nmap $OPTARG
            ;;
        d) # Discovery de red
            nmap -sn $OPTARG
            ;;
        v) # Escaneo detallado y vulnerabilidades
            nmap -sV -A -T4 --script=default,vuln $OPTARG
            ;;
        n) # Buscar script NSE
            scripts=($(grep -l -R "$OPTARG" $NSE_PATH | grep '\.nse$'))
            if [ ${#scripts[@]} -eq 0 ]; then
                echo -e "${RED}No se encontraron scripts que coincidan con la búsqueda.${NC}"
                exit 1
            fi
            echo -e "${GREEN}Scripts encontrados:${NC}"
            for script in "${scripts[@]}"; do
                local description=$(grep -m1 'description = ' $script | cut -d '"' -f 2)
                echo -e "${YELLOW}${script#$NSE_PATH} - ${description}${NC}"
            done
            ;;
        u) # Actualizar scripts NSE
            nmap --script-updatedb
            ;;
        h) # Ayuda
            usage
            ;;
        \?) # Opción inválida
            echo -e "${RED}Opción inválida: -$OPTARG${NC}" >&2
            usage
            ;;
    esac
done

# Verificar si se utilizó alguna opción
if [ $OPTIND -eq 1 ]; then
    usage
fi
