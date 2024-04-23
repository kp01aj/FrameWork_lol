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

#Descripción:
# Vamos a crear una versión del script anterior que utiliza Wireshark en lugar de Nmap, con opciones que sean más 
# relevantes para las capacidades de análisis de paquetes de Wireshark. Ten en cuenta que Wireshark no es una herramienta 
# de línea de comandos como Nmap, pero podemos utilizar tshark, que es la versión de consola de Wireshark, para automatizar 
# capturas y análisis de paquetes desde un script de Bash.

# Opciones del script:
##Captura desde interfaz: Captura tráfico directamente de una interfaz de red específica.
##Filtrar por protocolo: Filtra y muestra tráfico basado en un protocolo específico.
##Captura por tiempo: Limita la captura de tráfico a un tiempo específico.
##Filtrar por dirección IP: Filtra tráfico asociado con una dirección IP específica.
##Extraer información HTTP: Extrae y muestra detalles de las solicitudes HTTP.
##Guardar tráfico: Guarda el tráfico capturado en un archivo para análisis posterior.
##Analizar archivo de captura: Permite analizar un archivo de captura existente.
##Filtrar por puerto: Filtra tráfico de un puerto específico.

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar el menú principal
show_menu() {
    echo -e "${GREEN}Menú Principal de Tshark para Análisis de Tráfico de Redes 🌐${NC}"
    echo -e "${YELLOW}1.${NC} Capturar tráfico de una interfaz específica"
    echo -e "${YELLOW}2.${NC} Filtrar tráfico por protocolo"
    echo -e "${YELLOW}3.${NC} Capturar tráfico por un período específico"
    echo -e "${YELLOW}4.${NC} Filtrar tráfico por dirección IP"
    echo -e "${YELLOW}5.${NC} Extraer información de sesiones HTTP"
    echo -e "${YELLOW}6.${NC} Guardar tráfico capturado a un archivo"
    echo -e "${YELLOW}7.${NC} Analizar contenido de un archivo de captura"
    echo -e "${YELLOW}8.${NC} Filtrar tráfico por puerto"
    echo -e "${YELLOW}9.${NC} Salir"
}

# Función para leer la opción del usuario
read_option() {
    local choice
    read -p "Ingrese la opción deseada [1 - 9]: " choice
    echo $choice
}

# Funciones para cada opción del menú

# Captura desde interfaz específica
capture_from_interface() {
    echo -e "${RED}Ingrese la interfaz de red (ej. eth0):${NC}"
    read interface
    echo -e "${GREEN}Capturando tráfico... Presione Ctrl+C para detener.${NC}"
    tshark -i $interface
}

# Filtrar tráfico por protocolo
filter_by_protocol() {
    echo -e "${RED}Ingrese el protocolo (ej. tcp, udp, icmp):${NC}"
    read protocol
    echo -e "${GREEN}Capturando tráfico... Presione Ctrl+C para detener.${NC}"
    tshark -Y $protocol
}

# Captura por tiempo limitado
capture_for_time() {
    echo -e "${RED}Ingrese el tiempo de captura en segundos:${NC}"
    read time
    echo -e "${GREEN}Capturando tráfico durante $time segundos...${NC}"
    tshark -a duration:$time
}

# Filtrar por dirección IP
filter_by_ip() {
    echo -e "${RED}Ingrese la dirección IP (ej. 192.168.1.1):${NC}"
    read ip
    echo -e "${GREEN}Capturando tráfico relacionado con $ip... Presione Ctrl+C para detener.${NC}"
    tshark -Y "ip.addr == $ip"
}

# Extraer información HTTP
extract_http_info() {
    echo -e "${GREEN}Capturando sesiones HTTP... Presione Ctrl+C para detener.${NC}"
    tshark -Y "http" -T fields -e http.request.method -e http.request.uri -e http.host
}

# Guardar tráfico a archivo
save_traffic_to_file() {
    echo -e "${RED}Ingrese el nombre del archivo (ej. captura.pcap):${NC}"
    read filename
    echo -e "${GREEN}Guardando tráfico a $filename... Presione Ctrl+C para detener.${NC}"
    tshark -w $filename
}

# Analizar archivo de captura
analyze_capture_file() {
    echo -e "${RED}Ingrese el nombre del archivo de captura (ej. captura.pcap):${NC}"
    read filename
    echo -e "${GREEN}Analizando $filename...${NC}"
    tshark -r $filename
}

# Filtrar tráfico por puerto
filter_by_port() {
    echo -e "${RED}Ingrese el número de puerto (ej. 80, 443):${NC}"
    read port
    echo -e "${GREEN}Capturando tráfico del puerto $port... Presione Ctrl+C para detener.${NC}"
    tshark -Y "tcp.port == $port"
}

# Ejecución del menú
while true
do
    show_menu
    option=$(read_option)
    case $option in
        1) capture_from_interface ;;
        2) filter_by_protocol ;;
        3) capture_for_time ;;
        4) filter_by_ip ;;
        5) extract_http_info ;;
        6) save_traffic_to_file ;;
        7) analyze_capture_file ;;
        8) filter_by_port ;;
        9) echo -e "${GREEN}Saliendo...${NC}"; break ;;
        *) echo -e "${RED}Opción incorrecta. Intente de nuevo.${NC}" ;;
    esac
done
