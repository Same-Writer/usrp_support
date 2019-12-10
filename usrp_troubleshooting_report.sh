#!/bin/bash

#Utility to gather 95% of relevant USRP troublshooting information, output as
#.txt files, and then compress. Send this to the support team.
DATE=$(date +'%m_%d_%Y')
WORKING_DIR=""./usrp_report_"$DATE"
PREFIX_RETURN="$(uhd_config_info --install-prefix)"
UHD_INSTALL_DIR=${PREFIX_RETURN#"Install prefix: "}

get_host_sw_cmds=(
"uname -a"
"cat /etc/lsb-release"
#"comment anything you want to omit like this"
"ip a"
"cpufreq-info"
"cat /proc/cpuinfo"
"dpkg -l"
)

get_host_hw_cmds=(
"uhd_find_devices"
#"uhd_usrp_probe --args "type=b200""
"lshw"
"lsusb"
"lspci"
"lspci -vvv"
"lspci -t"
)

get_uhd_cmds=(
"uhd_usrp_probe"
#"uhd_usrp_probe --args "addr=123.123.123.123,serial=1234567"
"uhd_config_info --print-all"
"$UHD_INSTALL_DIR/lib/uhd/utils/usrp_burn_mb_eeprom --read-all"
"$UHD_INSTALL_DIR/lib/uhd/utils/usrp_burn_db_eeprom"
"$UHD_INSTALL_DIR/lib/uhd/utils/b2xx_fx3_utils"
)

get_gr_cmds=(
"gnuradio-companion --version"
"gnuradio-config-info --enabled-components"
"gnuradio-config-info --prefix"
)

file_names=(
"get_host_sw_cmds"
"get_host_hw_cmds"
"get_uhd_cmds"
"get_gr_cmds"
)

user_message(){
echo -e "
*****************************************************************************
* This utility will record several hardware and software details about your
* system. The outputs will be logged to .txt and .html files. Those files
* will get compressed as *.tar.gz so you can email them to technical support.
* Here's everything we're planning to log on this run:
*"

printf '\t%s\n' "${get_host_sw_cmds[@]}"
printf '\t%s\n' "${get_host_hw_cmds[@]}"
printf "\tlshw -html (comment last line of 'get_host_hw_info' to omit)\n"
printf '\t%s\n' "${get_gr_cmds[@]}"
printf '\t%s\n' "${get_uhd_cmds[@]}"

echo -e "\nWould you like to continue? (y/n)"
read user_decision

	if [ "$user_decision" = "y" ]
	then
		:
	elif [ "$user_decision" = "n" ];
		then
		exit 1
	else
		echo "Invalid Input, try again!"
		user_message
	fi
}

make_dir(){
	mkdir -p $WORKING_DIR
}

get_host_sw_info(){
	echo >$WORKING_DIR/${file_names[0]}.txt

	for i in ${!get_host_sw_cmds[@]};
	do
	echo -e '\n~~~'${get_host_sw_cmds[i]}'~~~~\n' 	>>$WORKING_DIR/${file_names[0]}.txt
	${get_host_sw_cmds[i]} 													&>>$WORKING_DIR/${file_names[0]}.txt
	done
}

get_host_hw_info(){
	echo >$WORKING_DIR/${file_names[1]}.txt

	for i in ${!get_host_hw_cmds[@]};
	do
	echo -e '\n~~~'${get_host_hw_cmds[i]}'~~~~\n' 	>>$WORKING_DIR/${file_names[1]}.txt
	${get_host_hw_cmds[i]} 													&>>$WORKING_DIR/${file_names[1]}.txt
	done

	lshw -html &>>$WORKING_DIR/hardware.html
}

get_uhd_info(){
	echo >$WORKING_DIR/${file_names[2]}.txt

	for i in ${!get_uhd_cmds[@]};
	do
	echo -e '\n~~~'${get_uhd_cmds[i]}'~~~~\n' 	>>$WORKING_DIR/${file_names[2]}.txt
	${get_uhd_cmds[i]} 													&>>$WORKING_DIR/${file_names[2]}.txt
	done
}

get_gr_info(){
	echo >$WORKING_DIR/${file_names[3]}.txt

	for i in ${!get_gr_cmds[@]};
	do
	echo -e '\n~~~'${get_gr_cmds[i]}'~~~~\n' 	>>$WORKING_DIR/${file_names[3]}.txt
	${get_gr_cmds[i]} 													&>>$WORKING_DIR/${file_names[3]}.txt
	done
}

compress_dir(){
	tar --warning=no-file-changed -czf $WORKING_DIR/$WORKING_DIR".tar.gz" $WORKING_DIR
}

user_message
make_dir
get_host_sw_info
get_host_hw_info
get_uhd_info
get_gr_info
compress_dir
