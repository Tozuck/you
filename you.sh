#!/bin/bash

echo_info() {
  echo -e "\033[1;32m[INFO]\033[0m $1"
}
echo_error() {
  echo -e "\033[1;31m[ERROR]\033[0m $1"
  exit 1
}

apt-get update; apt-get install curl socat git nload -y

if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sh || echo_error "Docker installation failed."
else
  echo_info "Docker is already installed."
fi

rm -r Marzban-node

git clone https://github.com/Gozargah/Marzban-node

rm -r /var/lib/marzban-node

mkdir /var/lib/marzban-node

rm ~/Marzban-node/docker-compose.yml

cat <<EOL > ~/Marzban-node/docker-compose.yml
services:
  marzban-node:
    image: gozargah/marzban-node:v0.4.1
    restart: always
    network_mode: host
    environment:
      SSL_CERT_FILE: "/var/lib/marzban-node/ssl_cert.pem"
      SSL_KEY_FILE: "/var/lib/marzban-node/ssl_key.pem"
      SSL_CLIENT_CERT_FILE: "/var/lib/marzban-node/ssl_client_cert.pem"
      SERVICE_PROTOCOL: "rest"
    volumes:
      - /var/lib/marzban-node:/var/lib/marzban-node
EOL

rm /var/lib/marzban-node/ssl_client_cert.pem

cat <<EOL > /var/lib/marzban-node/ssl_client_cert.pem
-----BEGIN CERTIFICATE-----
MIIEnDCCAoQCAQAwDQYJKoZIhvcNAQENBQAwEzERMA8GA1UEAwwIR296YXJnYWgw
IBcNMjUwMzI5MTEyODM0WhgPMjEyNTAzMDUxMTI4MzRaMBMxETAPBgNVBAMMCEdv
emFyZ2FoMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA0pbrSDiXdhB6
dIAeaeB+2B+XoOFCNKtUYEidbH4rpoIGyMa6ANO/1OB5bQvS72tTHrJnJdd/5rsy
RbVc7qgbQyMIVBQjPg1S/98bUP3oFNS4WTAePp/N3Wh7xiX3C6Lyf7xVDfricO9y
prOO78nBMqlL85qkBpIAXjiwA8IaL9GQAqLrUAnjAsDwS1BfET0ZIq03danLtSkb
C4kg4NLmh1fI++AhZaiHiLpRlCv/caazlps5P/qzgGcr/SOVmW6i6AtKZ2NPbsfm
Gu3PTtH+8Khg/kPadu81E4cX3BDjdnsYm2oVx5EL6Rw/r47tW9Zgn9n9CY2s/gOK
iATurAaSRfzCUP9Af5GMoiQbo5O3MHEMdyeF/26Vxr93QH33QNUFRATbdcGLkpZl
fmhpDkaJ+pZf+mkinC9J8V2HltOBhiXpczxHcBofqSpRuWZtkFLWgC9krkB9RtDF
y2GY7YopbATEPiB/Qbn4vhudWznZn3oGtPghvPnbFrvRbxbAkyxKaBbNzrggIOki
YSXmx/Uc5V5WULUePrs1P+l+i/2rqe8Mxzed3skPOrWr3SLgZEt5qJ9hW8fSXr3H
CgJv2Nspc8Zkd0zxRvyxBqZFhWNlxiROYIS1ub+qPPFVohcE7XYKrvxn/kQg61HK
8zTok4NlxHh2p8qcDIekZkvbkBvnnu0CAwEAATANBgkqhkiG9w0BAQ0FAAOCAgEA
UwA4Wa++etyhdvlNtJEc1OWdWYjzXCHOkOoWgtsGQsFFtVWHlioahwydAOB+1ETR
lY+l7bAVoLyzM7NdUWLaiaUxM66ZjxA8xDzn4zNZf/dTqVz2wfjmZQgn4RA6FL56
CtkfAKlCRDXnJe57l/b4FCNKxNBnX7v78ncrcFqqfbxNucqsMVKZf05jBwwzc5Go
HNrefFrZ7RtjyFciyeybGc6v7pSAGPiMK27nzSE8Ty/Aej/V8Gv+sJmOqUp5BMgy
LT4jsrDjNpYy9yh28c1XDuNWJRpZyEeGWeckSLGJSItHJictLn6F/7NuGIMu+LJf
30oiB5WKMzF8IoYry7aeK//R7JannzsZbNeXBQdBY2tIxaUYycJfQjVs1X28dAM1
a0U0MP81NAwHyMxbvufLqfzyoe61Z3wp3XIfRkF+tEVPkdbW8SyDsqDJAiijGDry
R3KloN1x6ArlqxmreFukRabYiYlk6KfQdNe/qCEHGBBM+ydJc+ggeVYU0BQZMz5/
NoAX49K+uQP15X5KdXRDw2uhSxbl9LHsbS+hvsHb5uaSxIUqFcWwic3Qzm8+whLX
YuVokv9cAvMPetuuYGQTeCRk6/eOYyft0XDjZCqISM82scpIt9yIeYiJAaddmxpb
ft9UDqizX7oSOkHd16EvoIwpWoLEIwDE3X5AFp4pUiQ=
-----END CERTIFICATE-----
EOL

cd ~/Marzban-node
docker compose up -d

echo_info "Finalizing UFW setup..."

ufw allow 22
ufw allow 80
ufw allow 2096
ufw allow 2053
ufw allow 62050
ufw allow 62051

ufw --force enable
ufw reload
