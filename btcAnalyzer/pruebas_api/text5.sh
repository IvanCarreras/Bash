#!/bin/bash

# Configuración
ADDRESS="3L1p2tUHPwrRN3qgf4Hm1R73e29hFshbnp" # Dirección de Bitcoin
API_URL="https://blockchain.info/rawaddr/$ADDRESS"

# Realizar la solicitud
response=$(curl -s "$API_URL")

# Verificar si hubo un error
if [[ -z "$response" ]]; then
  echo "Error: No se pudo obtener la información de la dirección."
  exit 1
fi
#echo "$response" | jq
# Extraer información clave usando jq
balance=$(echo "$response" | jq -r '.final_balance') # Saldo final en satoshis
total_received=$(echo "$response" | jq -r '.total_received') # Total recibido en satoshis
total_sent=$(echo "$response" | jq -r '.total_sent') # Total enviado en satoshis
tx_count=$(echo "$response" | jq -r '.n_tx') # Número de transacciones

# Convertir valores de satoshis a BTC
balance_btc=$(echo "$balance / 100000000" | bc -l)
total_received_btc=$(echo "$total_received / 100000000" | bc -l)
total_sent_btc=$(echo "$total_sent / 100000000" | bc -l)

# Mostrar información
echo "Información de la dirección $ADDRESS:"
echo "Saldo final: $balance satoshis ($balance_btc BTC)"
echo "Total recibido: $total_received satoshis ($total_received_btc BTC)"
echo "Total enviado: $total_sent satoshis ($total_sent_btc BTC)"
echo "Número de transacciones: $tx_count"
