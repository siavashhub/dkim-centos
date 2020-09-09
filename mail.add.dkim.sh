#!/bin/bash
# Script to create dkim public/private key

domain=$1

egrep "^default._domainkey.${domain}" /etc/opendkim/KeyTable >/dev/null
if [ ! $? -eq 0 ]; then
  if [ ! -d "/etc/opendkim/keys/${domain}" ]; then
    mkdir /etc/opendkim/keys/${domain}
  else
    rm -rf /etc/opendkim/keys/${domain}
    mkdir /etc/opendkim/keys/${domain}
  fi

  opendkim-genkey -D /etc/opendkim/keys/${domain} -d ${domain} -s default
  chown opendkim:root --recursive /etc/opendkim/keys
  
  echo "default._domainkey.${domain} ${domain}:default:/etc/opendkim/keys/${domain}/default.private" >> /etc/opendkim/KeyTable
  echo "*@${domain} default._domainkey.${domain}" >> /etc/opendkim/SigningTable
  
  systemctl restart opendkim
  PUBLICRECORD=`cat /etc/opendkim/keys/${domain}/default.txt | sed -n '1!p' | sed 's/^.*p=//' | sed 's/\" ).*//'`
  echo ${PUBLICRECORD}
fi