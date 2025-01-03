#!/bin/bash

#Autor: Ivan (Bash para principiantes #2 de S4vitar)

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n${redColour}[!] Saliendo...\n${endColour}"

	rm ut.t* money* entradas.tmp salidas.tmp it.tmp 2>/dev/null
	tput cnorm; exit 1
}

function helpPanel(){
	echo -e "\n${redColour}[!] Uso: ./btcAnalyzer${endColour}" #-e para los caracteres especiales
	for i in $(seq 1 80); do echo -ne "${redColour}-"; done; echo -ne "${endColour}" #-n para que no haga salto de linea
	echo -e "\n\n\t${gayColour}[-e]${endColour}${yellowColour} Modo exploracion${endColour}" #Importante poner endColor k sino se me cambia la terminal de color
	echo -e "\t\t${purpleColour}unconfirmed_transacctions${endColour}${yellowColour}:\t Listar transacciones no confirmadas${endColour}"
	echo -e "\t\t${purpleColour}Inspect${endColour}${yellowColour}:\t\t\t Inspeccionar un hash de transaccion${endColour}"
	echo -e "\t\t${purpleColour}Address${endColour}${yellowColour}:\t\t\t Inspeccionar una transaccion de direccion${endColour}"
	echo -e "\n\t${grayColour}[-n]${endColour}${yellowColour} Limitar numero de resultados (Ex: -n 10)${endColour}"
	echo -e "\n\t${grayColour}[-i]${endColour}${yellowColour} Proporcionar el identificador de transaccion${endColour}${blueColour} (Ex: -i 657sd4f63esf)${endColour}"
	echo -e "\n\t${grayColour}[-a]${endColour}${yellowColour} Proporcionar una direccion de transaccion{endColour}${blueColour} (Ex: -a 1ihyv56uo2)${endColour}"
	echo -e "\n\n\t${gayColour}[-h]${endColour}${yellowColour} Mostrar este panel de ayuda${endColour}"

	tput cnorm; exit 1 #cnorm para volver a mostrar el cursor
}


#Variable Globales
unconfirmed_transacctions="https://www.blockchain.com/es/explorer/mempool/btc"
inspect_transacction_url="https://blockchain.info/rawtx/"
inspect_address_url="https://blockchain.info/rawaddr/"

