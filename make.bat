set OPENSSL_EXE=openssl
set OPENSSL_CONF=.\input\openssl.cnf
set RANDFILE=.rnd
RMDIR /S /Q demoCA
RMDIR /S /Q output

@echo off

MD demoCA
MD demoCA\private
MD demoCA\newcerts
MD output
copy NUL demoCA\index.txt
echo 01 > demoCA\serial
%OPENSSL_EXE% genrsa -out demoCA\private\cakey.pem 2048
%OPENSSL_EXE% req -new -key demoCA\private\cakey.pem -out ca.csr -config input\openssl.cnf
%OPENSSL_EXE% x509 -req -days 3650 -in ca.csr -signkey demoCA\private\cakey.pem -out demoCA\cacert.pem
REM Generate private key for CA
%OPENSSL_EXE% genrsa -out publisher_private_key.pem 2048
REM Create Certificate request
%OPENSSL_EXE% req -config input/publisher.cnf -new -key publisher_private_key.pem -out temp.csr
REM Sign Certificate request for Domain Participant by CA
%OPENSSL_EXE% ca -days 365 -in temp.csr -out publisher_cert.pem
REM Create Permissions Grant File for Domain Participant
REM Sign Permissions Document
%OPENSSL_EXE% smime -sign -in input\publisher_permissions.xml -text -out signed_publisher_permissions.p7s -signer demoCA\cacert.pem -inkey demoCA\private\cakey.pem
REM generate private key for CA
%OPENSSL_EXE% genrsa -out subscriber_private_key.pem 2048
REM Create Certificate request
%OPENSSL_EXE% req -config input\subscriber.cnf -new -key subscriber_private_key.pem -out temp.csr
REM Sign Certificate request for Domain Participant by CA
%OPENSSL_EXE% ca -days 365 -in temp.csr -out subscriber_cert.pem
REM Create Permissions Grant File for Domain Participant
REM Sign Permissions Document
%OPENSSL_EXE% smime -sign -in input\subscriber_permissions.xml -text -out signed_subscriber_permissions.p7s -signer demoCA\cacert.pem -inkey demoCA\private\cakey.pem
REM Sign governance file
%OPENSSL_EXE% smime -sign -in input\governance.xml -text -out signed_governance.p7s -signer demoCA\cacert.pem -inkey demoCA\private\cakey.pem

MOVE signed_* output\ & MOVE publisher_* output\ & MOVE subscriber_* output\ & MOVE *_private_key.pem output & COPY demoCA\cacert.pem output\

echo "Done."
