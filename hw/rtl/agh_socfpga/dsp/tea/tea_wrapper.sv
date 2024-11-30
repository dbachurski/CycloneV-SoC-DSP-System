module tea_wrapper
    import csr_pkg::*;
(
    input logic               clk,
    input logic               rst_n,

    input csr_pkg::csr__out_t hwif_in,

    output logic [31:0]       tea_wrapper_source_data,
    output logic              tea_wrapper_source_valid,
    output logic              tea_wrapper_source_sop,
    output logic              tea_wrapper_source_eop,
    input logic               tea_wrapper_source_ready,

    output logic              tea_wrapper_sink_ready,
    input logic [31:0]        tea_wrapper_sink_data,
    input logic               tea_wrapper_sink_valid,
    input logic               tea_wrapper_sink_sop,
    input logic               tea_wrapper_sink_eop
);


/* Local variables */

logic [63:0] lsfr_data;
logic        lsfr_reset;


/* Signal assigments */

assign lsfr_reset = tea_wrapper_sink_sop;


/* Submodules placement */

tea #(
    .NUM_STAGES(16)
) u_tea (
    .clk,
    .rst_n,

    .tea_output_data(tea_wrapper_source_data),
    .tea_mode(hwif_in.DSP_CR.tea_mode.value),
    .tea_input_data(tea_wrapper_sink_data),
    .tea_encryption_key(lsfr_data)
);

lfsr_64 u_lsfr_64 (
    .clk,
    .rst_n,

    .lsfr_reset,
    .lsfr_data
);

source_synchronizer #(
    .N(16)
) u_source_synchronizer (
    .clk,
    .rst_n,

    .source_synchronizer_ready(tea_wrapper_sink_ready),
    .source_synchronizer_endofpacket(tea_wrapper_source_eop),
    .source_synchronizer_valid(tea_wrapper_source_valid),
    .source_synchronizer_startofpacket(tea_wrapper_source_sop),

    .avalon_streaming_source_ready(tea_wrapper_source_ready),
    .avalon_streaming_sink_endofpacket(tea_wrapper_sink_eop),
    .avalon_streaming_sink_valid(tea_wrapper_sink_valid),
    .avalon_streaming_sink_startofpacket(tea_wrapper_sink_sop)
);

endmodule
