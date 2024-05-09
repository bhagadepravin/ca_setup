#/bin/bash

if [ ! -f "./passfile" ]; then
  echo "Please create a file called ./passfile with a secure password"
  exit 1
fi

host=$1
cnf="cnf/${host}.cnf"

if [ -f "cnf/${host}.cnf" ]; then
  cnf="cnf/${host}.cnf"
else
  echo "[ req ]
default_bits = 2048
prompt = no
encrypt_key = no
default_md = sha256
distinguished_name = dn
utf8 = yes

[ dn ]
C = US
ST=LA
L=PA
O=ACCELDATA
CN = ${host}
" > cnf/${host}.cnf
  cnf="cnf/${host}.cnf"
fi

echo "Using ${cnf} as config file"

openssl genrsa -out intermediate/private/${host}.key.pem 2048

openssl req -config ${cnf} -batch -key intermediate/private/${host}.key.pem -new -sha256 -out intermediate/csr/${host}.csr.pem

# Add ${host} with the next available number in the [alt_names] section
next_dns_number=$(awk '/^\[ alt_names \]/{flag=1;next}/^\[/{flag=0}flag{count++}END{print count+1}' intermediate/openssl.cnf)
sed -i "/^\[ alt_names \]/a DNS.${next_dns_number} = \"${host}\"" intermediate/openssl.cnf

openssl ca -config intermediate/openssl.cnf -extensions v3_req -extensions server_cert \
  -days 375 -notext -md sha256 -in intermediate/csr/${host}.csr.pem \
  -passin file:passfile \
  -out intermediate/certs/${host}.cert.pem
