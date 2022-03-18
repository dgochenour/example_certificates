export OPENSSL_EXE=openssl
export OPENSSL_CONF=./input/openssl.cnf
rm *.xml
rm *.csr
rm *.pem
rm *.p7s
rm demoCA/*
rm demoCA/private/*
rm -rf ./output

mkdir output && \
mkdir -p 'demoCA' && \
mkdir -p 'demoCA/private' && \
$OPENSSL_EXE genrsa -out demoCA/private/cakey.pem 2048 && \
$OPENSSL_EXE req -new -key demoCA/private/cakey.pem -out ca.csr -config input/openssl.cnf && \
$OPENSSL_EXE x509 -req -days 3650 -in ca.csr -signkey demoCA/private/cakey.pem -out demoCA/cacert.pem && \
mkdir -p 'demoCA/newcerts' && \
touch demoCA/index.txt && \
echo 01 > demoCA/serial && \
# Generate private key for CA
$OPENSSL_EXE genrsa -out publisher_private_key.pem 2048 && \
# Create Certificate request
$OPENSSL_EXE req -config input/publisher.cnf -new -key publisher_private_key.pem -out temp.csr && \
# Sign Certificate request for Domain Participant by CA
$OPENSSL_EXE ca -days 365 -in temp.csr -out publisher_cert.pem && \
# Create Permissions Grant File for Domain Participant
# Sign Permissions Document
$OPENSSL_EXE smime -sign -in input/publisher_permissions.xml -text -out signed_publisher_permissions.p7s -signer demoCA/cacert.pem -inkey demoCA/private/cakey.pem && \
#generate private key for CA
$OPENSSL_EXE genrsa -out subscriber_private_key.pem 2048 && \
# Create Certificate request
$OPENSSL_EXE req -config input/subscriber.cnf -new -key subscriber_private_key.pem -out temp.csr && \
# Sign Certificate request for Domain Participant by CA
$OPENSSL_EXE ca -days 365 -in temp.csr -out subscriber_cert.pem && \
# Create Permissions Grant File for Domain Participant
# Sign Permissions Document
$OPENSSL_EXE smime -sign -in input/subscriber_permissions.xml -text -out signed_subscriber_permissions.p7s -signer demoCA/cacert.pem -inkey demoCA/private/cakey.pem && \
# Sign governance file
$OPENSSL_EXE smime -sign -in input/governance.xml -out signed_governance.p7s -text -signer demoCA/cacert.pem -inkey demoCA/private/cakey.pem && \

if [ $? -eq 0 ]; then
    echo "Done."
else
    echo "Something went wrong..."
    exit -1
fi

mv signed_* output/ && mv publisher_* output/ && mv subscriber_* output/ && mv *_private_key.pem output/ && cp demoCA/cacert.pem output/

echo "Done. Check the output folder."
