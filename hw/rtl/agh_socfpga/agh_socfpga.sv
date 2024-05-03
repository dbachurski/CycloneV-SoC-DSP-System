/**
 * Copyright (C) 2024  AGH University of Science and Technology
 */

module agh_socfpga
    import csr_pkg::*;
(
    input  logic        clk,
    input  logic        rst_n,

    output logic        avs_s0_waitrequest,
    output logic [1:0]  avs_s0_response,
    output logic        avs_s0_readdatavalid,
    output logic        avs_s0_writeresponsevalid,
    output logic [31:0] avs_s0_readdata,
    input logic [11:0]  avs_s0_address,
    input logic         avs_s0_read,
    input logic         avs_s0_write,
    input logic [3:0]   avs_s0_byteenable,
    input logic [31:0]  avs_s0_writedata,

    output logic [7:0]  led
);


/**
 * Local variables and signals
 */

csr__out_t   hwif_out;

logic [31:0] avs_s0_readdata_nxt;
logic        avs_s0_readdatavalid_nxt, avs_s0_writeresponsevalid_nxt;


/**
 * Signals assignments
 */

assign led = hwif_out.IO_CR.val.value;


/**
 * Submodules placement
 */

csr u_csr (
    .clk,
    .arst_n(rst_n),

    .avalon_waitrequest(avs_s0_waitrequest),
    .avalon_response(avs_s0_response),
    .avalon_readdatavalid(avs_s0_readdatavalid_nxt),
    .avalon_writeresponsevalid(avs_s0_writeresponsevalid_nxt),
    .avalon_readdata(avs_s0_readdata_nxt),
    .avalon_address(avs_s0_address[11:2]),
    .avalon_read(avs_s0_read),
    .avalon_write(avs_s0_write),
    .avalon_byteenable(avs_s0_byteenable),
    .avalon_writedata(avs_s0_writedata),

    .hwif_out
);


/**
 * Module internal logic
 */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        avs_s0_readdatavalid <= 1'b0;
        avs_s0_writeresponsevalid <= 1'b0;
        avs_s0_readdata <= 32'b0;
    end else begin
        avs_s0_readdatavalid <= avs_s0_readdatavalid_nxt;
        avs_s0_writeresponsevalid <= avs_s0_writeresponsevalid_nxt;
        avs_s0_readdata <= avs_s0_readdata_nxt;
    end
end

endmodule
