#!/bin/bash
LANG=en_US.UTF-8
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
dnf install -y tmux && echo "Install packages [OK]" || echo "Install [FAILED]"
echo "Security Updates"
TEMP_FILE=$(mktemp)
dnf clean all -y
dnf list updates --security -y|tee ${TEMP_FILE}
COUNT=$(wc -l ${TEMP_FILE}|cut -d" " -f1)

rm -f ${TEMP_FILE}
echo "NTP Server Using CHRONY"
chronyc -c sources && echo "Chrony [OK]" || echo "Chrony [FAILED]"
echo "Server FQDN"
hostname -s
hostname -f
grep $(hostname -f) /etc/hosts && echo "FQDN [OK]" || echo "FQDN [FAILED]"
echo "IdM Instalacion"
echo "Utilizando usuario admin@${CARNET}testlabs.info"
klist || kinit admin
if [ $? -eq 0 ]
then
  echo "Auth [OK]"
  ipa server-find|grep $(hostname -f) && echo "Server [OK]" || echo "Server [FAILED]"
  ipa server-show $(hostname -f)
  echo "IdM Domains"
  ipa dnszone-find |grep 'Zone name'
  echo "IdM Zone"
  ipa dnszone-show ${CARNET}testlabs.info|grep 'Zone name' && echo "Zone [OK]" || echo "Zone [FAILED]"
  echo "IdM Clients"
  CLIENTS=$(ipa host-find|grep 'Host name')
cat << EOF
${CLIENTS}
EOF
  C_CLIENTS=$(echo "${CLIENTS}"|wc -l)
  test ${C_CLIENTS} -gt 1 && echo "Clients [OK]" || echo "Clients [FAILED]"
  echo ""
  echo ""
else
 echo "Auth [FAILED]"
fi

cat lab.sha256
sha256sum lab.sh
