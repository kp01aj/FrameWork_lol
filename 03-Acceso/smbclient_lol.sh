#!/bin/bash
#
# L       OOO   L     !
# L      O   O  L     !
# L      O   O  L     !
# L      O   O  L      
# LLLLL   OOO   LLLLL !

# Creado por KernelPanicRD
# kp01aj@gmail.com
# https://discord.gg/VZ7PFx7C

#Descripción del Script
#Listar recursos compartidos disponibles: Permite ver todos los recursos compartidos disponibles en una dirección IP específica, utilizando una sesión anónima o de invitado.
#Conectarse a un recurso compartido: Inicia una sesión interactiva con un recurso compartido específico.
#Descargar un archivo de un recurso compartido: Facilita la descarga de archivos desde un recurso compartido.
#Subir un archivo a un recurso compartido: Permite subir archivos a un recurso compartido.
#Salir del script: Cierra el script.

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar el menú principal
show_menu() {
    echo -e "${GREEN}Menú Principal de smbclient 🖥️${NC}"
    echo -e "${YELLOW}1.${NC} Listar recursos compartidos disponibles"
    echo -e "${YELLOW}2.${NC} Conectarse a un recurso compartido"
    echo -e "${YELLOW}3.${NC} Descargar un archivo de un recurso compartido"
    echo -e "${YELLOW}4.${NC} Subir un archivo a un recurso compartido"
    echo -e "${YELLOW}5.${NC} Salir"
}

# Función para leer la opción del usuario
read_option() {
    local choice
    read -p "Ingrese la opción deseada [1 - 5]: " choice
    echo $choice
}

# Función para listar recursos compartidos disponibles
list_shares() {
    echo -e "${RED}Ingrese la dirección IP del servidor SMB:${NC}"
    read ip
    smbclient -L $ip -U guest
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función para conectarse a un recurso compartido
connect_share() {
    echo -e "${RED}Ingrese la dirección IP y el nombre del recurso compartido (ej. //192.168.1.10/share):${NC}"
    read share
    smbclient $share
}

# Función para descargar un archivo de un recurso compartido
download_file() {
    echo -e "${RED}Ingrese la dirección IP y el nombre del recurso compartido para la descarga (ej. //192.168.1.10/share):${NC}"
    read share
    echo -e "${RED}Ingrese el nombre del archivo a descargar:${NC}"
    read filename
    smbclient $share -c "get $filename"
    echo -e "${GREEN}Archivo descargado: $filename${NC}"
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función para subir un archivo a un recurso compartido
upload_file() {
    echo -e "${RED}Ingrese la dirección IP y el nombre del recurso compartido para la carga (ej. //192.168.1.10/share):${NC}"
    read share
    echo -e "${RED}Ingrese el nombre del archivo a subir:${NC}"
    read filename
    smbclient $share -c "put $filename"
    echo -e "${GREEN}Archivo subido: $filename${NC}"
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
            list_shares
            ;;
        2)
            connect_share
            ;;
        3)
            download_file
            ;;
        4)
            upload_file
            ;;
        5)
            echo -e "${GREEN}Saliendo...${NC}"
            break
            ;;
        *)
            echo -e "${RED}Opción incorrecta. Intente de nuevo.${NC}"
            ;;
    esac
done
