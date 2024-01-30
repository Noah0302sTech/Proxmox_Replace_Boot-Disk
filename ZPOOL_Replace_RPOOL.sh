#!/bin/bash
#	Made by Noah0302sTech
#	chmod +x ZPOOL_Replace_RPOOL.sh && bash ZPOOL_Replace_RPOOL.sh
#	wget https://raw.githubusercontent.com/Noah0302sTech/Proxmox_Replace_Boot-Disk/testing/ZPOOL_Replace_RPOOL.sh && bash ZPOOL_Replace_RPOOL.sh



#----- echoEnd
	function echoEnd {
		echo
		echo
		echo
	}



#----- WARNING
	echo "WARNING! This only works, if you are already booted via UEFI, NOT vi BIOS!"






#---------- Copy Data from remaining Disk to new Disk
	#----- List Disks by-id
		ls -l /dev/disk/by-id
		echo

	#----- Variables
		#--- Set Variable Defaults
			sdOLD=sdX
			sdNEW=sdY

		#--- Prompt for custom values
			read -p "Gib die FUNKTIONIERENDE Disk an [default: $sdOLD]: " input
			sdOLD=${input:-$sdOLD}
			read -p "Gib die NEUE Disk an [default: $sdNEW]: " input
			sdNEW=${input:-$sdNEW}
			echo

		#--- Approve Values
			echo "FUNKTIONIERENDE: $sdOLD (Kopieren)"
			echo "NEUE: $sdNEW (Überschreiben)"
			echo
			while IFS= read -n1 -r -p "Ist das richtig? [y]es|[n]o: " && [[ $REPLY != q ]]; do
			case $REPLY in
				y)	echo
					echo "Kopiere von $sdOLD auf $sdNEW..."
					sleep 5

					break;;
				n)	echo
					echo "ABBRUCH!!!"

					exit;;
				*)	echo
					echo "Antoworte mit y oder n";;
			esac
			done
			echo

	#----- Copy Data from Old to New
		sgdisk /dev/$sdOLD -R /dev/$sdNEW
		sgdisk -G /dev/$sdNEW

	echoEnd





#---------- Replace old ZPOOL-Device with new
	#----- List rpool
		zpool status rpool
		echo

	#----- Variables
		#--- Set Variable Defaults
			rpoolMISSING=ata-MISSING-PARTITION_OF-MISSING-DEVICE-part3
			rpoolNEW=ata-NEW-PARTITION_OF-NEW-DEVICE-part3

		#--- Prompt for custom values
			read -p "Gib die FEHLENDE Partition der FEHLENDEN Disk an (OHNE /dev/disk/by-id/) [default: $rpoolMISSING]: " input
			rpoolMISSING=${input:-$rpoolMISSING}
			echo

		#--- List Current Disks
			ls -l /dev/disk/by-id
			echo

		#--- Prompt for custom values
			read -p "Gib die NEU Partition der NEUEN Disk an (OHNE /dev/disk/by-id/) [default: $rpoolNEW]: " input
			rpoolNEW=${input:-$rpoolNEW}
			echo

		#--- Approve Values
			echo "FEHLEND: $rpoolMISSING (ERSETZEN)"
			echo "NEUE: $rpoolNEW (ÜBERNEHMEN)"
			echo
			while IFS= read -n1 -r -p "Ist das richtig? [y]es|[n]o: " && [[ $REPLY != q ]]; do
			case $REPLY in
				y)	echo
					echo "Ersetze $rpoolMISSING mit $rpoolNEW..."
					sleep 5

					break;;
				n)	echo
					echo "ABBRUCH!!!"

					exit;;
				*)	echo
					echo "Antoworte mit y oder n";;
			esac
			done
			echo

	#----- Replace Missing with New
		zpool replace -f rpool $rpoolMISSING $rpoolNEW

	echoEnd





#---------- Watch ZPOOL Status
	echo "ZPOOL-Status abbrechen, wenn Resilver fertig ist!"
	sleep 5
	watch zpool status -v rpool

	echoEnd





#---------- Copy Boot-Partition from old to new
	#----- List Disks by-id
		ls -l /dev/disk/by-id
		echo

	#----- Variables
		#--- Set Variable Defaults
			sdNEWz=sdYz

		#--- Prompt for custom values
			read -p "Gib die Boot-Partition der NEUEN Disk an [default: $sdNEWz]: " input
			sdNEWz=${input:-$sdNEWz}
			echo

		#--- Approve Values
			echo "BOOT-NEU: $sdNEWz (Erstellen)"
			echo
			while IFS= read -n1 -r -p "Ist das richtig? [y]es|[n]o: " && [[ $REPLY != q ]]; do
			case $REPLY in
				y)	echo
					echo "Erstelle Boot-Partition auf $sdNEWz..."
					sleep 5

					break;;
				n)	echo
					echo "ABBRUCH!!!"

					exit;;
				*)	echo
					echo "Antoworte mit y oder n";;
			esac
			done
			echo

	#----- Format new Boot-Sector
		proxmox-boot-tool format /dev/$sdNEWz

	#----- Init new Boot-Sector
		proxmox-boot-tool init /dev/$sdNEWz

	#----- Refresh Proxmox-Boot-Tool
		proxmox-boot-tool refresh

	echoEnd





#----- Create Folders
	mkdir /root/Noah0302sTech
	mkdir /root/Noah0302sTech/Proxmox_Replace_Boot-Disk

#----- Move Bash-Script
	mv ZPOOL_Replace_RPOOL.sh /root/Noah0302sTech/Proxmox_Replace_Boot-Disk/