# Función principal que imprime una tabla formateada a partir de datos y un delimitador
function printTable() {

    # Delimitador para separar columnas (por ejemplo, una coma o tabulación)
    local -r delimiter="${1}"

    # Datos de entrada, eliminando líneas vacías
    local -r data="$(removeEmptyLines "${2}")"

    # Verifica si el delimitador no está vacío y los datos no están vacíos
    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        # Obtiene el número de líneas de los datos
        local -r numberOfLines="$(wc -l <<< "${data}")"

        # Si hay al menos una línea
        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''  # Inicializa la tabla como una cadena vacía
            local i=1       # Contador para iterar por las líneas

            # Bucle para procesar cada línea de los datos
            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''  # Almacena la línea actual
                line="$(sed "${i}q;d" <<< "${data}")"  # Obtiene la línea actual (línea i)

                # Obtiene el número de columnas en la línea actual
                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                # Si es la primera línea, añade un borde superior
                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                table="${table}\n"  # Añade un salto de línea en la tabla

                local j=1  # Contador para iterar por las columnas

                # Bucle para procesar cada columna en la línea actual
                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    # Añade cada columna a la tabla, formateada con `#|`
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"  # Finaliza la línea de la tabla

                # Si es la primera línea o la última, añade un borde inferior
                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            # Si la tabla no está vacía, formatea e imprime
            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                # Imprime la tabla formateada, reemplazando `+` con bordes `-`
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

# Elimina líneas vacías del contenido dado
function removeEmptyLines() {
    local -r content="${1}"  # Contenido de entrada
    echo -e "${content}" | sed '/^\s*$/d'  # Usa sed para eliminar líneas vacías
}

# Repite una cadena un número específico de veces
function repeatString() {
    local -r string="${1}"           # Cadena a repetir
    local -r numberToRepeat="${2}"   # Número de repeticiones

    # Si la cadena no está vacía y el número es un entero válido
    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"  # Genera una cadena con espacios
        echo -e "${result// /${string}}"  # Reemplaza los espacios con la cadena
    fi
}

# Verifica si una cadena está vacía
function isEmptyString() {
    local -r string="${1}"  # Cadena de entrada

    # Si la cadena, una vez recortada, está vacía
    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0  # Devuelve 'true'
    fi

    echo 'false' && return 1  # Devuelve 'false' en caso contrario
}

# Elimina espacios en blanco al inicio y al final de una cadena
function trimString() {
    local -r string="${1}"  # Cadena de entrada
    # Usa sed para eliminar espacios iniciales y finales
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

function unconfirmedTransacctions(){

	number_output=$1

	echo '' > ut.tmp
	#Mientras el fichero ut.tmp este vacio (con una linea) no para de llamar a la web hasta que funcione el curl
	while [ "$(cat ut.tmp | wc -l)" == "1" ]; do curl -s "$unconfirmed_transacctions" | html2text | sed 's/_[^H]//g' > ut.tmp

	done

	hashes=$(cat ut.tmp | grep -E "Función" | awk 'NF{print $NF}' | head -n $number_output)

	echo "Hash_Cantidad_Bitcoin_Tiempo" > ut.table

	for hash in $hashes; do
		echo "${hash}_$(cat ut.tmp | grep -A 3 "$hash" | tail -n 1)_$(cat ut.tmp | grep -A 3 "$hash" | awk 'NR==3')_$(cat ut.tmp | grep -A 1 "$hash" | tail -n 1)" >> ut.table
		#echo $hash
	done

	cat ut.table | tr "_" " " | awk '{print $2}' | grep -v "Cantidad" | tr -d '$' | sed 's/\,.*//g' | tr -d '.' > money

	money=0; cat money | while read money_in_line; do 
		let money+=$money_in_line
		echo $money > money.tmp
	done;

	echo -n "Cantidad total_" > amount.table #la tabla tiene que estar toda junta en una linea de hay el -n
	echo "\$$(cat money.tmp | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')" >> amount.table

	if [ "$(cat ut.table | wc -l)" != "1" ]; then

		echo -ne "${yellowColour}"
        	printTable '_' "$(cat ut.table)"
	        echo -ne "${endColour}"

		echo -ne "${blueColour}"
		printTable "_" "$(cat amount.table)"
		echo -ne "${endColour}"

		rm ut.* money* amount.table 2>/dev/null
		exit 1
	else
		rm ut.t* 2>/dev/null
		tput cnorm
	fi

	rm ut.* money* amount.table 2>/dev/null
	tput cnorm
}

function inspectTransacction(){
	inspect_transacction_hash=$1 #el #1 equivale al primer parametro de la fucnion

	echo "Entrada Total_Salida Total" > total_entrada_salida.tmp

	while [ "$(cat total_entrada_salida.tmp | wc -l)" == "1" ]; do
		curl -s "${inspect_transacction_url}${inspect_transacction_hash}" | jq > it.tmp

		echo "$(cat it.tmp | jq '[.inputs[].prev_out.value] | add') BTC_$(cat it.tmp | jq '[.out[].value] | add') BTC" >> total_entrada_salida.tmp

	done
	echo -ne "${greenColour}"
	printTable '_' "$(cat total_entrada_salida.tmp)"
   	echo -ne "${endColour}"

	echo "Dirección (Entradas)_Valor" > entradas.tmp

	while [ "$(cat entradas.tmp | wc -l)" == "1" ]; do

		echo "$(cat it.tmp | jq '[.inputs[0].prev_out.addr] | add'| sed -e 's|["'\'']||g')_$(cat it.tmp | jq '[.inputs[].prev_out.value] | add'/100000000) BTC" >> entradas.tmp

	done

	echo -ne "${greenColour}"
        printTable '_' "$(cat entradas.tmp)"
        echo -ne "${endColour}"

	echo "Dirección (Salida)_Valor" > salidas.tmp

        while [ "$(cat salidas.tmp | wc -l)" == "1" ]; do

                echo "$(cat it.tmp | jq '[.out[0].addr] | add'| sed -e 's|["'\'']||g')_$(cat it.tmp | jq '[.out[].value] | add'/100000000) BTC" >> salidas.tmp

        done

        echo -ne "${greenColour}"
        printTable '_' "$(cat salidas.tmp)"
        echo -ne "${endColour}"

        rm total_entrada_salida.tmp entrada.tmp salidas.tmp it.tmp 2>/dev/null 
	tput cnorm

}

