#!/bin/bash
# Helper script to generate self-signed TLS certificates for Wisecow
DOMAIN="wisecow.local"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout tls.key -out tls.crt \
    -subj "/CN=${DOMAIN}/O=wisecow"

kubectl create secret tls wisecow-tls-secret --key tls.key --cert tls.crt
