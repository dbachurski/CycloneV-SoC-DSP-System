module dsp
(
    input  logic               clk,
    input  logic               rst_n,

    input csr_pkg::csr__out_t  hwif_in,

    output logic               dsp_sink_ready,
    input logic [31:0]         dsp_sink_data,
    input logic                dsp_sink_valid,
    input logic                dsp_sink_sop,
    input logic                dsp_sink_eop,

    output logic [31:0]        dsp_source_data,
    output logic               dsp_source_valid,
    output logic               dsp_source_sop,
    output logic               dsp_source_eop,
    input logic                dsp_source_ready
);

/* Local variables */

logic [31:0] dsp_source_data_inverted, dsp_sink_data_inverted;

logic [31:0] fir_filter_wrapper_source_data;
logic        fir_filter_wrapper_source_valid, fir_filter_wrapper_source_sop,
             fir_filter_wrapper_source_eop, fir_filter_wrapper_sink_ready;

logic [31:0] tea_wrapper_source_data;
logic        tea_wrapper_source_valid, tea_wrapper_source_sop,
             tea_wrapper_source_eop, tea_wrapper_sink_ready;


/* Submodules placement */

byte_swapper u_byte_swapper_0 (
    .data_out(dsp_sink_data_inverted),
    .data_in(dsp_sink_data)
);

byte_swapper u_byte_swapper_1 (
    .data_out(dsp_source_data),
    .data_in(dsp_source_data_inverted)
);

fir_filter_wrapper u_fir_filter_wrapper (
    .clk,
    .rst_n,

    .hwif_in,

    .fir_filter_wrapper_source_data,
    .fir_filter_wrapper_source_valid,
    .fir_filter_wrapper_source_sop,
    .fir_filter_wrapper_source_eop,
    .fir_filter_wrapper_source_ready(dsp_source_ready),

    .fir_filter_wrapper_sink_ready,
    .fir_filter_wrapper_sink_data(dsp_sink_data_inverted),
    .fir_filter_wrapper_sink_valid(dsp_sink_valid),
    .fir_filter_wrapper_sink_sop(dsp_sink_sop),
    .fir_filter_wrapper_sink_eop(dsp_sink_eop)
);

tea_wrapper u_tea_wrapper (
    .clk,
    .rst_n,

    .hwif_in,

    .tea_wrapper_source_data,
    .tea_wrapper_source_valid,
    .tea_wrapper_source_sop,
    .tea_wrapper_source_eop,
    .tea_wrapper_source_ready(dsp_source_ready),

    .tea_wrapper_sink_ready,
    .tea_wrapper_sink_data(dsp_sink_data_inverted),
    .tea_wrapper_sink_valid(dsp_sink_valid),
    .tea_wrapper_sink_sop(dsp_sink_sop),
    .tea_wrapper_sink_eop(dsp_sink_eop)
);


/* Internal logic */

always_comb begin
    dsp_source_data_inverted = 32'b0;
    dsp_sink_ready = 1'b0;
    dsp_source_valid = 1'b0;
    dsp_source_sop = 1'b0;
    dsp_source_eop = 1'b0;

    if (hwif_in.DSP_CR.fir_enable.value) begin
        dsp_sink_ready = fir_filter_wrapper_sink_ready;
        dsp_source_valid = fir_filter_wrapper_source_valid;
        dsp_source_data_inverted = fir_filter_wrapper_source_data;
        dsp_source_sop = fir_filter_wrapper_source_sop;
        dsp_source_eop = fir_filter_wrapper_source_eop;
    end else if (hwif_in.DSP_CR.tea_enable.value) begin
        dsp_sink_ready = tea_wrapper_sink_ready;
        dsp_source_valid = tea_wrapper_source_valid;
        dsp_source_data_inverted = tea_wrapper_source_data;
        dsp_source_sop = tea_wrapper_source_sop;
        dsp_source_eop = tea_wrapper_source_eop;
    end
end

endmodule