#!/bin/bash

# ID de la transacción (txid)
TXID="d07c2300d4435853088e73638621ed49351e9e0cd6460a67acf01c890f18aa3f"

# URL de la API (Blockchair como ejemplo)
API_URL="https://api.blockchair.com/bitcoin/raw/transaction/$TXID"

# Realizar la solicitud HTTP
response=$(curl -s "$API_URL")

# Imprimir la respuesta completa (opcional para depuración)
echo "$response" | jq

# Extraer los valores de entrada (inputs) con jq
inputs_value=$(echo "$response" | jq '[.data.transaction.inputs[].value] | add')

# Mostrar el resultado
echo "El valor total de ingreso de la transacción $TXID es: $inputs_value satoshis"
