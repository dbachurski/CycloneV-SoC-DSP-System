module fir_filter (
    input logic                clk,
    input logic                rst_n,

    input csr_pkg::csr__out_t  hwif_in,

    output logic               filtered_signal_valid,
    output logic signed [15:0] filtered_signal,

    input logic                signal_valid,
    input logic signed [15:0]  signal
);


/* Local variables */

logic signed [15:0] fir_coefficients [0:31];

logic signed [15:0] delayed_signal [0:31];
logic signed [31:0] product [0:31];
logic signed [32:0] sum_0 [0:15];
logic signed [33:0] sum_1 [0:7];
logic signed [34:0] sum_2 [0:3];
logic signed [35:0] sum_3 [0:1];
logic signed [36:0] sum_4;

logic signed [15:0] delayed_signal_nxt [0:31];
logic signed [31:0] product_nxt [0:31];
logic signed [32:0] sum_0_nxt [0:15];
logic signed [33:0] sum_1_nxt [0:7];
logic signed [34:0] sum_2_nxt [0:3];
logic signed [35:0] sum_3_nxt [0:1];
logic signed [36:0] sum_4_nxt;


/* Local assigments */

assign enable = hwif_in.DSP_CR.fir_enable.value;
assign fir_coefficients[0] = hwif_in.fir_coeff_0.val.value[15:0];
assign fir_coefficients[1] = hwif_in.fir_coeff_0.val.value[31:16];
assign fir_coefficients[2] = hwif_in.fir_coeff_1.val.value[15:0];
assign fir_coefficients[3] = hwif_in.fir_coeff_1.val.value[31:16];
assign fir_coefficients[4] = hwif_in.fir_coeff_2.val.value[15:0];
assign fir_coefficients[5] = hwif_in.fir_coeff_2.val.value[31:16];
assign fir_coefficients[6] = hwif_in.fir_coeff_3.val.value[15:0];
assign fir_coefficients[7] = hwif_in.fir_coeff_3.val.value[31:16];
assign fir_coefficients[8] = hwif_in.fir_coeff_4.val.value[15:0];
assign fir_coefficients[9] = hwif_in.fir_coeff_4.val.value[31:16];
assign fir_coefficients[10] = hwif_in.fir_coeff_5.val.value[15:0];
assign fir_coefficients[11] = hwif_in.fir_coeff_5.val.value[31:16];
assign fir_coefficients[12] = hwif_in.fir_coeff_6.val.value[15:0];
assign fir_coefficients[13] = hwif_in.fir_coeff_6.val.value[31:16];
assign fir_coefficients[14] = hwif_in.fir_coeff_7.val.value[15:0];
assign fir_coefficients[15] = hwif_in.fir_coeff_7.val.value[31:16];
assign fir_coefficients[16] = hwif_in.fir_coeff_8.val.value[15:0];
assign fir_coefficients[17] = hwif_in.fir_coeff_8.val.value[31:16];
assign fir_coefficients[18] = hwif_in.fir_coeff_9.val.value[15:0];
assign fir_coefficients[19] = hwif_in.fir_coeff_9.val.value[31:16];
assign fir_coefficients[20] = hwif_in.fir_coeff_10.val.value[15:0];
assign fir_coefficients[21] = hwif_in.fir_coeff_10.val.value[31:16];
assign fir_coefficients[22] = hwif_in.fir_coeff_11.val.value[15:0];
assign fir_coefficients[23] = hwif_in.fir_coeff_11.val.value[31:16];
assign fir_coefficients[24] = hwif_in.fir_coeff_12.val.value[15:0];
assign fir_coefficients[25] = hwif_in.fir_coeff_12.val.value[31:16];
assign fir_coefficients[26] = hwif_in.fir_coeff_13.val.value[15:0];
assign fir_coefficients[27] = hwif_in.fir_coeff_13.val.value[31:16];
assign fir_coefficients[28] = hwif_in.fir_coeff_14.val.value[15:0];
assign fir_coefficients[29] = hwif_in.fir_coeff_14.val.value[31:16];
assign fir_coefficients[30] = hwif_in.fir_coeff_15.val.value[15:0];
assign fir_coefficients[31] = hwif_in.fir_coeff_15.val.value[31:16];


/* Internal logic */

always_ff @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        for (int i = 0; i < 32; i++) begin
            delayed_signal[i] <= 16'b0;
            product[i] <= 32'b0;
        end
    end else begin
        for (int i = 0; i < 32; i++) begin
            delayed_signal[i] <= delayed_signal_nxt[i];
            product[i] <= product_nxt[i];
        end
    end
end

