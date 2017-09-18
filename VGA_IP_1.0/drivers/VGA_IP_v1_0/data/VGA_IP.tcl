

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "VGA_IP" "NUM_INSTANCES" "DEVICE_ID"  "C_CTRL_BASEADDR" "C_CTRL_HIGHADDR"
}
