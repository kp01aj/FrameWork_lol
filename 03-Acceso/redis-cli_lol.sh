#!/bin/bash
#
# L       OOO   L     !
# L      O   O  L     !
# L      O   O  L     !
# L      O   O  L      
# LLLLL   OOO   LLLLL !

# Creado por KernelPanicRD01
# kp01aj@gmail.com
# https://discord.gg/VZ7PFx7C

# Un script de Bash que incluye varias opciones útiles utilizando redis-cli:

#Descripción de las opciones del script:
# Conectar a Redis: Permite conectar a una instancia de Redis especificando host y puerto.
# Listar todas las claves: Muestra todas las claves almacenadas en la base de datos Redis.
# Leer valor de una clave: Obtiene el valor de una clave específica.
# Establecer valor de una clave: Permite asignar un valor a una clave específica.
# Eliminar una clave: Elimina una clave y su valor asociado.
# Publicar un mensaje en un canal: Envía un mensaje a un canal, útil para funcionalidades de pub/sub.
# Suscribirse a un canal: Se suscribe a un canal para recibir mensajes.
# Ejecutar un comando RAW: Permite ejecutar cualquier comando de Redis directamente.

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar el menú principal
show_menu() {
    echo -e "${GREEN}Menú Principal de Redis CLI para Gestión de Bases de Datos Redis 🗄️${NC}"
    echo -e "${YELLOW}1.${NC} Conectar a una instancia de Redis"
    echo -e "${YELLOW}2.${NC} Listar todas las claves"
    echo -e "${YELLOW}3.${NC} Leer valor de una clave"
    echo -e "${YELLOW}4.${NC} Establecer valor de una clave"
    echo -e "${YELLOW}5.${NC} Eliminar una clave"
    echo -e "${YELLOW}6.${NC} Publicar un mensaje en un canal"
    echo -e "${YELLOW}7.${NC} Suscribirse a un canal"
    echo -e "${YELLOW}8.${NC} Ejecutar un comando RAW"
    echo -e "${YELLOW}9.${NC} Salir"
}

# Función para leer la opción del usuario
read_option() {
    local choice
    read -p "Ingrese la opción deseada [1 - 9]: " choice
    echo $choice
}

# Función para conectar a Redis
connect_redis() {
    echo -e "${RED}Ingrese la dirección del servidor Redis (ej. localhost):${NC}"
    read host
    echo -e "${RED}Ingrese el puerto (default 6379):${NC}"
    read port
    redis-cli -h $host -p ${port:-6379}
}

# Función para listar todas las claves
list_keys() {
    echo -e "${GREEN}Listando todas las claves...${NC}"
    redis-cli KEYS '*'
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función para leer valor de una clave
read_key() {
    echo -e "${RED}Ingrese la clave cuyo valor desea leer:${NC}"
    read key
    redis-cli GET $key
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función para establecer valor de una clave
set_key() {
    echo -e "${RED}Ingrese la clave a establecer:${NC}"
    read key
    echo -e "${RED}Ingrese el valor de la clave:${NC}"
    read value
    redis-cli SET $key $value
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función para eliminar una clave
delete_key() {
    echo -e "${RED}Ingrese la clave que desea eliminar:${NC}"
    read key
    redis-cli DEL $key
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función para publicar un mensaje en un canal
publish_message() {
    echo -e "${RED}Ingrese el canal en el que desea publicar:${NC}"
    read channel
    echo -e "${RED}Ingrese el mensaje:${NC}"
    read message
    redis-cli PUBLISH $channel "$message"
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Función para suscribirse a un canal
subscribe_channel() {
    echo -e "${RED}Ingrese el canal al que desea suscribirse:${NC}"
    read channel
    echo -e "${GREEN}Suscribiéndose al canal $channel. Presione Ctrl+C para detener la suscripción.${NC}"
    redis-cli SUBSCRIBE $channel
}

# Función para ejecutar un comando RAW en Redis
execute_raw() {
    echo -e "${RED}Ingrese el comando de Redis a ejecutar (ej. INFO, CONFIG GET *):${NC}"
    read command
    redis-cli $command
    echo -e "${BLUE}Presione <Enter> para continuar${NC}"
    read
}

# Ejecución del menú
while true
do
    show_menu
    option=$(read_option)
    case $option in
        1) connect_redis ;;
        2) list_keys ;;
        3) read_key ;;
        4) set_key ;;
        5) delete_key ;;
        6) publish_message ;;
        7) subscribe_channel ;;
        8) execute_raw ;;
        9) echo -e "${GREEN}Saliendo...${NC}"; break ;;
        *) echo -e "${RED}Opción incorrecta. Intente de nuevo.${NC}" ;;
    esac
done
