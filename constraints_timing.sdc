create_clock -name clk -period 0.65 [get_ports clk]
set_clock_transition -rise 0.2 [get_clocks clk]
set_clock_transition -fall 0.25 [get_clocks clk]


set_input_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports reset]
set_input_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports recharge_code]
set_input_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports recharge]
set_input_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports recharge_option]
set_input_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports password]

set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports balance]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports units]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports backup]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports LED1]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports LED2]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports LED3]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports BD_ones]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports BD_tense]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports UD_ones]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports UD_tense]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports UD_hundred]
set_output_delay -clock [get_clocks clk] -add_delay 0.25 [get_ports sys_status]