always_comb begin
    if (enable) begin
        for (int i = 0; i < 32; i++) begin
            delayed_signal_nxt[i] = delayed_signal[i];
            product_nxt[i] = product[i];
        end

        if (signal_valid) begin
            for (int i = 1; i < 32; i++) begin
                delayed_signal_nxt[i] = delayed_signal[i-1];
            end
            delayed_signal_nxt[0] = signal;

            for (int i = 0; i < 32; i++) begin
                product_nxt[i] = delayed_signal[i] * fir_coefficients[i];
            end
        end
    end else begin
        for (int i = 0; i < 32; i++) begin
            delayed_signal_nxt[i] = 16'b0;
            product_nxt[i] = 32'b0;
        end
    end
end

always_ff @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        sum_0[0] <= 33'b0;
        sum_0[1] <= 33'b0;
        sum_0[2] <= 33'b0;
        sum_0[3] <= 33'b0;
        sum_0[4] <= 33'b0;
        sum_0[5] <= 33'b0;
        sum_0[6] <= 33'b0;
        sum_0[7] <= 33'b0;
        sum_0[8] <= 33'b0;
        sum_0[9] <= 33'b0;
        sum_0[10] <= 33'b0;
        sum_0[11] <= 33'b0;
        sum_0[12] <= 33'b0;
        sum_0[13] <= 33'b0;
        sum_0[14] <= 33'b0;
        sum_0[15] <= 33'b0;

        sum_1[0] <= 34'b0;
        sum_1[1] <= 34'b0;
        sum_1[2] <= 34'b0;
        sum_1[3] <= 34'b0;
        sum_1[4] <= 34'b0;
        sum_1[5] <= 34'b0;
        sum_1[6] <= 34'b0;
        sum_1[7] <= 34'b0;

        sum_2[0] <= 35'b0;
        sum_2[1] <= 35'b0;
        sum_2[2] <= 35'b0;
        sum_2[3] <= 35'b0;

        sum_3[0] <= 36'b0;
        sum_3[1] <= 36'b0;

        sum_4 <= 37'b0;
    end else begin
        sum_0[0] <= sum_0_nxt[0];
        sum_0[1] <= sum_0_nxt[1];
        sum_0[2] <= sum_0_nxt[2];
        sum_0[3] <= sum_0_nxt[3];
        sum_0[4] <= sum_0_nxt[4];
        sum_0[5] <= sum_0_nxt[5];
        sum_0[6] <= sum_0_nxt[6];
        sum_0[7] <= sum_0_nxt[7];
        sum_0[8] <= sum_0_nxt[8];
        sum_0[9] <= sum_0_nxt[9];
        sum_0[10] <= sum_0_nxt[10];
        sum_0[11] <= sum_0_nxt[11];
        sum_0[12] <= sum_0_nxt[12];
        sum_0[13] <= sum_0_nxt[13];
        sum_0[14] <= sum_0_nxt[14];
        sum_0[15] <= sum_0_nxt[15];

        sum_1[0] <= sum_1_nxt[0];
        sum_1[1] <= sum_1_nxt[1];
        sum_1[2] <= sum_1_nxt[2];
        sum_1[3] <= sum_1_nxt[3];
        sum_1[4] <= sum_1_nxt[4];
        sum_1[5] <= sum_1_nxt[5];
        sum_1[6] <= sum_1_nxt[6];
        sum_1[7] <= sum_1_nxt[7];

        sum_2[0] <= sum_2_nxt[0];
        sum_2[1] <= sum_2_nxt[1];
        sum_2[2] <= sum_2_nxt[2];
        sum_2[3] <= sum_2_nxt[3];

        sum_3[0] <= sum_3_nxt[0];
        sum_3[1] <= sum_3_nxt[1];

        sum_4 <= sum_4_nxt;
    end
end

