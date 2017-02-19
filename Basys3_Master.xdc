## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top #level signal names in the project

## Clock signal
set_property PACKAGE_PIN W5 [get_ports mclk]		
	set_property IOSTANDARD LVCMOS33 [get_ports mclk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports mclk]
 

## Switches
set_property PACKAGE_PIN V17 [get_ports color_switch0]					
	set_property IOSTANDARD LVCMOS33 [get_ports color_switch0]
set_property PACKAGE_PIN V16 [get_ports color_switch1]					
	set_property IOSTANDARD LVCMOS33 [get_ports color_switch1]
set_property PACKAGE_PIN W16 [get_ports color_switch2]					
	set_property IOSTANDARD LVCMOS33 [get_ports color_switch2]


##Buttons
set_property PACKAGE_PIN U18 [get_ports reset]						
	set_property IOSTANDARD LVCMOS33 [get_ports reset]


##Pmod Header JA
##Sch name = JA1
set_property PACKAGE_PIN J1 [get_ports a_left]					
	set_property IOSTANDARD LVCMOS33 [get_ports a_left]
##Sch name = JA2
set_property PACKAGE_PIN L2 [get_ports b_left]					
	set_property IOSTANDARD LVCMOS33 [get_ports b_left]


##Pmod Header JC
##Sch name = JC1
set_property PACKAGE_PIN K17 [get_ports a_right]					
	set_property IOSTANDARD LVCMOS33 [get_ports a_right]
##Sch name = JC2
set_property PACKAGE_PIN M18 [get_ports b_right]					
	set_property IOSTANDARD LVCMOS33 [get_ports b_right]


##VGA Connector
set_property PACKAGE_PIN G19 [get_ports {color[11]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[11]}]
set_property PACKAGE_PIN H19 [get_ports {color[10]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[10]}]
set_property PACKAGE_PIN J19 [get_ports {color[9]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[9]}]
set_property PACKAGE_PIN N19 [get_ports {color[8]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[8]}]
set_property PACKAGE_PIN N18 [get_ports {color[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[3]}]
set_property PACKAGE_PIN L18 [get_ports {color[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[2]}]
set_property PACKAGE_PIN K18 [get_ports {color[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[1]}]
set_property PACKAGE_PIN J18 [get_ports {color[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[0]}]
set_property PACKAGE_PIN J17 [get_ports {color[7]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[7]}]
set_property PACKAGE_PIN H17 [get_ports {color[6]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[6]}]
set_property PACKAGE_PIN G17 [get_ports {color[5]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {color[5]}]	
set_property PACKAGE_PIN D17 [get_ports {color[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {color[4]}]	
set_property PACKAGE_PIN P19 [get_ports hsync]						
	set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN R19 [get_ports vsync]						
	set_property IOSTANDARD LVCMOS33 [get_ports vsync]


## These additional constraints are recommended by Digilent
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]