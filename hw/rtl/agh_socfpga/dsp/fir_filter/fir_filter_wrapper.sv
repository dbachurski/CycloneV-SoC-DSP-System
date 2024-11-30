/**
 * Copyright (C) 2024  AGH University of Science and Technology
 */

module fir_filter_wrapper
(
    input  logic               clk,
    input  logic               rst_n,

    input csr_pkg::csr__out_t  hwif_in,

    output logic [31:0]        fir_filter_wrapper_source_data,
    output logic               fir_filter_wrapper_source_eop,
    output logic               fir_filter_wrapper_source_valid,
    output logic               fir_filter_wrapper_source_sop,
    input logic                fir_filter_wrapper_source_ready,

    output logic               fir_filter_wrapper_sink_ready,
    input logic [31:0]         fir_filter_wrapper_sink_data,
    input logic                fir_filter_wrapper_sink_eop,
    input logic                fir_filter_wrapper_sink_valid,
    input logic                fir_filter_wrapper_sink_sop

);


/* Submodules placement */

fir_filter u_fir_filter (
    .clk,
    .rst_n,

    .hwif_in,

    .filtered_signal_valid(fir_filter_wrapper_source_valid),
    .filtered_signal(fir_filter_wrapper_source_data),

    .signal_valid(fir_filter_wrapper_sink_valid),
    .signal(fir_filter_wrapper_sink_data)
);

source_synchronizer #(
    .N(5)
) u_source_synchronizer (
    .clk,
    .rst_n,

    .source_synchronizer_ready(fir_filter_wrapper_sink_ready),
    .source_synchronizer_endofpacket(fir_filter_wrapper_source_eop),
    // .source_synchronizer_valid,
    .source_synchronizer_startofpacket(fir_filter_wrapper_source_sop),

    .avalon_streaming_source_ready(fir_filter_wrapper_source_ready),
    .avalon_streaming_sink_endofpacket(fir_filter_wrapper_sink_eop),
    // .avalon_streaming_sink_valid,
    .avalon_streaming_sink_startofpacket(fir_filter_wrapper_sink_sop)
);

endmodule