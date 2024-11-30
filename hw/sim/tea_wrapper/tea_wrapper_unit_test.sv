/* Copyright (C) 2023  AGH University of Science and Technology */

`timescale 1ns/1ps

`include "svunit_defines.svh"

import svunit_pkg::svunit_testcase;

module tea_wrapper_unit_test;


/* Local variables and signals */

svunit_testcase svunit_ut;
string name = "tea";

logic               clk, rst_n;

csr_pkg::csr__out_t hwif_in;

logic [31:0]        tea_wrapper_source_data;
logic               tea_wrapper_source_valid, tea_wrapper_source_sop, tea_wrapper_source_eop, tea_wrapper_source_ready;

logic [31:0]        tea_wrapper_sink_data;
logic               tea_wrapper_sink_ready, tea_wrapper_sink_valid, tea_wrapper_sink_sop, tea_wrapper_sink_eop;

logic [31:0]        memory [8192];
logic [31:0]        memory_2 [8192];

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

tea_wrapper u_tea_wrapper (
    .clk,
    .rst_n,

    .hwif_in,

    .tea_wrapper_source_data,
    .tea_wrapper_source_valid,
    .tea_wrapper_source_sop,
    .tea_wrapper_source_eop,
    .tea_wrapper_source_ready,

    .tea_wrapper_sink_ready,
    .tea_wrapper_sink_data,
    .tea_wrapper_sink_valid,
    .tea_wrapper_sink_sop,
    .tea_wrapper_sink_eop
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
    int j;
    int error;

    hwif_in.DSP_CR.tea_mode.value = 1'b0;
    tea_wrapper_sink_data = 32'b0;
    tea_wrapper_sink_valid = 1'b0;
    tea_wrapper_sink_sop = 1'b0;
    tea_wrapper_sink_eop = 1'b0;

    for (int i = 0; i < 8192; i++)
        memory[i] = 192;

    @(negedge clk);

    fork
        begin
            for (int i = 0; i < 8192; i++) begin
                tea_wrapper_sink_sop = 1'b0;
                tea_wrapper_sink_eop = 1'b0;
                tea_wrapper_sink_valid = 1'b1;
                tea_wrapper_sink_data = memory[i];

                if (i == 0)
                    tea_wrapper_sink_sop = 1'b1;
                else if (i == 8191)
                    tea_wrapper_sink_eop = 1'b1;

                @(negedge clk);
            end

            tea_wrapper_sink_data = 32'b0;
            tea_wrapper_sink_valid = 1'b0;
            tea_wrapper_sink_sop = 1'b0;
            tea_wrapper_sink_eop = 1'b0;
        end
        begin
            while (j < 8192) begin
                #1
                if (tea_wrapper_source_valid) begin
                    if (j > 0 && j < 8191) begin
                        memory_2[j] = tea_wrapper_source_data;
                        j++;
                    end

                    if (tea_wrapper_source_sop == 1'b1) begin
                        memory_2[j] = tea_wrapper_source_data;
                        j++;
                    end

                    if (tea_wrapper_source_eop == 1'b1) begin
                        memory_2[j] = tea_wrapper_source_data;
                        j++;
                    end
                end
                @(negedge clk);
            end
        end
    join

    hwif_in.DSP_CR.tea_mode.value = 1'b1;
    @(negedge clk);

    fork
        begin
            for (int i = 0; i < 8192; i++) begin
                tea_wrapper_sink_sop = 1'b0;
                tea_wrapper_sink_eop = 1'b0;
                tea_wrapper_sink_valid = 1'b1;
                tea_wrapper_sink_data = memory_2[i];

                if (i == 0)
                    tea_wrapper_sink_sop = 1'b1;
                else if (i == 8191)
                    tea_wrapper_sink_eop = 1'b1;

                @(negedge clk);
            end
        end
        begin
            j = 0;
            while (j < 8192) begin
                if (tea_wrapper_source_valid) begin
                    if (j > 0 && j < 8191) begin
                        assert(tea_wrapper_source_data == memory[j]) else
                            $error("index: %d, tea_wrapper_source_data: exp: 0x%h, rcv: 0x%h", j, memory[j], tea_wrapper_source_data);
                        j++;
                    end

                    if (tea_wrapper_source_sop == 1'b1) begin
                        assert(tea_wrapper_source_data == memory[j]) else
                            $error("index: %d, tea_wrapper_source_data: exp: 0x%h, rcv: 0x%h", j, memory[j], tea_wrapper_source_data);
                        j++;
                    end

                    if (tea_wrapper_source_eop == 1'b1) begin
                        assert(tea_wrapper_source_data == memory[j]) else
                            $error("index: %d, tea_wrapper_source_data: exp: 0x%h, rcv: 0x%h", j, memory[j], tea_wrapper_source_data);
                        j++;
                    end
                end
                @(negedge clk);
            end
        end
    join

`SVTEST_END

`SVUNIT_TESTS_END

endmodule
