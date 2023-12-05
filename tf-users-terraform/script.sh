#!/bin/bash

SERVER="${SERVER:-client}"

OUTPUT_PATH=${OUTPUT_PATH:-certificates}
mkdir -p $OUTPUT_PATH

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

if [[ -z "$(cat $OUTPUT_PATH/PrivateCA.pem)" ]]; then
  echo "Create the certificate authority"
  openssl genrsa -out $OUTPUT_PATH/PrivateCA.key 4096
  openssl \
    req \
    -subj "/CN=$SERVER.ca/OU=$GROUP/O=$CORPORATION/L=$CITY/ST=$STATE/C=$COUNTRY" \
    -new \
    -x509 \
    -passout pass:$CERT_AUTH_PASS \
    -key $OUTPUT_PATH/PrivateCA.key \
    -out $OUTPUT_PATH/PrivateCA.pem \
    -config config.cnf \
    -extensions v3_ca \
    -days 36500
fi

echo "Create client private key (used to decrypt the cert we get from the CA)"
openssl genrsa -out $OUTPUT_PATH/$SERVER.key 4096

cat -<<EOF > client.ext
basicConstraints = CA:FALSE
authorityKeyIdentifier = keyid,issuer
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
EOF

echo "Create the CSR(Certitificate Signing Request)"

openssl req -new -key $OUTPUT_PATH/$SERVER.key -out $SERVER.csr -nodes \
  -subj "/CN=$SERVER/OU=$GROUP/O=$CORPORATION/L=$CITY/ST=$STATE/C=$COUNTRY" \
  -sha256

echo "Sign the certificate with the certificate authority"
openssl x509 -req -in $SERVER.csr -CA $OUTPUT_PATH/PrivateCA.pem -CAkey $OUTPUT_PATH/PrivateCA.key -CAcreateserial -out $OUTPUT_PATH/$SERVER.pem \
  -days 36500 \
  -extfile client.ext \
  -passin pass:$CERT_AUTH_PASS