function inspectAddress(){
	address_hash=$1

	echo "Transacciones realizadas_Cantidad total recibida (BTC)_Cantidad total enviada (BTC)_Saldo total en la cuenta (BTC)" > address.information

	while [ "$(cat address.information | wc -l)" == "1" ]; do
		curl -s "${inspect_address_url}${address_hash}" | jq > ia.tmp
		echo "$(cat ia.tmp | jq -r '.n_tx')_$(cat ia.tmp | jq -r '.total_received /10000000' | bc -l) BTC_$(cat ia.tmp | jq -r '.total_sent /10000000' | bc -l) BTC_$(cat ia.tmp | jq -r '.final_balance /10000000' | bc -l) BTC" >> address.information

	done
	echo -ne "${greyColour=}"
	printTable '_' "$(cat address.information)"
	echo -ne "${endColour}"


	bitcoin_value=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd" | jq -r '.bitcoin.usd')

	echo "$(cat ia.tmp | jq -r '.total_received /10000000' | bc -l) BTC" > bitcoin_to_dollar
	echo "$(cat ia.tmp | jq -r '.total_sent /10000000' | bc -l) BTC" >> bitcoin_to_dollar
	echo "$(cat ia.tmp | jq -r '.final_balance /10000000' | bc -l) BTC" >> bitcoin_to_dollar

	cat bitcoin_to_dollar | while read value; do

		echo "\$$(printf "%'.d\n" $(echo "$(echo $value | awk "{print $1}")*$bitcoin_value" | bc) 2>/dev/null)" >> address.information2
	done


	line_null=$(cat address.information | grep "^\$$" | awk '{print $1}' FS=":")

	if [ $line_null ]; then
		sed "${line_null}s/\$/0.00" -i address.information
	fi

	cat address.information2 | xargs | tr ' ' '_' > address.information3

	sed "1iCantidad total recibida (USD)_Cantidad total enviada (USD)_Saldo total en la cuenta (USD)" -i address.information3


	rm address.information ia.tmp 2>/dev/null && mv address.information3 address.information

	echo -ne "${greyColour}"
	printTable '_' "$(cat address.information)"
	echo -ne "${endColour}"


	rm address.information bitcoin_to_dollar address.information2
	tput cnorm
}

parameter_counter=0; while getopts "e:n:i:a:h:" arg; do
	case $arg in
		e) exploration_mode=$OPTARG;let parameter_counter+=1;; #let para hacer operaciones aritmeticas
		n) number_output=$OPTARG; let parameter_couter+=1;; #El parameter counter en este caso sirve para ver si lo estamos utilizando correctamente
		i) inspect_transacction=$OPTARG; let parameter_counter+=1;;
		a) inspect_address=$OPTARG; let parameter_counter+=1;;
		h) helpPanel;;
	esac

done

tput civis #civis para ocultar el cursor

if [ "$parameter_counter" == 0 ]; then helpPanel

else
	if [ "$(echo $exploration_mode)" == "unconfirmed_transacctions" ]; then #esto $() ejecuta lo k hay dentro y se queda con el output
		if [ ! "$number_output"  ]; then
			number_output=20
			unconfirmedTransacctions $number_output
		else
			unconfirmedTransacctions $number_output
		fi

	elif [ "$(echo $exploration_mode)" == "inspect" ]; then

		inspectTransacction $inspect_transacction

	elif [ "$(echo $exploration_mode)" == "address" ]; then

		inspectAddress $inspect_address

	fi
fi
