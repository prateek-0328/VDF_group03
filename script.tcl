set_db init_lib_search_path {/home/upal21214/cad180/}
set_db init_hdl_search_path {/home/upal21214/cad180/}

read_libs fast.lib
read_hdl Top_Circuit.v

elaborate Top_Circuit
read_sdc {/home/upal21214/cad180/constraints_timing.sdc}

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium
syn_generic
syn_map
syn_opt

report_area > reports/report_area.rpt
report_power > reports/report_power.rpt
report_qor > reports/report_qor.rpt

write_hdl > outputs/Top_netlist.v


