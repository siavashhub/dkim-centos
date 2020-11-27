#!/bin/bash
# Script to create dkim public/private key

domain=$1

egrep "^default._domainkey.${domain}" /etc/opendkim/KeyTable >/dev/null
if [ $? -eq 0 ]; then
  if [ -d "/etc/opendkim/keys/${domain}" ]; then
    rm -rf /etc/opendkim/keys/${domain}
  fi
  
  /bin/cp -f /etc/opendkim/KeyTable /etc/opendkim/KeyTable.thu.bak
  sed "/${domain}/d" /etc/opendkim/KeyTable > /etc/opendkim/KeyTable.thu
  /bin/cp -f /etc/opendkim/KeyTable.thu /etc/opendkim/KeyTable

  /bin/cp -f /etc/opendkim/SigningTable /etc/opendkim/SigningTable.thu.bak
  sed "/${domain}/d" /etc/opendkim/SigningTable > /etc/opendkim/SigningTable.thu
  /bin/cp -f /etc/opendkim/SigningTable.thu /etc/opendkim/SigningTable

  systemctl restart opendkim
  echo "DKIMv1 configuration of ${domain} removed!"
else
  echo "DKIMv1 configuration of ${domain} not found!"
fi



