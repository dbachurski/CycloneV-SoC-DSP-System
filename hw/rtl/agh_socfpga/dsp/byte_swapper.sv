module byte_swapper(
    input logic [31:0] data_in,
    output logic [31:0] data_out
);

always_comb begin
    data_out = {data_in[7:0], data_in[15:8], data_in[23:16], data_in[31:24]};
end

endmodule