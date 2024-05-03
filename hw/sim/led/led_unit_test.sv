/**
 * Copyright (C) 2023  AGH University of Science and Technology
 */

`timescale 1ns/1ps

`include "svunit_defines.svh"

import svunit_pkg::svunit_testcase;

module led_unit_test;


/**
 * Local variables and signals
 */

svunit_testcase svunit_ut;
string name = "led";

logic        clk, rst_n;
logic [7:0]  led;

logic [31:0] avs_s0_readdata, avs_s0_writedata;
logic [11:0] avs_s0_address;
logic [3:0]  avs_s0_byteenable;
logic [1:0]  avs_s0_response;
logic        avs_s0_waitrequest, avs_s0_readdatavalid, avs_s0_writeresponsevalid,
             avs_s0_read, avs_s0_write;


/**
 * BFMs instantiation
 */

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

altera_avalon_mm_master_bfm #(
    .AV_ADDRESS_W(12),
    .AV_SYMBOL_W(8),
    .AV_NUMSYMBOLS(4),
    .AV_BURSTCOUNT_W(3),
    .AV_READRESPONSE_W(8),
    .AV_WRITERESPONSE_W(8),

    .USE_READ(1),
    .USE_WRITE(1),
    .USE_ADDRESS(1),
    .USE_BYTE_ENABLE(1),
    .USE_BURSTCOUNT(0),
    .USE_READ_DATA(1),
    .USE_READ_DATA_VALID(1),
    .USE_WRITE_DATA(1),
    .USE_BEGIN_TRANSFER(0),
    .USE_BEGIN_BURST_TRANSFER(0),
    .USE_WAIT_REQUEST(1),
    .USE_ARBITERLOCK(0),
    .USE_LOCK(0),
    .USE_DEBUGACCESS(0),
    .USE_TRANSACTIONID(0),
    .USE_WRITERESPONSE(0),
    .USE_READRESPONSE(0),
    .USE_CLKEN(0),
    .AV_REGISTERINCOMINGSIGNALS(0),

    .AV_FIX_READ_LATENCY(0),
    .AV_MAX_PENDING_READS(0),
    .AV_MAX_PENDING_WRITES(0),

    .AV_BURST_LINEWRAP(0),
    .AV_BURST_BNDR_ONLY(0),
    .AV_CONSTANT_BURST_BEHAVIOR(1),

    .AV_READ_WAIT_TIME(0),
    .AV_WRITE_WAIT_TIME(0),

    .REGISTER_WAITREQUEST(0),
    .VHDL_ID(0),

    .PRINT_HELLO(1)
) u_altera_avalon_mm_master_bfm (
    .clk,
    .reset(~rst_n),

    .avm_waitrequest(avs_s0_waitrequest),
    .avm_readdatavalid(avs_s0_readdatavalid),
    .avm_readdata(avs_s0_readdata),
    .avm_write(avs_s0_write),
    .avm_read(avs_s0_read),
    .avm_address(avs_s0_address),
    .avm_byteenable(avs_s0_byteenable),
    .avm_burstcount(),
    .avm_beginbursttransfer(),
    .avm_begintransfer(),
    .avm_writedata(avs_s0_writedata),
    .avm_arbiterlock(),
    .avm_lock(),
    .avm_debugaccess(),

    .avm_transactionid(),
    .avm_readresponse(8'b0),
    .avm_readid(8'b0),
    .avm_writeresponserequest(),
    .avm_writeresponsevalid(avs_s0_writeresponsevalid),
    .avm_writeresponse(8'b0),
    .avm_writeid(8'b0),
    .avm_response(avs_s0_response),

    .avm_clken()
);


/**
 * Submodules placement
 */

agh_socfpga u_agh_socfpga (
    .clk,
    .rst_n,

    .avs_s0_waitrequest,
    .avs_s0_response,
    .avs_s0_readdatavalid,
    .avs_s0_writeresponsevalid,
    .avs_s0_readdata,
    .avs_s0_address,
    .avs_s0_read,
    .avs_s0_write,
    .avs_s0_byteenable,
    .avs_s0_writedata,

    .led
);


/**
 * Tasks and functions definitions
 */

function void build();
    svunit_ut = new(name);
    verbosity_pkg::set_verbosity(verbosity_pkg::VERBOSITY_WARNING);
    u_altera_avalon_mm_master_bfm.init();
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


/**
 * Test suite definition
 */

`SVUNIT_TESTS_BEGIN

`SVTEST(led_setting)
    u_altera_avalon_mm_master_bfm.set_command_address(12'h0);
    u_altera_avalon_mm_master_bfm.set_command_byte_enable(4'hf, 0);
    u_altera_avalon_mm_master_bfm.set_command_data(32'b1, 0);
    u_altera_avalon_mm_master_bfm.set_command_request(avalon_mm_pkg::REQ_WRITE);
    u_altera_avalon_mm_master_bfm.push_command();

    @(u_altera_avalon_mm_master_bfm.signal_all_transactions_complete);
    u_altera_avalon_mm_master_bfm.pop_response();

    `FAIL_UNLESS(led);
`SVTEST_END

`SVTEST(led_clearing)
    u_altera_avalon_mm_master_bfm.set_command_address(12'h0);
    u_altera_avalon_mm_master_bfm.set_command_byte_enable(4'hf, 0);
    u_altera_avalon_mm_master_bfm.set_command_data(32'b0, 0);
    u_altera_avalon_mm_master_bfm.set_command_request(avalon_mm_pkg::REQ_WRITE);
    u_altera_avalon_mm_master_bfm.push_command();

    @(u_altera_avalon_mm_master_bfm.signal_all_transactions_complete);
    u_altera_avalon_mm_master_bfm.pop_response();

    `FAIL_IF(led);
`SVTEST_END

`SVUNIT_TESTS_END

endmodule
