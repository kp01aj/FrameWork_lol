#!/bin/bash
# Creado por KernelPanicRD01
# kp01aj@gmail.com
# Este script contiene de opciones orientadas a NSE utilizadas con Nmap para hacer un proceso de enumeracion.
# Base en un MENU

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
    echo -e "${GREEN}Menú Principal de Nmap para Detección de Vulnerabilidades 🛡️${NC}"
    echo -e "${YELLOW}1.${NC} Hacer un scan simple de nmap"
    echo -e "${YELLOW}2.${NC} Hacer un discovery de IPs en un rango de red"
    echo -e "${YELLOW}3.${NC} Hacer un scan detallado y aplicar scripts NSE relevantes"
    echo -e "${YELLOW}4.${NC} Buscar y seleccionar script NSE para ejecución"
    echo -e "${YELLOW}5.${NC} Actualizar base de datos de scripts NSE"
    echo -e "${YELLOW}6.${NC} Salir"
}

# Función para leer la opción del usuario
read_option() {
    local choice
    read -p "Ingrese la opción deseada [1 - 6]: " choice
    echo $choice
}

# Función para realizar un scan simple
simple_scan() {
    echo -e "${RED}Ingrese la dirección IP o dominio del objetivo:${NC}"
    read target
    nmap $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función para realizar un discovery de IPs en un rango de red
network_discovery() {
    echo -e "${RED}Ingrese el rango de red (ej. 192.168.1.0/24):${NC}"
    read range
    nmap -sn $range
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función para realizar un scan detallado y aplicar scripts NSE relevantes
detailed_scan_and_nse() {
    echo -e "${RED}Ingrese la dirección IP o dominio del objetivo para análisis detallado:${NC}"
    read target
    echo -e "${GREEN}Realizando análisis detallado...${NC}"
    nmap -sV -A -T4 --script=default,vuln $target
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función para buscar y seleccionar un script NSE
search_and_select_nse() {
    echo -e "${RED}Ingrese palabra clave para buscar en los scripts NSE (ej. 'smb', 'http', 'ssl'):${NC}"
    read keyword
    local scripts=($(grep -l -R "$keyword" $NSE_PATH | grep '\.nse$'))
    if [ ${#scripts[@]} -eq 0 ]; then
        echo -e "${RED}No se encontraron scripts que coincidan con la búsqueda.${NC}"
        return
    fi
    local index=1
    for script in "${scripts[@]}"; do
        local description=$(grep -m1 'description = ' $script | cut -d '"' -f 2)
        echo -e "${YELLOW}${index}. ${script#$NSE_PATH} - ${description}${NC}"
        let index++
    done
    echo -e "${RED}Seleccione el número del script que desea ejecutar o 0 para cancelar:${NC}"
    read selection
    if [[ $selection -gt 0 && $selection -le ${#scripts[@]} ]]; then
        echo -e "${RED}Ingrese la dirección IP o dominio del objetivo:${NC}"
        read target
        nmap --script "${scripts[$selection-1]}" $target
        echo -e "${BLUE}Presione <Enter> para continuar${NC}"
        read
    elif [[ $selection -eq 0 ]]; then
        echo "Cancelando selección..."
    else
        echo -e "${RED}Selección inválida. Intente de nuevo.${NC}"
    fi
}

# Función para actualizar scripts NSE
update_nse() {
    echo -e "${GREEN}Actualizando la base de datos de scripts NSE...${NC}"
    nmap --script-updatedb
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Ejecución del menú
while true
do
    show_menu
    option=$(read_option)
    case $option in
        1)
            simple_scan
            ;;
        2)
            network_discovery
            ;;
        3)
            detailed_scan_and_nse
            ;;
        4)
            search_and_select_nse
            ;;
        5)
            update_nse
            ;;
        6)
            echo -e "${GREEN}Saliendo...${NC}"
            break
            ;;
        *)
            echo -e "${RED}Opción incorrecta. Intente de nuevo.${NC}"
            ;;
    esac
done
