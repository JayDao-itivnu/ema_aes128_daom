# Clock signal
set_property PACKAGE_PIN W5 [get_ports clock]							
	set_property IOSTANDARD LVCMOS33 [get_ports clock]
#	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK100MHZ]
 
# Switches
set_property PACKAGE_PIN V17 [get_ports reset]					
	set_property IOSTANDARD LVCMOS33 [get_ports reset]
	
# LEDs 
set_property PACKAGE_PIN U16 [get_ports tx_tick]					
	set_property IOSTANDARD LVCMOS33 [get_ports tx_tick]
set_property PACKAGE_PIN E19 [get_ports rx_tick]					
	set_property IOSTANDARD LVCMOS33 [get_ports rx_tick]
set_property PACKAGE_PIN U19 [get_ports rx_bit_tick]					
	set_property IOSTANDARD LVCMOS33 [get_ports rx_bit_tick]
	
##USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports rx]						
	set_property IOSTANDARD LVCMOS33 [get_ports rx]
set_property PACKAGE_PIN A18 [get_ports tx]						
	set_property IOSTANDARD LVCMOS33 [get_ports tx]

