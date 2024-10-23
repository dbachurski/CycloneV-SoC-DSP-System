/**
 * Copyright (C) 2024  AGH University of Science and Technology
 */

module agh_socfpga
    import csr_pkg::*;
(
    input  logic        clk,
    input  logic        rst_n,

    /* Avalon MM slave interface */

    output logic        avalon_mm_slave_waitrequest,
    output logic [1:0]  avalon_mm_slave_response,
    output logic        avalon_mm_slave_readdatavalid,
    output logic        avalon_mm_slave_writeresponsevalid,
    output logic [31:0] avalon_mm_slave_readdata,
    input logic [11:0]  avalon_mm_slave_address,
    input logic         avalon_mm_slave_read,
    input logic         avalon_mm_slave_write,
    input logic [3:0]   avalon_mm_slave_byteenable,
    input logic [31:0]  avalon_mm_slave_writedata,


    /* Avalon Streaming Sink interface */

    output logic        avalon_streaming_sink_ready,
    input logic [31:0]  avalon_streaming_sink_data,
    input logic         avalon_streaming_sink_valid,
    input logic         avalon_streaming_sink_startofpacket,
    input logic         avalon_streaming_sink_endofpacket,


    /* Avalon Streaming Source interface */

    output logic [31:0] avalon_streaming_source_data,
    output logic        avalon_streaming_source_valid,
    output logic        avalon_streaming_source_startofpacket,
    output logic        avalon_streaming_source_endofpacket,
    input logic         avalon_streaming_source_ready,

    output logic [7:0]  led
);


/* Local variables and signals */

csr__out_t   hwif_out;

logic [31:0] avalon_mm_slave_readdata_nxt;
logic        avalon_mm_slave_readdatavalid_nxt, avalon_mm_slave_writeresponsevalid_nxt;

logic [31:0] dsp_sink_data, dsp_source_data;
logic        dsp_sink_ready, dsp_sink_valid, dsp_sink_sop, dsp_sink_eop, dsp_source_valid,
             dsp_source_sop, dsp_source_eop, dsp_source_ready;


/* Signals assignments */

assign led = hwif_out.IO_CR.val.value;


/* Submodules placement */

csr u_csr (
    .clk,
    .arst_n(rst_n),

    .hwif_out,

    .avalon_waitrequest(avalon_mm_slave_waitrequest),
    .avalon_response(avalon_mm_slave_response),
    .avalon_readdatavalid(avalon_mm_slave_readdatavalid_nxt),
    .avalon_writeresponsevalid(avalon_mm_slave_writeresponsevalid_nxt),
    .avalon_readdata(avalon_mm_slave_readdata_nxt),
    .avalon_address(avalon_mm_slave_address),
    .avalon_read(avalon_mm_slave_read),
    .avalon_write(avalon_mm_slave_write),
    .avalon_byteenable(avalon_mm_slave_byteenable),
    .avalon_writedata(avalon_mm_slave_writedata)
);

dsp u_dsp (
    .clk,
    .rst_n,

    .hwif_in(hwif_out),

    .dsp_sink_ready,
    .dsp_sink_data(avalon_streaming_sink_data),
    .dsp_sink_valid(avalon_streaming_sink_valid),
    .dsp_sink_sop(avalon_streaming_sink_startofpacket),
    .dsp_sink_eop(avalon_streaming_sink_endofpacket),

    .dsp_source_data,
    .dsp_source_valid,
    .dsp_source_sop,
    .dsp_source_eop,
    .dsp_source_ready(avalon_streaming_source_ready)
);


/* Internal logic */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        avalon_mm_slave_readdatavalid <= 1'b0;
        avalon_mm_slave_writeresponsevalid <= 1'b0;
        avalon_mm_slave_readdata <= 32'b0;
    end else begin
        avalon_mm_slave_readdatavalid <= avalon_mm_slave_readdatavalid_nxt;
        avalon_mm_slave_writeresponsevalid <= avalon_mm_slave_writeresponsevalid_nxt;
        avalon_mm_slave_readdata <= avalon_mm_slave_readdata_nxt;
    end
end

always_comb begin
    if(hwif_out.DSP_CR.fir_enable.value || hwif_out.DSP_CR.dft_enable.value) begin
        avalon_streaming_sink_ready = dsp_sink_ready;
        avalon_streaming_source_valid = dsp_source_valid;
        avalon_streaming_source_data = dsp_source_data;
        avalon_streaming_source_startofpacket = dsp_source_sop;
        avalon_streaming_source_endofpacket = dsp_source_eop;
    end else begin
        avalon_streaming_sink_ready = avalon_streaming_source_ready;
        avalon_streaming_source_valid = avalon_streaming_sink_valid;
        avalon_streaming_source_data = avalon_streaming_sink_data;
        avalon_streaming_source_startofpacket = avalon_streaming_sink_startofpacket;
        avalon_streaming_source_endofpacket = avalon_streaming_sink_endofpacket;
    end
end


endmodule