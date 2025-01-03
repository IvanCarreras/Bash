#!/bin/bash

# Configuración
TXID="d4e6bc03dd89747fff4aee2ba6b93de8c724a9db090a9b392c84017408b19fad" # Hash de la transacción
API_TX_URL="https://blockchain.info/rawtx/$TXID"
API_PRICE_URL="https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"

# Obtener información de la transacción
tx_response=$(curl -s "$API_TX_URL")

# Verificar si se pudo obtener la transacción
if [[ -z "$tx_response" ]]; then
  echo "Error: No se pudo obtener la información de la transacción."
  exit 1
fi

# Obtener el precio actual de BTC en USD
price_response=$(curl -s "$API_PRICE_URL")
btc_price_usd=$(echo "$price_response" | jq -r '.bitcoin.usd')

# Verificar si se pudo obtener el precio
if [[ -z "$btc_price_usd" ]]; then
  echo "Error: No se pudo obtener el precio de BTC."
  exit 1
fi

# Calcular entradas y salidas totales en satoshis
total_input=$(echo "$tx_response" | jq '[.inputs[].prev_out.value] | add')
total_output=$(echo "$tx_response" | jq '[.out[].value] | add')

# Convertir satoshis a BTC
total_input_btc=$(echo "$total_input / 10000000" | bc -l | awk '{printf "%.6f\n", $0}')
total_output_btc=$(echo "$total_output / 100000000" | bc -l | awk '{printf "%.6f\n", $0}')

# Calcular valores en USD
total_input_usd=$(echo "$total_input_btc * $btc_price_usd" | bc -l | awk '{printf "%.6f\n", $0}')
total_output_usd=$(echo "$total_output_btc * $btc_price_usd" | bc -l | awk '{printf "%.6f\n", $0}')

# Mostrar resultados
echo "Información de la transacción:"
echo "Hash de la transacción: $TXID"
echo "Precio actual de BTC: $btc_price_usd USD"

echo -e "\nBTC Gastados (Entradas):"
echo "Total: $total_input_btc BTC"
echo "Valor en USD: $total_input_usd USD"

echo -e "\nBTC Comprados (Salidas):"
echo "Total: $total_output_btc BTC"
echo "Valor en USD: $total_output_usd USD"
