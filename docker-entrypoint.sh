#!/usr/bin/env bash

for FILENAME in `find /usr/local/freeswitch -type f -iname 'vars.xml'`
do
  sed -i "s|default_password=1234|default_password=${FS_DEFAULT_SIP_PASSWORD}|g" ${FILENAME}
  sed -i "s|internal_sip_port=5060|internal_sip_port=${FS_INTERNAL_SIP_PORT}|g" ${FILENAME}
  sed -i "s|internal_tls_port=5061|internal_tls_port=${FS_INTERNAL_TLS_PORT}|g" ${FILENAME}
  sed -i "s|external_sip_port=5080|external_sip_port=${FS_EXTERNAL_SIP_PORT}|g" ${FILENAME}
  sed -i "s|external_tls_port=5081|external_tls_port=${FS_EXTERNAL_TLS_PORT}|g" ${FILENAME}
  sed -i "s|domain=$${local_ip_v4}|domain=${FS_DOMAIN}|g" ${FILENAME}
  sed -i "s|<X-PRE-PROCESS cmd=\"stun-set\" data=\"external_rtp_ip=stun:stun.freeswitch.org\"/>|<X-PRE-PROCESS cmd=\"set\" data=\"external_rtp_ip=${FS_EXT_IP}\"/>|g" ${FILENAME}
  sed -i "s|<X-PRE-PROCESS cmd=\"stun-set\" data=\"external_sip_ip=stun:stun.freeswitch.org\"/>|<X-PRE-PROCESS cmd=\"set\" data=\"external_sip_ip=${FS_EXT_IP}\"/>|g" ${FILENAME}
  # echo "<X-PRE-PROCESS cmd=\"set\" data=\"certs_dir=/usr/local/freeswitch/tls\"/>" >> ${FILENAME}
done

for FILENAME in `find /usr/local/freeswitch -type f -iname 'event_socket.conf.xml'`
do
  sed -i "s|::|${FS_ESL_IP}|g" ${FILENAME}
  sed -i "s|ClueCon|${FS_ESL_PASSWORD}|g" ${FILENAME}
  sed -i "s|8021|${FS_ESL_PORT}|g" ${FILENAME}
done

for FILENAME in `find /usr/local/freeswitch -type f -iname 'internal.xml'`
do
  sed -i "s|:5066|:${FS_WS_PORT}|g" ${FILENAME}
  sed -i "s|:7443|:${FS_WSS_PORT}|g" ${FILENAME}
done

for FILENAME in `find /usr/local/freeswitch -type f -iname 'switch.conf.xml'`
do
  sed -i "s|<!-- <param name=\"rtp-start-port\" value=\"16384\"/> -->|<param name=\"rtp-start-port\" value=\"${FS_RTP_START_PORT}\"/>|g" ${FILENAME}
  sed -i "s|<!-- <param name=\"rtp-end-port\" value=\"32768\"/> -->|<param name=\"rtp-end-port\" value=\"${FS_RTP_END_PORT}\"/>|g" ${FILENAME}
done

for FILENAME in `find /usr/local/freeswitch -type f -iname '*ipv6.xml'`
do
  rm ${FILENAME}
done

exec "$@"