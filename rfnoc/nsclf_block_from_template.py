#!/usr/bin/env python3
"""rfnoc_modtool's rfnoc_block_nsclf.sv template -> rtl/x310/rfnoc_block_nsclf.sv (called by rfnoc/gen_nsclf.sh).

Three mechanical edits, nothing else: (1) header comment; (2) the io-port widths, which rfnoc_modtool 4.9
writes as unrendered Mako (evidence/stage5/toolchain/README.md section 4), become [32*NIPC*NUM_PORTS-1:0] /
[NUM_PORTS-1:0]; (3) the template's "User Logic" section becomes one nsclf_user instance.
usage: nsclf_block_from_template.py <template.sv> <out.sv>
"""
import re
import sys

HDR = '''//
// rfnoc_block_nsclf: the Stage 5 classifier block for the X310 image (PLAN.md D-S5-TAP, D-S5-OUT).
//
// Made from the rfnoc_modtool (UHD 4.9 a5d1b2e) template for rfnoc/blocks/nsclf.yml by
// rfnoc/gen_nsclf.sh: the template's unrendered Mako io-port widths are replaced by
// [32*NIPC*NUM_PORTS-1:0] / [NUM_PORTS-1:0] (evidence/stage5/toolchain/README.md section 4) and the
// "User Logic" section by nsclf_user (pass-through wires + nsclf_core). The noc_shell is the
// framework-generated noc_shell_nsclf.sv (its ctrlport_endpoint and axis_data_to_chdr are the only
// clock crossings of the block); everything in nsclf_user runs on radio_clk.
// Register map and timing: evidence/stage5/block/README.md.
//
'''
PORTS = ['radio_rx_data_in', 'radio_rx_stb_in', 'radio_rx_running_in', 'radio_tx_data_in', 'radio_tx_stb_in',
         'radio_tx_running_in', 'radio_rx_data_out', 'radio_rx_stb_out', 'radio_rx_running_out', 'radio_tx_data_out',
         'radio_tx_stb_out', 'radio_tx_running_out', 'radio_time', 'm_ctrlport_req_wr', 'm_ctrlport_req_rd',
         'm_ctrlport_req_addr', 'm_ctrlport_req_data', 'm_ctrlport_resp_ack', 'm_ctrlport_resp_data',
         's_evt_axis_tdata', 's_evt_axis_tkeep', 's_evt_axis_tlast', 's_evt_axis_tvalid', 's_evt_axis_tready',
         's_evt_axis_ttimestamp', 's_evt_axis_thas_time', 's_evt_axis_tlength', 's_evt_axis_teov', 's_evt_axis_teob']
PARAMS = ['NUM_PORTS', 'NIPC', 'CORE_LAT', 'IN_REG', 'LC_X10', 'K_DEFAULT']


def main():
    src = open(sys.argv[1]).read()
    head = re.compile(r'\A//\n// Copyright \d+ <author>\n//\n// SPDX-License-Identifier: GPL-3.0-or-later\n//\n'
                      r'// Module: rfnoc_block_nsclf\n//\n// Description:\n//\n//   <Add block description here>\n//\n')
    src, n = head.subn(HDR, src)
    assert n == 1, 'template header changed'
    wide = (r"\$\{32\*int\(parameters\['spc'\]\)\*int\(parameters\['num_ports'\]\) if isinstance\(parameters\['spc'\], "
            r"int\) and isinstance\(parameters\['num_ports'\], int\) else f\"32\*\{parameters\['spc'\]\}\*"
            r"\{parameters\['num_ports'\]\}\"\}")
    src = re.sub(r'\[' + wide + r'-1:0\]', '[32*NIPC*NUM_PORTS-1:0]', src)
    src = src.replace("[${parameters['num_ports']}-1:0]", '[NUM_PORTS-1:0]')
    assert '${' not in src, 'unrendered Mako left in the template'
    pw = max(len(p) for p in PARAMS)
    qw = max(len(p) for p in PORTS)
    conn = {p: p for p in PORTS}
    user = ('  //---------------------------------------------------------------------------\n'
            '  // User Logic: pass-through + classifier tap (radio_clk only)\n'
            '  //---------------------------------------------------------------------------\n\n'
            '  nsclf_user #(\n'
            + ',\n'.join(f'    .{p:<{pw}} ({p})' for p in PARAMS) + '\n'
            '  ) nsclf_user_i (\n'
            f'    .{"radio_clk":<{qw}} (radio_clk),\n'
            f'    .{"radio_rst":<{qw}} (ctrlport_rst),\n'
            + ',\n'.join(f'    .{p:<{qw}} ({conn[p]})' for p in PORTS) + '\n'
            '  );\n\nendmodule // rfnoc_block_nsclf\n')
    i = src.index('  //---------------------------------------------------------------------------\n  // User Logic')
    end = 'endmodule // rfnoc_block_nsclf\n'
    j = src.index(end) + len(end)
    src = src[:i] + user + src[j:]
    open(sys.argv[2], 'w').write(src)


if __name__ == '__main__':
    main()
