#!/bin/bash

echo "El servidor FreeIPA debe tener acceso a Internet"
echo "debe poder descargar e instalar paquetes,"
echo "debe contar con todos los parches de seguridad aplicados en la fecha de calificacion,"
echo "debe tener una instalación funciona de FreeIA, con la convensión de nombres definida en cla"s
echo ""
echo "Al menos debe existir un cliente unido al dominio."


read -p "# Carnet: " CARNET
if [ -z "$CARNET" ]
then
  CARNET=""
fi



if [ ! $(id -u) -eq 0 ] 
then
 echo "Debe ejecutar este comando como root, desde su sevidor de IdM - FreeIPA"
 exit 1

fi
echo "------------------------------------"


echo "Server info"
dnf install -y tmux lsb_release && echo "Install packages [OK]" || echo "Install [FAILED]" 
echo "Security Updates"
TEMP_FILE=$(mktemp)
dnf clean all -y
dnf list updates --security -y|tee ${TEMP_FILE}
COUNT=$(wc -l ${TEMP_FILE}|cut -d" " -f1)
[ $COUNT -gt 2 ] && echo "Secutiry Updates [OK]" || echo "Secutiry Updates [FAILED]" 
rm -f ${TEMP_FILE}
echo "NTP Server Using CHRONY"
chronyc -c sources && echo "Chrony [OK]" || echo "Chrony [FAILED]"
echo "Server FQDN"
hostname -s
hostname -f
grep $(hostname -f) /etc/hosts && echo "FQDN [OK]" || echo "FQDN [FAILED]" 
echo "IdM Instalacion"
kinit admin 
if [ $? -eq 0 ]
then
  echo "Auth [OK]" 
  ipa server-find|grep $(hostname -f) && echo "Server [OK]" || echo "Server [FAILED]" 
  ipa server-show $(hostname -f)
  echo "IdM Domains"
  ipa dnszone-find
  echo "IdM Clients"
  ipa host-find
  ipa dnszone-show ${CARNET}testlabs.info && echo "Zone [OK]" || echo "Zone [FAILED]"
else
 echo "Auth [FAILED]"
fi





