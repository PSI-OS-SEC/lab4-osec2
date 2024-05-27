#!/bin/bash

echo "El servidor FreeIPA debe tener acceso a Internet"
echo "debe poder descargar e instalar paquetes,"
echo "debe contar con todos los parches de seguridad aplicados en la fecha de calificacion,"
echo "debe tener una instalación funciona de FreeIA, con la convensión de nombres definida en cla"s
echo ""
echo "Al menos debe existir un cliente unido al dominio."





if [ ! $(id -n) -eq 0 ] 
then
 echo "Debe ejecutar este comando como root, desde su sevidor de IdM - FreeIPA"
 exit 1

fi


echo "Sever info"
dnf install -y tmux lsb_release && "Es posible instalar paquetes" || echo "Error Instalar paquetes" 
echo "Security Updates"
TEMP_FILE=$(mktemp)
dnf list updates --security -y|tee ${TEMP_FILE}
wc -l ${TEMP_FILE}
rm -f ${TEMP_FILE}
echo "NTP Server Using CHRONY"
chronyc -c sources && echo "Servidor de hora Configurado y Sincronizado" || echo "Error Servidor de Hora" 
echo "Server FQDN"
hostname -s
hostname -f
grep $(hostname -f) /etc/hosts && echo "FQDN configurado" || echo "Error FQDN"
echo "IdM Instalacion"
kinit admin && echo "Autentication IdM = OK" || echo "Auth Failed" && exit 1
ipa server-find|grep $(hostname -f) && echo "IdM server OK" || echo "Server Failed"
ipa server-show $(hostname -f)
ipa dnszone-find




