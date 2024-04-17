# Ejemplos Avanzados de Uso de Nmap
### Por KernelPanicRD01

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

## 3. Detección de Sistema Operativo
Este escaneo intenta determinar el sistema operativo del host objetivo, junto con los servicios/versiones:

```bash
nmap -A [IP_o_Dominio]
```

## 4. Escaneo de Scripts
Nmap puede ejecutar diferentes scripts usando la opción -script. Este ejemplo utiliza scripts para buscar vulnerabilidades conocidas:

```bash
nmap --script=vuln [IP_o_Dominio]
```

## 5. Escaneo Agresivo
Un escaneo más agresivo que realiza detección de servicios, sistema operativo, traceroute y ejecuta scripts por defecto:

```bash
nmap -A -T4 [IP_o_Dominio]
```

## 6. Escaneo UDP
Los escaneos UDP pueden ser útiles para identificar servicios que no se detectan mediante escaneos TCP estándar:

```bash
nmap -sU [IP_o_Dominio]
```

## 7. Escaneo Stealth
Para realizar un escaneo más sigiloso que es menos probable que sea detectado por los sistemas de prevención de intrusos:

```bash
nmap -sS [IP_o_Dominio]
```

## 8. Escaneo de Subred
Para escanear múltiples hosts dentro de una subred:

```bash
nmap -sV -p 80,443 192.168.1.0/24
```

## 9. Escaneo de IPs desde un Archivo
Si tienes una lista de IPs en un archivo, puedes usar Nmap para escanear todas estas IPs:

```bash
nmap -iL lista-de-ips.txt
```

## 10. Guardar los Resultados en un Archivo
Para guardar los resultados de tu escaneo en un archivo, puedes usar:

```bash
nmap -oN salida.txt [IP_o_Dominio]
```

Estos comandos proporcionan una base sólida para realizar un reconocimiento efectivo utilizando Nmap. Modifica y combina estas opciones según las necesidades específicas de tu proyecto de pentesting.


