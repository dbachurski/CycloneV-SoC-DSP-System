/* Copyright (C) 2023  AGH University of Science and Technology */

`timescale 1ns/1ps

`include "svunit_defines.svh"

import svunit_pkg::svunit_testcase;

module fir_filter_unit_test;


/* Local variables and signals */

svunit_testcase svunit_ut;
string name = "fir_filter";

logic               clk, rst_n;

csr_pkg::csr__out_t hwif_in;

logic signed [15:0] signal;
logic signed [15:0] filtered_signal;
logic               signal_valid, filtered_signal_valid;

logic signed [15:0] memory [0:255];

int fd;


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

  fir_filter u_fir_filter (
    .clk,
    .rst_n,

    .hwif_in,

    .filtered_signal_valid,
    .filtered_signal,

    .signal_valid,
    .signal
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
    signal = 512'b0;
    signal_valid = 1'b0;

    hwif_in.fir_coeff_0.val.value = 32'h00004000;
    hwif_in.fir_coeff_1.val.value = 32'h00000000;
    hwif_in.fir_coeff_2.val.value = 32'h00000000;
    hwif_in.fir_coeff_3.val.value = 32'h00000000;
    hwif_in.fir_coeff_4.val.value = 32'h00000000;
    hwif_in.fir_coeff_5.val.value = 32'h00000000;
    hwif_in.fir_coeff_6.val.value = 32'h00000000;
    hwif_in.fir_coeff_7.val.value = 32'h00000000;
    hwif_in.fir_coeff_8.val.value = 32'h00000000;
    hwif_in.fir_coeff_9.val.value = 32'h00000000;
    hwif_in.fir_coeff_10.val.value = 32'h00000000;
    hwif_in.fir_coeff_11.val.value = 32'h00000000;
    hwif_in.fir_coeff_12.val.value = 32'h00000000;
    hwif_in.fir_coeff_13.val.value = 32'h00000000;
    hwif_in.fir_coeff_14.val.value = 32'h00000000;
    hwif_in.fir_coeff_15.val.value = 32'h00000000;

    signal_valid = 1'b1;

    fork
        begin
            fd = $fopen("noisy_signal.txt", "r");
            for (int i = 0; i < 1000; i++) begin
                @(negedge clk);
                $fscanf(fd, "%d\n", signal);
            end
        end
        begin
            for (int i = 0; i < 1000; i++) begin
                @(negedge clk);
                memory[i] = filtered_signal;
            end
        end
    join_any
    disable fork;

    signal_valid = 1'b0;
`SVTEST_END

`SVTEST(test_moving_avarage_filter)
    signal = 0;
    signal_valid = 1'b0;

    hwif_in.fir_coeff_0.val.value = 32'h02000200;
    hwif_in.fir_coeff_1.val.value = 32'h02000200;
    hwif_in.fir_coeff_2.val.value = 32'h02000200;
    hwif_in.fir_coeff_3.val.value = 32'h02000200;
    hwif_in.fir_coeff_4.val.value = 32'h02000200;
    hwif_in.fir_coeff_5.val.value = 32'h02000200;
    hwif_in.fir_coeff_6.val.value = 32'h02000200;
    hwif_in.fir_coeff_7.val.value = 32'h02000200;
    hwif_in.fir_coeff_8.val.value = 32'h02000200;
    hwif_in.fir_coeff_9.val.value = 32'h02000200;
    hwif_in.fir_coeff_10.val.value = 32'h02000200;
    hwif_in.fir_coeff_11.val.value = 32'h02000200;
    hwif_in.fir_coeff_12.val.value = 32'h02000200;
    hwif_in.fir_coeff_13.val.value = 32'h02000200;
    hwif_in.fir_coeff_14.val.value = 32'h02000200;
    hwif_in.fir_coeff_15.val.value = 32'h02000200;

    signal_valid = 1'b1;

    fork
        begin
            fd = $fopen("noisy_signal.txt", "r");
            for (int i = 0; i < 1000; i++) begin
                @(negedge clk);
                $fscanf(fd, "%d\n", signal);
            end
        end
        begin
            for (int i = 0; i < 1000; i++) begin
                @(negedge clk);
                memory[i] = filtered_signal;
            end
        end
    join_any

    signal_valid = 1'b0;
    $finish;
`SVTEST_END

`SVUNIT_TESTS_END

endmodule
