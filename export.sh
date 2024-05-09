#!/bin/bash
# usage: ./export.sh <intermediate> <certificate-name> <dest-folder>

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo ./export.sh"
  exit
fi

showHelp() {
cat << EOF
Usage: ./export.sh -i <intermediate-name> -c <certificate-name> -d <dest-folder> [-k] [-h]
  -h  Display help
  -i  name of the intermediate
      (it's the /root/ca_setup/intermediate)
  -c  name of the certificate ("intermediate" or client/server name)
      (it's /root/ca_setup/intermediate/certs/<CERT_NAME>.cert.pem and /root/ca_setup/intermediate/private/<CERT_NAME>.cert.pem)
  -d  destination folder
  -k  exports the private key

Examples:

  to extract the intermediate "intermediate" (including private key) into ~/exported:
    ./export.sh -i intermediate -c intermediate -d ~/exported -k

  to extract the server "odp1-mar2024.adsre.com" (including private key) into ~/exported:
    ./export.sh -i intermediate -c odp1-mar2024.adsre.com -d ~/exported -k

EOF
}

while getopts "hki:c:d:" args; do
    case "${args}" in
        h ) showHelp;;
        i ) INTERMEDIATE_DIR="${OPTARG}";;
        c ) CERT_NAME="${OPTARG}";;
        d ) DEST_DIR="${OPTARG}";;
        k ) PK=1;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done
shift $((OPTIND-1))

if [ ! "$INTERMEDIATE_DIR" ] || [ ! "$CERT_NAME" ] || [ ! "$DEST_DIR" ]; then
    showHelp
    exit 1
fi

CA_ROOT="/root/ca_setup"

# Create dest folder if it does not exist
echo "Creating ${DEST_DIR} (if it does not exist already)..."
mkdir -p ${DEST_DIR}

source="${CA_ROOT}/${INTERMEDIATE_DIR}/certs/ca-chain.cert.pem"
dest="${DEST_DIR}/${INTERMEDIATE_DIR}-ca-chain.cert.pem"
echo "Exporting root+intermediate chain..."
echo "${source} --> ${dest}"
cp "$source" "$dest"

source="${CA_ROOT}/${INTERMEDIATE_DIR}/certs/${CERT_NAME}.cert.pem"
dest="${DEST_DIR}/${INTERMEDIATE_DIR}-${CERT_NAME}.cert.pem"
echo "Exporting certificate..."
echo "${source} --> ${dest}"
cp "$source" "$dest"

if [ "$PK" ]; then
    source="${CA_ROOT}/${INTERMEDIATE_DIR}/private/${CERT_NAME}.key.pem"
    dest="${DEST_DIR}/${INTERMEDIATE_DIR}-${CERT_NAME}.key.pem"
    echo "Exporting private key..."
    echo "${source} --> ${dest}"
    cp "$source" "$dest"
fi

exit 0
