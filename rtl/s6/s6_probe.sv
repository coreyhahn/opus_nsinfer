// s6_probe: one-way link latency probe (Stage 6, docs/PLAN.md D-S6-MEAS). Possible because both link ends
// run on ONE clock: a timestamp written by one end is read by the other end's counter, the same counter.
//
// Generator (en = 1): one probe word every PERIOD+1 cycles (counted from the accept edge), held while
// tready is low:  [DW-1:DW-8] TAG_PROBE   [DW-9:DW-32] seq   [31:0] tsc in the cycle of the accept edge
// (tdata is combinational in tsc, so the stamp is the value at the accepting edge, as s3_side_a's send stamp).
// Checker: every RX beat is registered (R, as s3_side_a's R0 and s3_side_b's R); a probe word's latency is
// tsc(R edge) - stamp = edges from the TX accept edge to the RX register edge, the s3 loop convention.
// HB-bin histogram from HBASE; words with another tag or a sequence gap count as n_bad.
module s6_probe
  import s6_pkg::*;
#(
    parameter int DW = 64,
    parameter int HB = 32
) (
    input  logic          clk,
    input  logic          rst,
    input  logic          en,
    input  logic [15:0]   period,
    input  logic [15:0]   hbase,
    input  logic          clr,
    input  logic [31:0]   tsc,
    output logic [DW-1:0] tdata,
    output logic          tvalid,
    input  logic          tready,
    input  logic [DW-1:0] rdata,
    input  logic          rvalid,
    output s6_probe_stat_t stat,
    output logic [31:0]   hist[HB]
);
  // ---------------- generator ----------------
  logic [23:0] seq;
  logic [15:0] gcnt;
  always_comb begin
    tdata = '0;
    tdata[DW-1 -: 32] = {TAG_PROBE, seq};
    tdata[31:0] = tsc;
  end
  always_ff @(posedge clk) begin
    if (rst || !en) begin
      tvalid <= 1'b0; seq <= '0; gcnt <= '0;
    end else begin
      if (gcnt != '0) gcnt <= gcnt - 1'b1;
      if (tvalid && tready) begin
        tvalid <= 1'b0; seq <= seq + 1'b1; gcnt <= period;
      end else if (!tvalid && gcnt == '0) begin
        tvalid <= 1'b1;
      end
    end
  end

  // ---------------- checker ----------------
  logic          r_v;
  logic [DW-1:0] r_d;
  logic [31:0]   r_t;
  always_ff @(posedge clk) begin
    r_v <= rvalid && !rst;
    r_d <= rdata;
    r_t <= tsc;
  end
  wire        is_p = r_v && (r_d[DW-1:DW-8] == TAG_PROBE);
  wire [31:0] lat  = r_t - r_d[31:0];
  wire [31:0] off  = lat - 32'(hbase);
  logic [23:0] exp_seq;
  logic [31:0] c_tx, c_rx, c_bad, c_min, c_max;
  logic [47:0] c_sum;
  always_ff @(posedge clk) begin
    if (rst || clr) begin
      c_tx <= '0; c_rx <= '0; c_bad <= '0; c_min <= '1; c_max <= '0; c_sum <= '0; exp_seq <= '0;
      for (int i = 0; i < HB; i++) hist[i] <= '0;
    end else begin
      if (en && tvalid && tready) c_tx <= c_tx + 1'b1;   // en: the link takes the probe's word only while en
      if (r_v && !is_p) c_bad <= c_bad + 1'b1;
      if (is_p) begin
        c_rx <= c_rx + 1'b1;
        exp_seq <= r_d[DW-9:DW-32] + 1'b1;
        if (r_d[DW-9:DW-32] != exp_seq) c_bad <= c_bad + 1'b1;
        if (lat < c_min) c_min <= lat;
        if (lat > c_max) c_max <= lat;
        c_sum <= c_sum + 48'(lat);
        if (lat >= 32'(hbase) && off < 32'(HB)) hist[off[$clog2(HB)-1:0]] <= hist[off[$clog2(HB)-1:0]] + 1'b1;
      end
    end
  end
  assign stat = '{n_tx: c_tx, n_rx: c_rx, n_bad: c_bad, lat_min: c_min, lat_max: c_max, lat_sum: c_sum};

  if (DW > 64) begin : g_unused
    wire unused = &{1'b0, r_d[DW-33:32]};
  end
endmodule
