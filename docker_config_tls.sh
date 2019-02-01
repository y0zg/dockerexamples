#!/usr/bin/env bash

: ' Script that enables TLS for Docker service in Ubuntu 16.x
    This script is intended to be run as root
    It;
    - Generates the keys
    - Creates the daemon.json Docker config file
    - Reconfigures docker systemctl
    - Reloads systemctl and restarts Docker service
    More information: https://docs.docker.com/engine/security/https/#secure-by-default
    To remove all created files execute (considering default Docker key store folder);
    rm -rf /root/.docker/ /etc/systemd/system/docker.service.d/ /etc/docker/daemon.json /etc/docker/certs/
    '

# check if debug flag is set
if [ "${DEBUG}" = true ]; then

  set -x # enable print commands and their arguments as they are executed.
  export # show all declared variables (includes system variables)
  whoami # print current user

else

  # unset if flag is not set
  unset DEBUG

fi

# bash default parameters
set -o errexit  # make your script exit when a command fails
set -o pipefail # exit status of the last command that threw a non-zero exit code is returned
set -o nounset  # exit when your script tries to use undeclared variables

# parameters
__external_ip="${1:-"200.200.200.200"}"
__company_name="${2:-"My Company Inc"}"
__country_code="${3:-"US"}"
__certificate_password="${4:-"password"}"
__docker_keystore_folder="${5:-"/etc/docker/certs"}"

# binaries
__CAT=$(which cat)
__CHMOD=$(which chmod)
__DOCKER=$(which docker)
__LN=$(which ln)
__MKDIR=$(which mkdir)
__OPENSSL=$(which openssl)
__RM=$(which rm)
__SERVICE=$(which service)
__SYSTEMCTL=$(which systemctl)

# create Docker keystore folder
${__MKDIR} --parents "${__docker_keystore_folder}"

# create CA key
${__OPENSSL} genrsa -aes256 \
                    -out "${__docker_keystore_folder}/ca-key.pem" \
                    -passout pass:"${__certificate_password}" \
                    4096

# create CA certificate
${__OPENSSL} req -new \
                 -x509 \
                 -days 365 \
                 -key "${__docker_keystore_folder}/ca-key.pem" \
                 -subj "/CN=${__external_ip}/O=${__company_name}/C=${__country_code}" \
                 -passin pass:"${__certificate_password}" \
                 -sha256 \
                 -out "${__docker_keystore_folder}/ca.pem"

# create server key
${__OPENSSL} genrsa -out "${__docker_keystore_folder}/server-key.pem" 4096

# create serer certificate request
${__OPENSSL} req -subj "/CN=${__external_ip}" \
                 -sha256 \
                 -new \
                 -key "${__docker_keystore_folder}/server-key.pem" \
                 -out "${__docker_keystore_folder}/server.csr"

# create the extfile.cnf with server info
${__CAT} <<EOF > "${__docker_keystore_folder}/extfile.cnf"
subjectAltName = DNS:localhost,IP:${__external_ip},IP:127.0.0.1
extendedKeyUsage = serverAuth
EOF

# create server certificate
${__OPENSSL} x509 -req \
                  -days 365 \
                  -sha256 \
                  -in "${__docker_keystore_folder}/server.csr" \
                  -CA "${__docker_keystore_folder}/ca.pem" \
                  -CAkey "${__docker_keystore_folder}/ca-key.pem" \
                  -CAcreateserial \
                  -passin pass:"${__certificate_password}" \
                  -out "${__docker_keystore_folder}/server-cert.pem" \
                  -extfile "${__docker_keystore_folder}/extfile.cnf"

# create server key
${__OPENSSL} genrsa -out "${__docker_keystore_folder}/key.pem" 4096

# create client certificate request
${__OPENSSL} req -subj '/CN=client' \
                 -new \
                 -key "${__docker_keystore_folder}/key.pem" \
                 -out "${__docker_keystore_folder}/client.csr"

# add client info to extfile.cnf
echo extendedKeyUsage = clientAuth >> "${__docker_keystore_folder}/extfile.cnf"

# create client certificate
${__OPENSSL} x509 -req \
                  -days 365 \
                  -sha256 \
                  -in "${__docker_keystore_folder}/client.csr" \
                  -CA "${__docker_keystore_folder}/ca.pem" \
                  -CAkey "${__docker_keystore_folder}/ca-key.pem" \
                  -CAcreateserial \
                  -passin pass:"${__certificate_password}" \
                  -out "${__docker_keystore_folder}/cert.pem" \
                  -extfile "${__docker_keystore_folder}/extfile.cnf"

# delete certificate requests
${__RM} "${__docker_keystore_folder}/client.csr" "${__docker_keystore_folder}/server.csr"

# set correct permissions
${__CHMOD} 0400 "${__docker_keystore_folder}/ca-key.pem" "${__docker_keystore_folder}/key.pem" "${__docker_keystore_folder}/server-key.pem"
${__CHMOD} 0444 "${__docker_keystore_folder}/ca.pem" "${__docker_keystore_folder}/server-cert.pem" "${__docker_keystore_folder}/cert.pem"

# create .docker folder and link certs/keys
${__MKDIR} --parents /root/.docker
${__LN} --symbolic "${__docker_keystore_folder}/"{ca,cert,key}.pem /root/.docker/

# create folder for Docker service and configure Docker systemctl
${__MKDIR} --parents /etc/systemd/system/docker.service.d/

cat <<EOF > /etc/systemd/system/docker.service.d/docker.conf
[Service]
ExecStart=
ExecStart=$(which dockerd)
EOF

# configure Docker daemon
cat <<EOF > /etc/docker/daemon.json
{
  "tlsverify": true,
  "tlscacert": "${__docker_keystore_folder}/ca.pem",
  "tlscert": "${__docker_keystore_folder}/server-cert.pem",
  "tlskey": "${__docker_keystore_folder}/server-key.pem",
  "hosts": ["tcp://0.0.0.0:2376", "unix:///var/run/docker.sock"]
}
EOF

# reload systemctl and Docker service
${__SYSTEMCTL} daemon-reload
${__SERVICE} docker restart

# verify Docker service with TLS
${__DOCKER} --tlsverify \
            --tlscacert="${__docker_keystore_folder}/ca.pem" \
            --tlscert="${__docker_keystore_folder}/cert.pem" \
            --tlskey="${__docker_keystore_folder}/key.pem" \
            -H=127.0.0.1:2376 \
            version
