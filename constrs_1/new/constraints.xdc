set_property PACKAGE_PIN T1 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_property PACKAGE_PIN R2 [get_ports reset2]
set_property IOSTANDARD LVCMOS33 [get_ports reset2]

set_property PACKAGE_PIN U1 [get_ports reset3]
set_property IOSTANDARD LVCMOS33 [get_ports reset3]

set_property PACKAGE_PIN W2 [get_ports reset4]
set_property IOSTANDARD LVCMOS33 [get_ports reset4]

# clock
set_property PACKAGE_PIN W5 [get_ports clk]							
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

#segments

set_property PACKAGE_PIN U2 [get_ports {anode_activate[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode_activate[0]}]

set_property PACKAGE_PIN U4 [get_ports {anode_activate[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode_activate[1]}]

set_property PACKAGE_PIN V4 [get_ports {anode_activate[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode_activate[2]}]

set_property PACKAGE_PIN W4 [get_ports {anode_activate[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {anode_activate[3]}]

set_property PACKAGE_PIN W7 [get_ports {led_segment[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segment[6]}]

set_property PACKAGE_PIN W6 [get_ports {led_segment[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segment[5]}]

set_property PACKAGE_PIN U8 [get_ports {led_segment[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segment[4]}]

set_property PACKAGE_PIN V8 [get_ports {led_segment[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segment[3]}]

set_property PACKAGE_PIN U5 [get_ports {led_segment[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segment[2]}]

set_property PACKAGE_PIN V5 [get_ports {led_segment[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segment[1]}]

set_property PACKAGE_PIN U7 [get_ports {led_segment[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_segment[0]}]

set_property PACKAGE_PIN V7 [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports dp]

## Slide switches (12 least significant)

set_property PACKAGE_PIN V17   [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16   [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16   [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17   [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
set_property PACKAGE_PIN W15   [get_ports {sw[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
set_property PACKAGE_PIN V15   [get_ports {sw[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
set_property PACKAGE_PIN W14   [get_ports {sw[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
set_property PACKAGE_PIN W13   [get_ports {sw[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
set_property PACKAGE_PIN V2    [get_ports {sw[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
set_property PACKAGE_PIN T3    [get_ports {sw[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
set_property PACKAGE_PIN T2    [get_ports {sw[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
set_property PACKAGE_PIN R3    [get_ports {sw[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]

## Red bits
set_property PACKAGE_PIN G19   [get_ports {rgb[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[11]}]
set_property PACKAGE_PIN H19   [get_ports {rgb[10]}] 
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[10]}]
set_property PACKAGE_PIN J19   [get_ports {rgb[9]}]  
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[9]}]
set_property PACKAGE_PIN N19   [get_ports {rgb[8]}]  
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[8]}]

## Blue bits
set_property PACKAGE_PIN N18   [get_ports {rgb[7]}]  
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[7]}]
set_property PACKAGE_PIN L18   [get_ports {rgb[6]}]  
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[6]}]
set_property PACKAGE_PIN K18   [get_ports {rgb[5]}]  
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[5]}]
set_property PACKAGE_PIN J18   [get_ports {rgb[4]}]  
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[4]}]

## Green bits
set_property PACKAGE_PIN J17   [get_ports {rgb[3]}]   
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[3]}]
set_property PACKAGE_PIN H17   [get_ports {rgb[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[2]}]
set_property PACKAGE_PIN G17   [get_ports {rgb[1]}]  
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[1]}]
set_property PACKAGE_PIN D17   [get_ports {rgb[0]}]   
set_property IOSTANDARD LVCMOS33 [get_ports {rgb[0]}]

## VGA sync signals
set_property PACKAGE_PIN P19   [get_ports hsync_staged]
set_property IOSTANDARD LVCMOS33 [get_ports hsync_staged]
set_property PACKAGE_PIN R19   [get_ports vsync_staged]
set_property IOSTANDARD LVCMOS33 [get_ports vsync_staged]

# PS/2 Signals (The Basys3 converts USB Keyboard to these pins internally)
set_property PACKAGE_PIN C17 [get_ports ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_clk]
set_property PULLUP true [get_ports ps2_clk]

set_property PACKAGE_PIN B17 [get_ports ps2_data]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_data]
set_property PULLUP true [get_ports ps2_data]
