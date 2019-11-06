#!/bin/bash

#Utility to gather 95% of relevant USRP troublshooting information, output as
#.txt files, and then compress. Send this to the support team.
DATE=$(date +'%m_%d_%Y')
WORKING_DIR=""./usrp_report_"$DATE"

get_host_sw_cmds=(
"uname -a"
#"comment anything you want to omit like this"
"ifconfig"
"cpufreq-info"
)

get_host_hw_cmds=(
"uhd_find_devices"
#"uhd_usrp_probe --args "type=b200""
"lshw"
)

get_uhd_cmds=(
"uhd_usrp_probe"
#"uhd_usrp_probe --args "addr=123.123.123.123,serial=1234567""
)

get_gr_cmds=(
"gnuradio-companion --version"
)

file_names=(
"get_host_sw_cmds"
"get_host_hw_cmds"
"get_uhd_cmds"
"get_gr_cmds"
)

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

make_dir
get_host_sw_info
get_host_hw_info
get_uhd_info
get_gr_info
compress_dir
