#!/bin/bash

BITCOIN_ADDRESS="1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
API_URL="https://api.blockchair.com/bitcoin/dashboards/address/$BITCOIN_ADDRESS"

# Realizar la solicitud HTTP usando curl
response=$(curl -s "$API_URL")

# Imprimir la respuesta completa
echo "Respuesta completa de la API:"
echo "$response" | jq
