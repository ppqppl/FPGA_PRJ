# Copyright (C) 2018  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details.

# Quartus Prime Version 18.1.0 Build 625 09/12/2018 SJ Standard Edition
# File: D:\code-file\fpga_prj\led_obj\LED_obj.tcl
# Generated on: Mon Apr 24 09:46:07 2023

package require ::quartus::project

set_location_assignment PIN_G15 -to led_on[0]
set_location_assignment PIN_F16 -to led_on[1]
set_location_assignment PIN_F15 -to led_on[2]
set_location_assignment PIN_D16 -to led_on[3]
set_location_assignment PIN_E1 -to clk
set_location_assignment PIN_E15 -to rst_n
