read_verilog top.v
read_xdc top.xdc
synth_design -top top -part xczu9eg-ffvb1156-2-i
place_design
route_design
report_datasheet -file datasheet.rpt
report_timing -from [get_ports {hd_in hp_in}] -max_paths 2 -nworst 1 -delay_type max -file t_in_max.rpt
report_timing -from [get_ports {hd_in hp_in}] -max_paths 2 -nworst 1 -delay_type min -file t_in_min.rpt
report_timing -to [get_ports {hd_out hp_out}] -max_paths 2 -nworst 1 -delay_type max -file t_out_max.rpt
report_timing -to [get_ports {hd_out hp_out}] -max_paths 2 -nworst 1 -delay_type min -file t_out_min.rpt
report_io -file io.rpt
