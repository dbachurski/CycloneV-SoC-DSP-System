/* Copyright (C) 2023  AGH University of Science and Technology */

`timescale 1ns/1ps

`include "svunit_defines.svh"

import svunit_pkg::svunit_testcase;

module memory_reader_unit_test;


/* Local variables and signals */

svunit_testcase svunit_ut;
string name = "memory_reader";

logic        clk, rst_n;

logic [31:0] memory_reader_readdata, memory_reader_source_data, exp_memory_reader_source_data;
logic [12:0] memory_reader_readaddress, read_address;
logic [1:0]  memory_reader_status;
logic        memory_reader_trigger, memory_reader_read, memory_reader_source_ready,
             memory_reader_source_valid, memory_reader_source_sop, memory_reader_source_eop,
             exp_memory_reader_source_sop, exp_memory_reader_source_eop;

logic [31:0] memory [8192];

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

memory_reader u_memory_reader (
    .clk,
    .rst_n,

    .memory_reader_trigger,

    .memory_reader_readaddress,
    .memory_reader_read,
    .memory_reader_readdata,

    .memory_reader_status,

    .memory_reader_source_data,
    .memory_reader_source_valid,
    .memory_reader_source_sop,
    .memory_reader_source_eop,
    .memory_reader_source_ready
);


/* Macros definition */

`define verify_memory_reader_output(index, exp_memory_reader_source_data, exp_memory_reader_source_sop,
    exp_memory_reader_source_eop) \
    assert(memory_reader_source_data == exp_memory_reader_source_data) \
        else $error("index: 0x%h, memory_reader_source_data: exp: 0x%h, rcv: 0x%h", \
            index, exp_memory_reader_source_data, memory_reader_source_data); \
    assert(memory_reader_source_sop == exp_memory_reader_source_sop) \
        else $error("memory_reader_source_sop: exp: 0x%h, rcv: 0x%h", \
            exp_memory_reader_source_sop, memory_reader_source_sop); \
    assert(memory_reader_source_eop == exp_memory_reader_source_eop) \
        else $error("memory_reader_source_eop: exp: 0x%h, rcv: 0x%h", \
            exp_memory_reader_source_eop, memory_reader_source_eop);


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
    memory_reader_readdata = 32'b0;
    memory_reader_source_ready = 1'b1;
    memory_reader_trigger = 1'b0;

    exp_memory_reader_source_data = 32'b0;
    exp_memory_reader_source_sop = 1'b0;
    exp_memory_reader_source_eop = 1'b0;

    for (int i = 0; i < 8192; i++)
        memory[i] = $random();

    @(negedge clk);
    memory_reader_trigger = 1'b1;
    #1

    fork
        begin
            @(negedge clk);
            memory_reader_trigger = 1'b0;

            for (int i = 0; i < 8192; i++) begin
                @(posedge memory_reader_source_valid);
                exp_memory_reader_source_data = memory[i];
                exp_memory_reader_source_sop = (i == 0);
                exp_memory_reader_source_eop = (i == 8191);

                `verify_memory_reader_output(i, exp_memory_reader_source_data,
                    exp_memory_reader_source_sop, exp_memory_reader_source_eop);
            end
        end
        begin
            forever begin
                if (memory_reader_read) begin
                    read_address = memory_reader_readaddress;
                    @(negedge clk);
                    memory_reader_readdata = memory[read_address];
                end
                @(negedge clk);
            end
        end
    join_any

    for (int i = 0; i < 3; i++)
        @(negedge clk);

    assert(memory_reader_status == 2'b0) else
        $error("memory_reader_status: exp: 0x%h, rcv: 0x%h",
            2'b0, memory_reader_status);
`SVTEST_END

`SVUNIT_TESTS_END

endmodule
