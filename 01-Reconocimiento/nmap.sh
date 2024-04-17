#!/bin/bash
# Creado por KernelPanicRD01
# kp01aj@gmail.com
# Este script contiene de las opcioens mas utilizadas con Nmap para hacer un proceso de enumeracion.

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar el menú
show_menu() {
    echo -e "${GREEN}Menú de opciones de Nmap 🌐${NC}"
    echo -e "${YELLOW}1.${NC} Escaneo de Puertos Completo 🚀"
    echo -e "${YELLOW}2.${NC} Detección de Servicios y Versión 📡"
    echo -e "${YELLOW}3.${NC} Detección de Sistema Operativo 🖥️"
    echo -e "${YELLOW}4.${NC} Escaneo de Scripts 📜"
    echo -e "${YELLOW}5.${NC} Escaneo Agresivo 🏹"
    echo -e "${YELLOW}6.${NC} Escaneo UDP 🛰️"
    echo -e "${YELLOW}7.${NC} Escaneo Stealth 🕶️"
    echo -e "${YELLOW}8.${NC} Escaneo de Subred 🔍"
    echo -e "${YELLOW}9.${NC} Escaneo de IPs desde un Archivo 📂"
    echo -e "${YELLOW}10.${NC} Guardar los Resultados en un Archivo 📋"
    echo -e "${YELLOW}11.${NC} Ayuda 🆘"
    echo -e "${YELLOW}12.${NC} Salir 🚪"
}

# Función para leer la opción del usuario
read_option() {
    local choice
    read -p "Ingrese la opción deseada [1 - 12]: " choice
    echo $choice
}

# Funciones para cada comando de Nmap
perform_action() {
    case $1 in
        1) nmap -p- -v $2 ;;
        2) nmap -sV $2 ;;
        3) nmap -A $2 ;;
        4) nmap --script=vuln $2 ;;
        5) nmap -A -T4 $2 ;;
        6) nmap -sU $2 ;;
        7) nmap -sS $2 ;;
        8) nmap -sV -p 80,443 $2 ;;
        9) nmap -iL $2 ;;
        10) nmap -oN salida.txt $2; echo "Resultados guardados en salida.txt" ;;
    esac
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función de ayuda
show_help() {
    echo -e "${BLUE}Ayuda - Descripciones de las opciones del menú:${NC}"
    echo -e "${YELLOW}1.${NC} Escanea todos los puertos de una IP o dominio."
    echo -e "${YELLOW}2.${NC} Identifica los servicios y sus versiones en los puertos abiertos."
    echo -e "${YELLOW}3.${NC} Realiza un escaneo completo que incluye OS, servicios, versión y traceroute."
    echo -e "${YELLOW}4.${NC} Ejecuta scripts de Nmap para identificar vulnerabilidades."
    echo -e "${YELLOW}5.${NC} Escaneo agresivo para detección rápida."
    echo -e "${YELLOW}6.${NC} Escaneo de puertos UDP."
    echo -e "${YELLOW}7.${NC} Realiza un escaneo stealth, útil para evadir IDS/IPS."
    echo -e "${YELLOW}8.${NC} Escanea múltiples hosts en una subred específica."
    echo -e "${YELLOW}9.${NC} Escanea IPs listadas en un archivo."
    echo -e "${YELLOW}10.${NC} Guarda los resultados del escaneo en un archivo."
    echo -e "${YELLOW}11.${NC} Muestra esta ayuda."
    echo -e "${YELLOW}12.${NC} Salir del script."
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Ejecución del menú
while true
do
    show_menu
    option=$(read_option)
    case $option in
        1|2|3|4|5|6|7|8|9|10)
            echo -e "${RED}Ingresar dirección IP o dominio:${NC}"
            read target
            perform_action $option $target
            ;;
        11)
            show_help
            ;;
        12)
            echo -e "${GREEN}Saliendo...${NC}"
            break
            ;;
        *)
            echo -e "${RED}Opción incorrecta. Intente de nuevo.${NC}"
            ;;
    esac
done
