#!/bin/bash
DIR1=/mnt/syshosp
DIR2=/home/sti/.wine/drive_c/syshosp/
DIR3=/home/sti/.config/autostart/syshosp.sh.desktop

function montarSyshosp() {
	clear
	if [ -d $DIR1 ]; then
		umount /mnt/syshosp
		rm -rf /mnt/syshosp/
		sleep 5
	fi

	echo "Montando partições necessárias ..."
	mkdir /mnt/syshosp/
	clear
	sleep 2
	mount -t cifs -o guest //10.12.112.5/cpcinstall/ /mnt/syshosp/
	sleep 2
}

function instalarSyshosp() {
	clear
	echo "#############################################"
	echo "# Estamos instalando o Syshosp. Aguarde ... #"
	echo "#############################################"

	echo -e "\nInstale manualmente o Firebird"

	su - sti -c "cp /mnt/syshosp/Firebird_32.exe /home/sti/Downloads/"

	wine /home/sti/Downloads/Firebird_32.exe
	cp -r /root/.wine /home/sti/
	chmod -R 777 /home/sti/.wine

	if [ ! -d $DIR2 ]; then
		su - sti -c "mkdir $DIR2"
	fi

	if [ ! -f $DIR3 ]; then
		su - sti -c "cp /mnt/syshosp/syshosp.sh.desktop /home/sti/.config/autostart/"
	fi

	echo -e "\nCopiando arquivos. Aguarde..."
	su - sti -c "
	cp -r /mnt/syshosp/Medicall/ $DIR2
	cp -r /mnt/syshosp/Almoxarifado $DIR2 
	cp -r /mnt/syshosp/Laudos/ $DIR2
	cp -r /mnt/syshosp/Syshosp/ $DIR2
	cp -r /mnt/syshosp/Sapi/ $DIR2
	cp -r /mnt/syshosp/lancador/ $DIR2
	cp /mnt/syshosp/syshospv2.py /home/sti/Downloads/ 
	"

	echo -e "Criando arquivo da barra do syshosp..."

	sleep 3
}

function configurarFirefox() {
	clear
	echo -e "Configurando o Firefox. Aguarde ..."
	sleep 2
	su - sti -c "cp /mnt/syshosp/mozilla.cfg /home/sti/Downloads/
		      cp /mnt/syshosp/autoconfig.js /home/sti/Downloads/"

}

function copiarParaSkel() {
	clear

	echo -e "\nCopiando os arquivos para o Skel . . .\n"
	clear
	sleep 3
	echo "Copiando .wine"
	clear
	sleep 2
	cp -r /home/sti/.wine/ /etc/skel/
	clear
	sleep 3
	echo "Copiando .config"
	sleep 4
	clear

	mkdir /etc/skel/.config/
	cp -r /home/sti/.config/autostart /etc/skel/.config/
	echo "Copiando arquivos do Firefox"
	sleep 4
	mv /home/sti/Downloads/autoconfig.js /usr/lib/firefox/browser/defaults/preferences/
	mv /home/sti/Downloads/mozilla.cfg /usr/lib/firefox/
	clear
	echo "Copiando syshosp.sh ..."
	sleep 4
	mv /home/sti/Downloads/syshospv2.py /usr/syshospv2.py
	clear
	sleep 4

}

function atualizaSistema() {
	clear
	echo "Atualizando o Sistema . . ."
	sleep 3
	apt update && apt dist-upgrade -y
	apt install openssh-client -y
	apt install expect -y
}

function instalaAntivirus() {
	clear
	echo "Instalando o Antivírus"
	sleep 2
	if [ ! -f /usr/bin/curl ]; then
		echo "Utilitário CURL nao instalado. Vamos fazer isso agora..."
		apt update && apt install curl -y
	fi
	#curl -k https://www.ctim.mb/sites/default/files/aplicacoes/kspLinux2-0.tar.gz >kspLinux2-0.tar.gz && tar -zxvf kspLinux2-0.tar.gz && chmod +x akinstall.sh && ./akinstall.sh
	cp /mnt/syshosp/kspLinux2-0.tar.gz . && tar -zxvf kspLinux2-0.tar.gz && chmod +x akinstall.sh && ./akinstall.sh
}

function ingressaNoDominio() {
	clear
	echo -e "Copiando arquivos de configuração\n"
	python3 /usr/sbin/mb-config-dominio.py

	clear
	echo -e "Máquina inserida no domínio com sucesso.\n"
}

function pararCups() {
	clear
	echo -e "Vamos limpar o cups..\n"
	sleep 5
	chmod a-x /etc/init.d/avahi-daemon
	chmod a-x /etc/init.d/cups-browsed
	clear
	echo -e "Alterando cups.conf...\n"
	sed 's/^BrowseLocalProtocols.*$/BrowseLocalProtocols\ none/' -i /etc/cups/cupsd.conf
	sleep 5
	echo -e "Parando avahi-daemon..\n"
	service avahi-daemon stop
	sleep 5
	clear
	echo -e "Parando cups-browsed...\n"
	service cups-browsed stop
	sleep 5
	clear
	echo -e "Desabilitando a inicialização automática do cups-browsed...\n"
	sleep 3
	systemctl disable cups-browsed
	clear
	echo -e "Impressoras configuradas\n"
}

function bloquearUsb() {
	clear
	echo -e "Bloqueando portas usb"
	sleep 5
	chmod 444 /media
}

function principal() {
	op=$(
		whiptail --title "Aqui o que podemos fazer" --menu "Selecione o que deseja" 16 100 9 \
			"1" "Somente instalar o Syshosp" \
			"2" "Somente configurar o Firefox" \
			"3" "Somente instalar o Kapersky" \
			"4" "Atualizar o Sistema" \
			"5" "Ingressar no domínio" \
			"6" "Instalar Máquina Padrão por completo" \
			"7" "Instalar máquina padrão SEM o syshosp" \
			"8" "Somente remover impressoras" 3>&2 2>&1 1>&3
	)

	case $op in

	"1")
		montarSyshosp
		instalarSyshosp
		copiarParaSkel
		atualizaSistema
		;;

	"2")
		montarSyshosp
		configurarFirefox
		copiarParaSkel
		atualizaSistema
		;;

	"3")
		montarSyshosp
		instalaAntivirus
		atualizaSistema
		;;

	"4") atualizaSistema ;;

	"5")
		montarSyshosp
		atualizaSistema
		ingressaNoDominio
		;;

	"6")
		montarSyshosp
		instalarSyshosp
		configurarFirefox
		copiarParaSkel
		atualizaSistema
		instalaAntivirus
		ingressaNoDominio
		pararCups
		bloquearUsb
		;;

	"7")
		montarSyshosp
		configurarFirefox
		copiarParaSkel
		atualizaSistema
		instalaAntivirus
		ingressaNoDominio
		pararCups
		bloquearUsb
		;;

	"8") pararCups ;;

	"9") bloquearUsb ;;
	esac

}

########### Início do Script #############

if [ $EUID -ne 0 ]; then
	whiptail --title "Oops" --msgbox "Rode esse script SOMENTE como Root" --fb 10 50
else
	principal
fi
