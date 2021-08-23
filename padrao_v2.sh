#!/bin/bash
DIR1=/mnt/syshosp
DIR2=/home/sti/.wine/drive_c/syshosp/
DIR3=/home/sti/.config/autostart/syshosp.sh.desktop


function montar_syshosp(){
	#echo -e "Insira a senha de root para montar a partição necessária"
	if [ -d $DIR1 ]; then	
		umount /mnt/syshosp
		rm -rf /mnt/syshosp/
		sleep 5
	fi
	
	echo "Montando partições necessárias ..."
	mkdir /mnt/syshosp/ 
	sleep 2
	mount -t cifs -o guest //10.12.112.5/cpcinstall/ /mnt/syshosp/
	sleep 2
}

function instalar_syshosp(){
	clear
	echo "#############################################"
	echo "# Estamos instalando o Syshosp. Aguarde ... #"
	echo "#############################################"
	#Verifica se existe a pasta do syshosp no .wine localmente e a cria se nao existir.

	echo -e "\nInstale manualmente o Firebird."
	#Executa o instalador do Firebird
	su - sti -c "wine /mnt/syshosp/Firebird_32.exe"

	if [ ! -d $DIR2 ]; then
		su - sti -c "mkdir $DIR2"
	fi
	
	#Verifica se existe o arquivo syshosp.sh.desktop localmente e o importa se nao existir.
	if [ ! -f $DIR3 ]; then
		su - sti -c "cp /mnt/syshosp/syshosp.sh.desktop /home/sti/.config/autostart/"
		#chmod 777 /home/sti/.config/autostart/syshosp.sh.desktop
	fi
	
	echo -e "\nCopiando arquivos. Aguarde..."
	#Importa todos os arquivos do syshosp
	su - sti -c "
	cp -r /mnt/syshosp/Medicall/ $DIR2
	cp -r /mnt/syshosp/Almoxarifado $DIR2 
	cp -r /mnt/syshosp/Laudos/ $DIR2
	cp -r /mnt/syshosp/Syshosp/ $DIR2
	cp -r /mnt/syshosp/Sapi/ $DIR2
	cp -r /mnt/syshosp/lancador/ $DIR2
	cp /mnt/syshosp/syshosp.py /home/sti/Downloads/ 
	cp /mnt/syshosp/Firebird_32.exe /home/sti/Downloads"
	echo -e "Criando arquivo da barra do syshosp..."
	#Cria o arquivo que executa a barra de tarefas do syshosp
	sleep 3
	}
	
function configurar_ff(){
	echo -e "Configurando o Firefox. Aguarde ..." 
	sleep 2
	su  - sti -c "cp /mnt/syshosp/mozilla.cfg /home/sti/Downloads/
		      cp /mnt/syshosp/autoconfig.js /home/sti/Downloads/"
	
	}

function copiar_para_skel(){
	#Copia os arquivos de configuração do firefox e syshosp para o skel
	#echo -e "\nInsira a senha de root para copiar os arquivos."
	echo -e "\nCopiando os arquivos para o Skel . . .\n"
	clear
	sleep 3
	echo "Copiando .wine"
	clear
	sleep 2
	cp -r /home/sti/.wine/ /etc/skel/
		#echo -e "\nSe houve erro aqui e você não está instalando o Syshosp não há nada de mais. Prossigamos...\n"
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
	mv /home/sti/Downloads/syshosp.py /usr/syshosp.py
	mv /home/sti/Downloads/Firebird_32.exe /usr/Firebird_32.exe
		clear
		#echo -e "\nSe houve erro aqui e você não está instalando o Syshosp não há nada de mais. Prossigamos...\n"
		sleep 4

	#chmod 755 /usr/syshosp.sh
	
	
	}
	
function atualizar_sistema(){
	#echo -e "\nInsira a senha de root para atualizar o sistema"
	echo "Atualizando o Sistema . . ."
	sleep 3
	apt update && apt dist-upgrade -y
	apt install openssh-client -y
	apt install expect -y
	}
	
function instalar_antivirus(){
	clear
	echo "Instalando o Antivírus"
	sleep 2
	if [ ! -f /usr/bin/curl ]; then
		echo "Utilitário CURL nao instalado. Vamos fazer isso agora..."
		#echo -e "\nInsira a senha de root."
		apt update && apt install curl -y
	fi
	#echo -e "\nInsira a senha de root para baixar e instalar o antivírus"
	#curl -k https://www.ctim.mb/sites/default/files/aplicacoes/kspLinux2-0.tar.gz > kspLinux2-0.tar.gz && tar -zxvf kspLinux2-0.tar.gz && chmod +x akinstall.sh && ./akinstall.sh
	cp /mnt/syshosp/kspLinux2-0.tar.gz . && tar -zxvf kspLinux2-0.tar.gz && chmod +x akinstall.sh && ./akinstall.sh
	}
	
function ingressar_dominio(){
	clear
	echo -e "Copiando arquivos de configuração\n"
	#echo -e "\nInsira a senha de root."
	python3 /usr/sbin/mb-config-dominio.py
	#cp /mnt/syshosp/krb5.conf /etc/
	#cp /mnt/syshosp/krb5.keytab /etc/
	clear
	echo -e "Máquina inserida no domínio com sucesso.\n"
	}


function parar_cups(){
	clear	
	echo -e	"Vamos limpar o cups..\n"
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

function bloquear_usb {
+----	echo -e "Bloqueando portas usb"
	sleep 5
	chmod 444 /media
}



function principal(){
	# echo -e "\n ###########################  Isso é o que você pode fazer com este script. Escolha uma opção.  ###########################\n"
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

	"1")        montar_syshosp
		    instalar_syshosp
		    copiar_para_skel 
		    atualizar_sistema ;;
	
	"2")	    montar_syshosp
		    configurar_ff
		    copiar_para_skel
		    atualizar_sistema ;;

	"3")        montar_syshosp
		    instalar_antivirus 
		    atualizar_sistema ;;

	"4")        atualizar_sistema ;;

	"5")        montar_syshosp
		    atualizar_sistema
		    ingressar_dominio ;;
	
	"6")	    montar_syshosp
		    instalar_syshosp
		    configurar_ff
		    copiar_para_skel
		    atualizar_sistema
		    instalar_antivirus
		    ingressar_dominio
		    parar_cups
		    bloquear_usb ;;
	
	"7")	    montar_syshosp
		    configurar_ff
		    copiar_para_skel
		    atualizar_sistema
		    instalar_antivirus
		    ingressar_dominio
		    parar_cups 
		    bloquear_usb ;;

	"8")	    parar_cups ;;

	"9")	    bloquear_usb	
	esac

}


########### Início do Script #############


if [ $EUID -ne 0 ]; then
		whiptail --title "Pouco poder em suas mãos..." --msgbox "Rode esse script SOMENTE como Root" --fb 10 50
	else
		principal
fi