always_comb begin
    if (enable) begin
        sum_0_nxt[0] = sum_0[0];
        sum_0_nxt[1] = sum_0[1];
        sum_0_nxt[2] = sum_0[2];
        sum_0_nxt[3] = sum_0[3];
        sum_0_nxt[4] = sum_0[4];
        sum_0_nxt[5] = sum_0[5];
        sum_0_nxt[6] = sum_0[6];
        sum_0_nxt[7] = sum_0[7];
        sum_0_nxt[8] = sum_0[8];
        sum_0_nxt[9] = sum_0[9];
        sum_0_nxt[10] = sum_0[10];
        sum_0_nxt[11] = sum_0[11];
        sum_0_nxt[12] = sum_0[12];
        sum_0_nxt[13] = sum_0[13];
        sum_0_nxt[14] = sum_0[14];
        sum_0_nxt[15] = sum_0[15];
        sum_1_nxt[0] = sum_1[0];
        sum_1_nxt[1] = sum_1[1];
        sum_1_nxt[2] = sum_1[2];
        sum_1_nxt[3] = sum_1[3];
        sum_1_nxt[4] = sum_1[4];
        sum_1_nxt[5] = sum_1[5];
        sum_1_nxt[6] = sum_1[6];
        sum_1_nxt[7] = sum_1[7];
        sum_2_nxt[0] = sum_2[0];
        sum_2_nxt[1] = sum_2[1];
        sum_2_nxt[2] = sum_2[2];
        sum_2_nxt[3] = sum_2[3];
        sum_3_nxt[0] = sum_3[0];
        sum_3_nxt[1] = sum_3[1];
        sum_4_nxt = sum_4;

        if (signal_valid) begin
            /* Pipeline 1 stage */
            sum_0_nxt[0] = product[0] + product[1];
            sum_0_nxt[1] = product[2] + product[3];
            sum_0_nxt[2] = product[4] + product[5];
            sum_0_nxt[3] = product[6] + product[7];
            sum_0_nxt[4] = product[8] + product[9];
            sum_0_nxt[5] = product[10] + product[11];
            sum_0_nxt[6] = product[12] + product[13];
            sum_0_nxt[7] = product[14] + product[15];
            sum_0_nxt[8] = product[16] + product[17];
            sum_0_nxt[9] = product[18] + product[19];
            sum_0_nxt[10] = product[20] + product[21];
            sum_0_nxt[11] = product[22] + product[23];
            sum_0_nxt[12] = product[24] + product[25];
            sum_0_nxt[13] = product[26] + product[27];
            sum_0_nxt[14] = product[28] + product[29];
            sum_0_nxt[15] = product[30] + product[31];

            /* Pipeline 2 stage */
            sum_1_nxt[0] = sum_0[0] + sum_0[1];
            sum_1_nxt[1] = sum_0[2] + sum_0[3];
            sum_1_nxt[2] = sum_0[4] + sum_0[5];
            sum_1_nxt[3] = sum_0[6] + sum_0[7];
            sum_1_nxt[4] = sum_0[8] + sum_0[9];
            sum_1_nxt[5] = sum_0[10] + sum_0[11];
            sum_1_nxt[6] = sum_0[12] + sum_0[13];
            sum_1_nxt[7] = sum_0[14] + sum_0[15];

            /* Pipeline 3 stage */
            sum_2_nxt[0] = sum_1[0] + sum_1[1];
            sum_2_nxt[1] = sum_1[2] + sum_1[3];
            sum_2_nxt[2] = sum_1[4] + sum_1[5];
            sum_2_nxt[3] = sum_1[6] + sum_1[7];

            /* Pipeline 4 stage */
            sum_3_nxt[0] = sum_2[0] + sum_2[1];
            sum_3_nxt[1] = sum_2[2] + sum_2[3];

            /* Pipeline 5 stage */
            sum_4_nxt = sum_3[0] + sum_3[1];
        end
    end else begin
        sum_0_nxt[0] = 33'b0;
        sum_0_nxt[1] = 33'b0;
        sum_0_nxt[2] = 33'b0;
        sum_0_nxt[3] = 33'b0;
        sum_0_nxt[4] = 33'b0;
        sum_0_nxt[5] = 33'b0;
        sum_0_nxt[6] = 33'b0;
        sum_0_nxt[7] = 33'b0;
        sum_0_nxt[8] = 33'b0;
        sum_0_nxt[9] = 33'b0;
        sum_0_nxt[10] = 33'b0;
        sum_0_nxt[11] = 33'b0;
        sum_0_nxt[12] = 33'b0;
        sum_0_nxt[13] = 33'b0;
        sum_0_nxt[14] = 33'b0;
        sum_0_nxt[15] = 33'b0;
        sum_1_nxt[0] = 34'b0;
        sum_1_nxt[1] = 34'b0;
        sum_1_nxt[2] = 34'b0;
        sum_1_nxt[3] = 34'b0;
        sum_1_nxt[4] = 34'b0;
        sum_1_nxt[5] = 34'b0;
        sum_1_nxt[6] = 34'b0;
        sum_1_nxt[7] = 34'b0;
        sum_2_nxt[0] = 35'b0;
        sum_2_nxt[1] = 35'b0;
        sum_2_nxt[2] = 35'b0;
        sum_2_nxt[3] = 35'b0;
        sum_3_nxt[0] = 36'b0;
        sum_3_nxt[1] = 36'b0;
        sum_4_nxt = 37'b0;
    end
end

always_comb begin
    if (enable) begin
        if (signal_valid)
            filtered_signal_valid = 1'b1;
        else
            filtered_signal_valid = 1'b0;

        if ($signed(sum_4[36:14]) > $signed(16'h7FFF))
            filtered_signal = $signed(16'h7FFF);
        else if ($signed(sum_4[36:14]) < $signed(16'h8000))
            filtered_signal = $signed(16'h8000);
        else
            filtered_signal = sum_4[36:14];
    end else begin
        filtered_signal_valid = 1'b0;
        filtered_signal = 16'b0;
    end
end

endmodule

