/* Copyright (C) 2023  AGH University of Science and Technology */

`timescale 1ns/1ps

`include "svunit_defines.svh"

import svunit_pkg::svunit_testcase;

module tea_unit_test;


/* Local variables and signals */

svunit_testcase svunit_ut;
string name = "tea";

logic        clk, rst_n;

logic [63:0] tea_output_data, tea_input_data;
logic        tea_mode;

logic [31:0] memory [8192];
logic [31:0] memory_2 [8192];

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

tea u_tea (
    .clk,
    .rst_n,

    .tea_output_data,
    .tea_mode,
    .tea_input_data,
    .tea_encryption_key(64'hdead_beef_dead_beef)
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

`SVTEST(test_memory_reader)
    tea_mode = 1'b0;
    tea_input_data = 32'b0;

    for (int i = 0; i < 8192; i++)
        memory[i] = $random;

    @(negedge clk);

    fork
        begin
            for (int i = 0; i < 8192; i++) begin
                tea_input_data = memory[i];
                @(negedge clk);
            end
        end
        begin
            @(negedge clk);
            @(negedge clk);
            @(negedge clk);
            @(negedge clk);
            for (int i = 0; i < 8192; i++) begin
                #1
                memory_2[i] = tea_output_data;
                @(negedge clk);
            end
        end
    join

    tea_mode = 1'b1;
    tea_input_data = 32'b0;

    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);

    fork
        begin
            for (int i = 0; i < 8192; i++) begin
                tea_input_data = memory_2[i];
                @(negedge clk);
            end
        end
        begin
            @(negedge clk);
            @(negedge clk);
            @(negedge clk);
            @(negedge clk);
            for (int i = 0; i < 8192; i++) begin
                #1
                assert(tea_output_data == memory[i]) else
                    $error("tea_output_data: exp: 0x%h, rcv: 0x%h", memory[i], tea_output_data);
                @(negedge clk);
            end
        end
    join

`SVTEST_END

`SVUNIT_TESTS_END

endmodule
