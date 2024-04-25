#!/bin/bash
#
# L       OOO   L     !
# L      O   O  L     !
# L      O   O  L     !
# L      O   O  L      
# LLLLL   OOO   LLLLL !

# Creado por KernelPanicRD01
# kp01aj@gmail.com
#https://discord.gg/VZ7PFx7C

#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
MATRIX_GREEN='\033[0;32m'

# Función para mostrar el menú principal
show_menu() {
    echo -e "${GREEN}🔍 Menú Principal de Nmap para Detección y Análisis de Redes 🌐${NC}"
    echo -e "${GREEN}1. Hacer un scan simple de nmap 🌟${NC}"
    echo -e "${GREEN}2. Hacer un discovery de IPs en un rango de red 🔎${NC}"
    echo -e "${GREEN}3. Hacer un scan detallado y aplicar scripts NSE relevantes 🔬${NC}"
    echo -e "${GREEN}4. Buscar y seleccionar script NSE para ejecución 📄${NC}"
    echo -e "${GREEN}5. Actualizar base de datos de scripts NSE 🔄${NC}"
    echo -e "${GREEN}6. Escanear puertos específicos 🚪${NC}"
    echo -e "${GREEN}7. Escaneo de versiones de servicios 🛠️${NC}"
    echo -e "${GREEN}8. Escaneo agresivo ⚔️${NC}"
    echo -e "${GREEN}9. Detección de sistema operativo 💻${NC}"
    echo -e "${GREEN}10. Escaneo de firewall 🧱${NC}"
    echo -e "${GREEN}11. Escaneo UDP 📡${NC}"
    echo -e "${GREEN}12. Escaneo de fragmentación 🧩${NC}"
    echo -e "${GREEN}13. Escaneo de scripts por categoría 🗂️${NC}"
    echo -e "${GREEN}14. Chequeo de vulnerabilidades específicas 🎯${NC}"
    echo -e "${GREEN}15. Análisis completo de red 🌍${NC}"
    echo -e "${GREEN}16. Escaneo silencioso (Stealth) 🕵️${NC}"
    echo -e "${GREEN}17. Escaneo de sincronización TCP (TCP SYN scan) 🌊${NC}"
    echo -e "${GREEN}18. Escaneo con salida en XML 📊${NC}"
    echo -e "${GREEN}19. Realizar traceroute 🛤️${NC}"
    echo -e "${GREEN}20. Uso de decoys 🎭${NC}"
    echo -e "${GREEN}21. Salir 🚪${NC}"
}

# Función para leer la opción del usuario
read_option() {
    local choice
    read -p "Ingrese la opción deseada [1 - 21]: " choice
    echo $choice
}

# Función general para pedir objetivo
get_target() {
    echo -e "${RED}Ingrese la dirección IP o dominio del objetivo:${NC}"
    read target
    echo $target
}

# Funciones para cada opción del menú
simple_scan() {
    local target=$(get_target)
    nmap $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

network_discovery() {
    echo -e "${RED}Ingrese el rango de red (ej. 192.168.1.0/24):${NC}"
    read range
    nmap -sn $range
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

detailed_scan_and_nse() {
    local target=$(get_target)
    nmap -sV -A -T4 --script=default,vuln $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

search_and_select_nse() {
    echo -e "${RED}Ingrese palabra clave para buscar en los scripts NSE (ej. 'smb', 'http', 'ssl'):${NC}"
    read keyword
    local scripts=($(find /usr/share/nmap/scripts/ -name "*$keyword*.nse"))
    if [ ${#scripts[@]} -eq 0 ]; then
        echo -e "${RED}No se encontraron scripts que coincidan con la búsqueda.${NC}"
        return
    fi
    echo "Scripts encontrados:"
    local index=1
    for script in "${scripts[@]}"; do
        echo -e "${YELLOW}${index}. $(basename $script)${NC}"
        let index++
    done
    echo -e "${RED}Seleccione el número del script que desea ejecutar o 0 para cancelar:${NC}"
    read selection
    if [[ $selection -gt 0 && $selection -le ${#scripts[@]} ]]; then
        local target=$(get_target)
        nmap --script "${scripts[$selection-1]}" $target
    elif [[ $selection -eq 0 ]]; then
        echo "Cancelando selección..."
    else
        echo -e "${RED}Selección inválida. Intente de nuevo.${NC}"
    fi
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

update_nse() {
    echo -e "${GREEN}Actualizando la base de datos de scripts NSE...${NC}"
    nmap --script-updatedb
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Implementaciones para las opciones adicionales
specific_port_scan() {
    local target=$(get_target)
    echo -e "${RED}Ingrese los puertos a escanear (ej. 80,443):${NC}"
    read ports
    nmap -p $ports $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

service_version_scan() {
    local target=$(get_target)
    nmap -sV $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

aggressive_scan() {
    local target=$(get_target)
    nmap -A $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

os_detection_scan() {
    local target=$(get_target)
    nmap -O $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

firewall_scan() {
    local target=$(get_target)
    nmap -sA $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

udp_scan() {
    local target=$(get_target)
    nmap -sU $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

fragment_scan() {
    local target=$(get_target)
    nmap -f $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

script_category_scan() {
    echo -e "${RED}Ingrese la categoría de scripts a ejecutar (ej. 'safe', 'intrusive'):${NC}"
    read category
    local target=$(get_target)
    nmap --script=$category $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

specific_vulnerability_check() {
    echo -e "${RED}Ingrese el script de vulnerabilidad específica (ej. smb-vuln-ms08-067.nse):${NC}"
    read vuln_script
    local target=$(get_target)
    nmap --script=$vuln_script $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

complete_network_analysis() {
    local target=$(get_target)
    nmap -sS -sU -sC -A -O -p- $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

stealth_scan() {
    local target=$(get_target)
    nmap -sS $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

tcp_syn_scan() {
    local target=$(get_target)
    nmap -sS $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

xml_output_scan() {
    local target=$(get_target)
    nmap -oX output.xml $target
    echo -e "${GREEN}Resultados guardados en 'output.xml'${NC}"
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

perform_traceroute() {
    local target=$(get_target)
    nmap --traceroute $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

use_decoys() {
    local target=$(get_target)
    echo -e "${RED}Ingrese la lista de decoys, separados por comas (ej. me,decoy1,decoy2):${NC}"
    read decoys
    nmap -D $decoys $target
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
