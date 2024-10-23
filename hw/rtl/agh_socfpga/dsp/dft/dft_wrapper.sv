module dft_wrapper
    import csr_pkg::*;
(
    input logic               clk,
    input logic               rst_n,

    output csr_pkg::csr__in_t hwif_out,
    input csr_pkg::csr__out_t hwif_in,

    output logic [31:0]       dft_wrapper_source_data,
    output logic              dft_wrapper_source_valid,
    output logic              dft_wrapper_source_sop,
    output logic              dft_wrapper_source_eop,
    input logic               dft_wrapper_source_ready,

    output logic              dft_wrapper_sink_ready,
    input logic [31:0]        dft_wrapper_sink_data,
    input logic               dft_wrapper_sink_valid,
    input logic               dft_wrapper_sink_sop,
    input logic               dft_wrapper_sink_eop,

    output logic              dft_wrapper_error,
    input logic [16:0]        dft_wrapper_number_of_points
);


/* Local variables */

logic [31:0] memory_reader_readdata;
logic [12:0] memory_reader_readaddress;
logic        memory_reader_trigger, memory_reader_read;


/* Submodules placement */

r2fft_impl u_r2fft_impl (
    .clk(clk),
    .rst_i(rst_i),

    .autorun_i(1'b1),
    .run_i(1'b0),
    .fin_i(hwif_in.DSP_CR.dft_reset.value),
    .ifft_i(1'b0),

    .done_o(memory_reader_trigger),
    .status_o(hwif_out.DSP_SR.dft_status.next),
    .bfpexp_o(8'b0),

    .sact_istream_i(dft_wrapper_sink_valid),
    .sdw_istream_real_i(dft_wrapper_sink_data[15:0]),
    .sdw_istream_imag_i(dft_wrapper_sink_data[31:16]),

    .dmaact_i(memory_reader_read),
    .dmaa_i(memory_reader_readaddress),
    .dmadr_real_o(memory_reader_readdata[15:0]),
    .dmadr_imag_o(memory_reader_readdata[31:16])
);

memory_reader u_memory_reader (
    .clk,
    .rst_n,

    .memory_reader_trigger,

    .memory_reader_readaddress,
    .memory_reader_read,
    .memory_reader_readdata,

    .memory_reader_source_data(dft_wrapper_source_data),
    .memory_reader_source_valid(dft_wrapper_source_valid),
    .memory_reader_source_sop(dft_wrapper_source_sop),
    .memory_reader_source_eop(dft_wrapper_source_eop),
    .memory_reader_source_ready(dft_wrapper_source_ready)
);

endmodule

// always_comb begin
//     if ($signed(output_data_real[30:14]) > $signed(16'h7FFF))
//         dft_wrapper_source_data[15:0] = $signed(16'h7FFF);
//     else if ($signed(output_data_real[30:14]) < $signed(16'h8000))
//         dft_wrapper_source_data[15:0] = $signed(16'h8000);
//     else;
//         dft_wrapper_source_data[15:0] = output_data_real[30:14];

//     if ($signed(output_data_imag[30:14]) > $signed(16'h7FFF))
//         dft_wrapper_source_data[31:16] = $signed(16'h7FFF);
//     else if ($signed(output_data_imag[30:14]) < $signed(16'h8000))
//         dft_wrapper_source_data[31:16] = $signed(16'h8000);
//     else
//         dft_wrapper_source_data[31:16] = output_data_imag[30:14];
// end

// dft u_dft (
//     .clk(clk),
//     .reset_n(rst_n),
//     .sink_valid(dft_wrapper_sink_valid),
//     .sink_ready(dft_wrapper_sink_ready),
//     .sink_error(1'b0),
//     .sink_sop(dft_wrapper_sink_sop),
//     .sink_eop(dft_wrapper_sink_eop),
//     .sink_real(dft_wrapper_sink_data),
//     .sink_imag(16'b0),
//     .fftpts_in(dft_wrapper_number_of_points),
//     .inverse(1'b0),
//     .source_valid(dft_wrapper_source_valid),
//     .source_ready(dft_wrapper_source_ready),
//     .source_error(dft_wrapper_error),
//     .source_sop(dft_wrapper_source_sop),
//     .source_eop(dft_wrapper_source_eop),
//     .source_real(output_data_real),
//     .source_imag(output_data_imag),
//     .fftpts_out()
// );