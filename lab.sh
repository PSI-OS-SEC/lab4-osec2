#!/bin/bash
LANG=en_US.UTF-8

# Definir colores
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # Sin color (reset)

echo "El servidor FreeIPA debe tener acceso a Internet"
echo "debe poder descargar e instalar paquetes,"
echo "debe contar con todos los parches de seguridad aplicados en la fecha de calificacion,"
echo "debe tener una instalación funciona de FreeIA, con la convensión de nombres definida en cla"s
echo ""
echo "Al menos debe existir un cliente unido al dominio."

read -p "# Carnet: " CARNET
if [ -z "$CARNET" ]; then
  CARNET=""
fi

if [ ! $(id -u) -eq 0 ]; then
  echo -e "${RED}Debe ejecutar este comando como root, desde su servidor de IdM - FreeIPA${NC}"
  exit 1
fi

echo "------------------------------------"

echo "Server info"
dnf install -y tmux && echo -e "Install packages [${GREEN}OK${NC}]" || echo -e "Install packages [${RED}FAILED${NC}]"

echo "Security Updates"
TEMP_FILE=$(mktemp)
dnf clean all -y
dnf list updates --security -y | tee ${TEMP_FILE}
COUNT=$(wc -l < ${TEMP_FILE})
rm -f ${TEMP_FILE}

echo "NTP Server Using CHRONY"
chronyc -c sources && echo -e "Chrony [${GREEN}OK${NC}]" || echo -e "Chrony [${RED}FAILED${NC}]"

echo "Server FQDN"
hostname -s
hostname -f
grep $(hostname -f) /etc/hosts && echo -e "FQDN [${GREEN}OK${NC}]" || echo -e "FQDN [${RED}FAILED${NC}]"

echo "IdM Instalacion"
echo "Utilizando usuario admin@${CARNET}testlabs.info"
klist || kinit admin
if [ $? -eq 0 ]; then
  echo -e "Auth [${GREEN}OK${NC}]"
  ipa server-find | grep $(hostname -f) && echo -e "Server [${GREEN}OK${NC}]" || echo -e "Server [${RED}FAILED${NC}]"
  ipa server-show $(hostname -f)
  echo "IdM Domains"
  ipa dnszone-find | grep 'Zone name'
  echo "IdM Zone"
  ipa dnszone-show ${CARNET}testlabs.info | grep 'Zone name' && echo -e "Zone [${GREEN}OK${NC}]" || echo -e "Zone [${RED}FAILED${NC}]"
  echo "IdM Clients"
  CLIENTS=$(ipa host-find | grep 'Host name')
cat << EOF
${CLIENTS}
EOF
  C_CLIENTS=$(echo "${CLIENTS}" | wc -l)
  test ${C_CLIENTS} -gt 1 && echo -e "Clients [${GREEN}OK${NC}]" || echo -e "Clients [${RED}FAILED${NC}]"
  echo ""
  echo ""
else
  echo -e "Auth [${RED}FAILED${NC}]"
fi

cat lab.sha256
sha256sum lab.sh
