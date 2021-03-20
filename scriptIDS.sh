#!/bin/bash
# Almacenar la fecha y hora para el log
fecha=`date +"%d/%m/%Y"-"%H:%M":`

# Crear una variable de control para registrar si se ha encontrado un intruso
control=0

# Ejecutar nmap para que guarde un mapa de la red en un archivo que luego se borra
nmap -sP 192.168.1.1-255 > /root/Escritorio/INTRUSOS/mapa.tmp

# Leer el mapa de red, aislar las MAC y buscar las MAC que no estén en el listado de MACS permitidas
for intruso in $(cat /root/Escritorio/INTRUSOS/mapa.tmp | grep "MAC" | awk '{ print $3 }' |
grep -v -f /root/Escritorio/INTRUSOS/MACS.txt);
do
# Si entra en el bucle FOR es porque ha encontrado una MAC que no está en el listado de MACS..

# Poner la variable de control a 1
control=1

# Buscar la IP dentro del mapa realizado por nmap
ip_intruso=$(cat /root/Escritorio/INTRUSOS/mapa.tmp | grep -B 2 "$intruso" | grep "for" | awk '{ print $5 }')

# Crear la entrada en el registro y realizar un analisis del intruso
echo "---------------------------------------------------------------" >>/root/Escritorio/INTRUSOS/intrusos.log
echo "$fecha Equipo No Registrado: $intruso - IP: $ip_intruso" >> /root/Escritorio/INTRUSOS/intrusos.log
nmap -sS -sV -O $ip_intruso >>/root/Escritorio/INTRUSOS/intrusos.log
echo "---------------------------------------------------------------" >> /root/Escritorio/INTRUSOS/intrusos.log
done

# Si se ha encontado un intruso, enviar el fichero de log por mail
if [ $control -eq 1 ];
then
cat /root/Escritorio/INTRUSOS/intrusos.log | mail -s "$fecha equipo no registrado en la
red" tucorreo@gmail.com
fi

# Borrar el fichero temporal del mapa
rm /root/Escritorio/INTRUSOS/mapa.tmp
exit
 
