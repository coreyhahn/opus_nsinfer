# Re-implement an OOC post_synth.dcp with a placement variant (Stage 4 routability work).
#   vivado -mode batch -nojournal -source ooc_impl_variant.tcl -tclargs <post_synth.dcp> <out_dir> <variant>
#   variant: slr1        pblock the whole design to SLR1, default directives
#            slr1_xto    SLR1 pblock, place ExtraTimingOpt, phys_opt AggressiveExplore, route AggressiveExplore
#            fanout      no pblock, place Explore, phys_opt AggressiveFanoutOpt then AggressiveExplore
#            rep         no pblock, place ExtraNetDelay_high, then force-replicate every register-driven net
#                        with more than 40 pins (placement-aware), phys_opt AggressiveExplore, route AggressiveExplore
#            explore     place Explore, phys_opt Explore, route Explore
#            xto         place ExtraTimingOpt, phys_opt AggressiveExplore, route AggressiveExplore (no pblock)
#            nethigh     place ExtraNetDelay_high, phys_opt AggressiveExplore, route AggressiveExplore
#            ssi         place SSI_SpreadLogic_high, phys_opt AggressiveExplore, route AggressiveExplore, post-route phys_opt
# Same OOC class as ooc_jsc.tcl (register to register; ports and IOBs excluded).
lassign $argv dcp out_dir variant
file mkdir $out_dir
set_param general.maxThreads 4
open_checkpoint $dcp
if {[string match slr1* $variant]} {
    create_pblock pb_core
    resize_pblock pb_core -add SLR1
    add_cells_to_pblock pb_core [get_cells -hier -filter {IS_PRIMITIVE}]
}
opt_design
switch $variant {
    slr1     { place_design; phys_opt_design; route_design }
    slr1_xto { place_design -directive ExtraTimingOpt; phys_opt_design -directive AggressiveExplore
               route_design -directive AggressiveExplore }
    fanout   { place_design -directive Explore; phys_opt_design -directive AggressiveFanoutOpt
               phys_opt_design -directive AggressiveExplore; route_design -directive AggressiveExplore }
    rep      { place_design -directive ExtraNetDelay_high
               set q [get_pins -of [get_cells -hier -filter {REF_NAME == FDRE}] -filter {DIRECTION == OUT}]
               set hf [get_nets -of $q -filter {FLAT_PIN_COUNT > 40}]
               puts "rep: force-replicating [llength $hf] register-driven nets"
               phys_opt_design -force_replication_on_nets $hf
               phys_opt_design -directive AggressiveExplore; route_design -directive AggressiveExplore }
    explore  { place_design -directive Explore; phys_opt_design -directive Explore; route_design -directive Explore }
    xto      { place_design -directive ExtraTimingOpt; phys_opt_design -directive AggressiveExplore
               route_design -directive AggressiveExplore }
    nethigh  { place_design -directive ExtraNetDelay_high; phys_opt_design -directive AggressiveExplore
               route_design -directive AggressiveExplore }
    ssi      { place_design -directive SSI_SpreadLogic_high; phys_opt_design -directive AggressiveExplore
               route_design -directive AggressiveExplore; phys_opt_design -directive AggressiveExplore }
    default  { error "unknown variant $variant" }
}
write_checkpoint -force $out_dir/post_route.dcp
report_timing_summary -max_paths 10 -file $out_dir/timing_route.rpt
report_utilization -file $out_dir/util_route.rpt
set wns [get_property SLACK [get_timing_paths -max_paths 1 -setup]]
set whs [get_property SLACK [get_timing_paths -max_paths 1 -hold]]
set fh [open $out_dir/summary.json w]
puts $fh "{\"dcp\": \"$dcp\", \"variant\": \"$variant\", \"wns_ns\": $wns, \"whs_ns\": $whs, \"vivado\": \"[version -short]\", \"date\": \"[clock format [clock seconds] -format %Y-%m-%dT%H:%M:%S]\"}"
close $fh
puts "SUMMARY variant=$variant wns=$wns whs=$whs"
