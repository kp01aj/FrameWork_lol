#Realizar scan y busca vuln.
nmap -sV -p - -T4 -O -A -v -Pn --open --script address-info,afp-serverinfo,vuln $1
