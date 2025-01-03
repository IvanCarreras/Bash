#!/bin/bash

# Dirección de Bitcoin (ejemplo)
BITCOIN_ADDRESS="1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"

# URL de la API (Blockchair como ejemplo)
API_URL="https://api.blockchair.com/bitcoin/dashboards/address/$BITCOIN_ADDRESS"

# Realizar la solicitud HTTP usando curl
response=$(curl -s "$API_URL")

# Extraer el saldo (en satoshis) usando jq
balance=$(echo "$response" | jq '.data."'$BITCOIN_ADDRESS'".address.balance')

# Mostrar el saldo
echo "El saldo de la dirección $BITCOIN_ADDRESS es: $balance satoshis"
