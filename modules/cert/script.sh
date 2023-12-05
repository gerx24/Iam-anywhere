#!/bin/bash


SERVER="${SERVER:-private}"

CORPORATION=ELC
GROUP="Platform Engineering"
CITY="New York"
STATE="NY"
COUNTRY=US

CERT_AUTH_PASS=`openssl rand -base64 32`
echo $CERT_AUTH_PASS > cert_auth_password
CERT_AUTH_PASS=`cat cert_auth_password`


cat -<<EOF > config.cnf
[ req ]
distinguished_name	= req_distinguished_name
attributes		= req_attributes

[ req_distinguished_name ]
countryName			= Country Name (2 letter code)
countryName_min			= 2
countryName_max			= 2
stateOrProvinceName		= State or Province Name (full name)
localityName			= Locality Name (eg, city)
0.organizationName		= Organization Name (eg, company)
organizationalUnitName		= Organizational Unit Name (eg, section)
commonName			= Common Name (eg, fully qualified host name)
commonName_max			= 64
emailAddress			= Email Address
emailAddress_max		= 64

[ req_attributes ]
challengePassword		= A challenge password
challengePassword_min		= 4
challengePassword_max		= 20

[ v3_ca ]
basicConstraints        = critical, CA:TRUE
subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid:always, issuer:always
keyUsage                = critical, cRLSign, digitalSignature, keyCertSign

[SAN]
subjectAltName=DNS:$SERVER"
EOF

echo "Create the certificate authority .pem and .key"
openssl genrsa -out PrivateCA.key 4096
openssl \
  req \
  -subj "/CN=$SERVER.ca/OU=$GROUP/O=$CORPORATION/L=$CITY/ST=$STATE/C=$COUNTRY" \
  -new \
  -x509 \
  -passout pass:$CERT_AUTH_PASS \
  -key PrivateCA.key \
  -out PrivateCA.pem \
  -config config.cnf \
  -extensions v3_ca \
  -days 36500

echo "Client certificate key"
openssl genrsa -out client_private.key 4096

echo "Generate Certificate Signing Request"
openssl req -new -key client_private.key -out client.csr -subj "/CN=$SERVER.ca/OU=$GROUP/O=$CORPORATION/L=$CITY/ST=$STATE/C=$COUNTRY"

cat -<<EOF > client.ext
basicConstraints = CA:FALSE
authorityKeyIdentifier = keyid,issuer
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
EOF

echo "Generate Client.pem certificate"
openssl x509 \
  -req \
  -subj "/CN=$SERVER.ca/OU=$GROUP/O=$CORPORATION/L=$CITY/ST=$STATE/C=$COUNTRY" \
  -in client.csr \
  -CA PrivateCA.pem \
  -CAkey PrivateCA.key \
  -CAcreateserial \
  -out client.pem \
  -days 3650 \
  -sha256  \
  -extfile client.ext
