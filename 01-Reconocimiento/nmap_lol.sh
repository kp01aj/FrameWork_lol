#!/bin/bash
# Creado por KernelPanicRD01
# kp01aj@gmail.com
#https://discord.gg/VZ7PFx7C

#Descripción del Script
#Opción 1: Realiza un escaneo simple de Nmap.
#Opción 2: Descubre dispositivos activos dentro de un rango de red especificado.
#Opción 3: Realiza un escaneo detallado de la IP o dominio objetivo y luego aplica scripts NSE relevantes para identificar vulnerabilidades.
#Opción 4: Permite buscar scripts NSE por palabras clave y seleccionar uno para ejecutarlo en un objetivo especificado.
#Opción 5: Actualiza la base de datos de scripts NSE para asegurar que se usen las versiones más recientes.
#Opción 6: Salir del script.

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ruta donde se encuentran los scripts NSE
NSE_PATH="/usr/share/nmap/scripts/"

# Función para mostrar el menú principal
show_menu() {
    echo -e "${GREEN}Menú Principal de Nmap para Detección y Análisis de Redes 🛡️${NC}"
    echo -e "${YELLOW}1.${NC} Hacer un scan simple de nmap"
    echo -e "${YELLOW}2.${NC} Hacer un discovery de IPs en un rango de red"
    echo -e "${YELLOW}3.${NC} Hacer un scan detallado y aplicar scripts NSE relevantes"
    echo -e "${YELLOW}4.${NC} Buscar y seleccionar script NSE para ejecución"
    echo -e "${YELLOW}5.${NC} Actualizar base de datos de scripts NSE"
    echo -e "${YELLOW}6.${NC} Escanear puertos específicos"
    echo -e "${YELLOW}7.${NC} Escaneo de versiones de servicios"
    echo -e "${YELLOW}8.${NC} Escaneo agresivo"
    echo -e "${YELLOW}9.${NC} Detección de sistema operativo"
    echo -e "${YELLOW}10.${NC} Escaneo de firewall"
    echo -e "${YELLOW}11.${NC} Escaneo UDP"
    echo -e "${YELLOW}12.${NC} Escaneo de fragmentación"
    echo -e "${YELLOW}13.${NC} Escaneo de scripts por categoría"
    echo -e "${YELLOW}14.${NC} Chequeo de vulnerabilidades específicas"
    echo -e "${YELLOW}15.${NC} Análisis completo de red"
    echo -e "${YELLOW}16.${NC} Escaneo silencioso (Stealth)"
    echo -e "${YELLOW}17.${NC} Escaneo de sincronización TCP (TCP SYN scan)"
    echo -e "${YELLOW}18.${NC} Escaneo con salida en XML"
    echo -e "${YELLOW}19.${NC} Realizar traceroute"
    echo -e "${YELLOW}20.${NC} Uso de decoys"
    echo -e "${YELLOW}21.${NC} Salir"
}

# Función para leer la opción del usuario
read_option() {
    local choice
    read -p "Ingrese la opción deseada [1 - 21]: " choice
    echo $choice
}

# Aquí se deberían definir las funciones de escaneo detalladas para cada una de las opciones adicionales
# Por ejemplo, la función para el escaneo agresivo:
aggressive_scan() {
    echo -e "${RED}Ingrese la dirección IP o dominio del objetivo:${NC}"
    read target
    nmap -A $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Ejecución del menú
while true
do
    show_menu
    option=$(read_option)
    case $option in
        1) simple_scan ;;
        2) network_discovery ;;
        3) detailed_scan_and_nse ;;
        4) search_and_select_nse ;;
        5) update_nse ;;
        6) specific_port_scan ;;
        7) service_version_scan ;;
        8) aggressive_scan ;;
        9) os_detection_scan ;;
        10) firewall_scan ;;
        11) udp_scan ;;
        12) fragment_scan ;;
        13) script_category_scan ;;
        14) specific_vulnerability_check ;;
        15) complete_network_analysis ;;
        16) stealth_scan ;;
        17) tcp_syn_scan ;;
        18) xml_output_scan ;;
        19) perform_traceroute ;;
        20) use_decoys ;;
        21) echo -e "${GREEN}Saliendo...${NC}"; break ;;
        *) echo -e "${RED}Opción incorrecta. Intente de nuevo.${NC}" ;;
    esac
done
