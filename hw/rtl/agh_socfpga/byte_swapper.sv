module byte_swapper(
    input logic [15:0] data_in,
    output logic [15:0] data_out
);

always_comb begin
    data_out = {data_in[7:0], data_in[15:8]};
end

endmodule