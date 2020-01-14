#!/bin/bash

X310_IP="192.168.40.2"
UHD_INSTALL=$(uhd_config_info --install-prefix | sed 's/\Install prefix: //g')
IMAGES_DIR="$UHD_INSTALL/share/uhd/images"
X310_IMAGE="usrp_x310_fpga_XG.bit"

check_for_device(){
	exec 2> /dev/null
	uhd_find_devices --args addr=$X310_IP >/dev/null
	if [ $? -eq 0 ]; then
		check_x310_fpga
	else
  		echo "No USRP detected at $X310_IP. Make sure network setting are configured correctly."
	fi
}

check_x310_fpga(){
	uhd_usrp_probe --args addr=$X310_IP >/dev/null
	if [ $? -eq 0 ]; then
			echo "FPGA versions match."
		else
 	 		echo "FPGA versions do not match. Need to update FPGA..."
			check_for_images
			update_fpga
	fi
}

check_for_images(){
	if [ -f "$IMAGES_DIR/$X310_IMAGE" ]; then
		echo "Found a valid x310 image in $IMAGES_DIR."
	else 
		echo "Did not find a valid X310 image in $IMAGES_DIR. Downloading..."
		sudo uhd_images_downloader -t $X310_IMAGE
	fi
}

update_fpga(){
	echo -e "\n***UPDATING USRP FPGA IMAGE. DO NOT POWER CYCLE OR INTERRUPT COMMUNICATIONS WITH THE USRP UNTIL UPDATE IS COMPLETE***\n"
	uhd_image_loader --args type=x300,addr=$X310_IP
	if [ $? -eq 0 ]; then
		echo "FPGA update complete. Powercycle USRP to use new FPGA image, rerun this script to ensure your FPGA versions are now aligned. "
		else
  		echo "Failed to Flash FPGA. Ensure you have FPGA images downloaded with uhd_images_downloader"
	fi
}

check_for_device