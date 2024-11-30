module lfsr_64 (
    input logic          clk,
    input logic          rst_n,

    input logic          lsfr_reset,
    output logic [63:0]  lsfr_data
);

logic [63:0] lsfr_data_buf;
logic        feedback;


always_ff @(posedge clk) begin
    if (!rst_n) begin
        lsfr_data_buf <= 64'h0;
    end else begin
        lsfr_data_buf <= lsfr_data;
    end
end

always_comb begin
    feedback = lsfr_data_buf[63] ^ lsfr_data_buf[62] ^ lsfr_data_buf[60] ^ lsfr_data_buf[59];

    if (lsfr_reset)
        lsfr_data = {64{1'b1}};
    else
        lsfr_data = {lsfr_data_buf[62:0], feedback};
end

endmodule