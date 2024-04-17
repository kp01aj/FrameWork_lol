# Ejemplos Avanzados de Uso de Nmap

Nmap (Network Mapper) es una herramienta esencial para el reconocimiento en pentesting. A continuación, se presentan algunos ejemplos avanzados de cómo utilizar Nmap para diferentes propósitos de reconocimiento:

## 1. Escaneo de Puertos Completo

Este comando realiza un escaneo completo de todos los 65535 puertos de una dirección IP o dominio:

```bash
nmap -p- -v [IP_o_Dominio]
```

## 2. Detección de Servicios y Versión
Para identificar los servicios que se ejecutan en los puertos abiertos y determinar sus versiones:

```bash
nmap -sV [IP_o_Dominio]
```

