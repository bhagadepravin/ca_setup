#!/bin/bash

cd intermediate
mkdir -p certs crl csr newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber
