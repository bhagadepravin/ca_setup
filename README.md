# ca_setup
Simple setup to create your own CA
This code sets up a simple Certificate Authority (CA) for generating SSL/TLS certificates:

1. It initializes the CA setup by executing `bootstrap.sh`, which sets up the necessary directory structure and configuration files.
2. It creates the CA root certificate chain by running `create_cachain.sh`.
3. It generates a server certificate for the current machine (identified by `hostname -f`) using `gen_server_cert.sh`. This script generates a private key, a certificate signing request (CSR), and then signs the CSR to create the server certificate.
4. Finally, it exports the generated certificate and its private key to the specified destination folder (`/home` in this case) using `export.sh`. If the `-k` option is provided, it also exports the private key.

```
echo "Welcome" > passfile
./bootstrap.sh

./create_cachain.sh
./gen_server_cert.sh `hostname -f`
./export.sh -i intermediate -c `hostname -f` -d /home -k
```
