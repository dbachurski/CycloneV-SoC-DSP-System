/* Copyright (C) 2023  AGH University of Science and Technology */

`timescale 1ns/1ps

`include "svunit_defines.svh"

import svunit_pkg::svunit_testcase;

module dft_unit_test;


/* Local variables and signals */

svunit_testcase svunit_ut;
string name = "dft";

reg clk;
reg rst_i;
reg autorun_i;
reg run_i;
reg fin_i;
reg ifft_i;

wire done_o;
wire [3:0] status_o;
wire [7:0] bfpexp_o;

reg sact_istream_i;
reg [15:0] sdw_istream_real_i;
reg [15:0] sdw_istream_imag_i;

reg dmaact_i;
reg [31:0] dmaa_i;
wire [15:0] dmadr_real_o;
wire [15:0] dmadr_imag_o;

localparam NUM_SAMPLES = 8192;

reg [31:0] dft_samples [0:NUM_SAMPLES-1];
integer i;


/* BFMs instantiation */

altera_avalon_clock_source #(
    .CLOCK_RATE(50),
    .CLOCK_UNIT(1000000)
) u_altera_avalon_clock_source (
    .clk
);

altera_avalon_reset_source #(
    .INITIAL_RESET_CYCLES(0),
    .ASSERT_HIGH_RESET(0)
) u_altera_avalon_reset_source (
    .clk(clk),
    .reset(rst_n)
);


/* Submodules placement */

r2fft_impl u_r2fft_impl (
    .clk(clk),
    .rst_i(rst_i),
    .autorun_i(1'b1),
    .run_i(run_i),
    .fin_i(fin_i),
    .ifft_i(ifft_i),
    .done_o(done_o),
    .status_o(status_o),
    .bfpexp_o(bfpexp_o),
    .sact_istream_i(sact_istream_i),
    .sdw_istream_real_i(sdw_istream_real_i),
    .sdw_istream_imag_i(sdw_istream_imag_i),
    .dmaact_i(dmaact_i),
    .dmaa_i(dmaa_i),
    .dmadr_real_o(dmadr_real_o),
    .dmadr_imag_o(dmadr_imag_o)
  );


/* Tasks and functions definitions */

function void build();
    svunit_ut = new(name);
    verbosity_pkg::set_verbosity(verbosity_pkg::VERBOSITY_WARNING);
endfunction

task setup();
    svunit_ut.setup();

    @(negedge clk);
    u_altera_avalon_reset_source.reset_assert();
    @(negedge clk);
    u_altera_avalon_reset_source.reset_deassert();
    #1;
endtask

task teardown();
    svunit_ut.teardown();
endtask


/* Test suite definition */

`SVUNIT_TESTS_BEGIN

`SVTEST(test_unit_impulse_filter)
    autorun_i = 1'b1;
    run_i = 1'b0;
    fin_i = 1'b0;
    ifft_i = 1'b0;
    dmaact_i = 1'b0;
    sact_istream_i = 1'b0;

    for (i = 0; i < NUM_SAMPLES; i = i + 1) begin
      dft_samples[i] = $random;
    end

    for (i = 0; i < NUM_SAMPLES; i = i + 1) begin
      sact_istream_i = 1'b1;
      sdw_istream_real_i = dft_samples[i][15:0];
      sdw_istream_imag_i = dft_samples[i][31:16];
      #10;
    end
    sact_istream_i = 1'b0;

    wait(status_o == 4'b1000);
    $display("Simulation completed with status: %b", status_o);
    $finish;
`SVTEST_END

`SVUNIT_TESTS_END

endmodule
