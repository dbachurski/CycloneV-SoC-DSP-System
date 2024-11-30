module tea #(
    parameter NUM_STAGES = 4
)(
    input  logic        clk,
    input  logic        rst_n,

    output logic [31:0] tea_output_data,
    input logic         tea_mode,
    input logic [31:0]  tea_input_data,
    input logic [63:0]  tea_encryption_key
);


/* Local parameters */

localparam DELTA = 16'h9e37;


/* User defined types */

typedef enum logic {
    ENCRYPT,
    DECRYPT
} state_t;


/* Local variables */

state_t            state, state_nxt;

logic [15:0]       key [0:3] [NUM_STAGES-1:0];
logic [15:0]       left_data_block [NUM_STAGES-1:0];
logic [15:0]       right_data_block [NUM_STAGES-1:0];
logic [15:0]       round_sum [NUM_STAGES-1:0];

logic [15:0]       key_nxt [0:3] [NUM_STAGES-1:0];
logic [15:0]       left_data_block_nxt [NUM_STAGES-1:0];
logic [15:0]       right_data_block_nxt [NUM_STAGES-1:0];
logic [15:0]       round_sum_nxt [NUM_STAGES-1:0];


/* Signal assigments */

assign tea_output_data = {right_data_block[NUM_STAGES-1], left_data_block[NUM_STAGES-1]};


/* Internal logic */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= ENCRYPT;
    end else begin
        state <= state_nxt;
    end
end

always_comb begin
    state_nxt = state;

    case (state)
    ENCRYPT: begin
        if (tea_mode == 1)
            state_nxt = DECRYPT;
    end
    DECRYPT: begin
        if (tea_mode == 0)
            state_nxt = ENCRYPT;
    end
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (int i = 0; i < NUM_STAGES; i++) begin
            round_sum[i] <= 16'b0;
            left_data_block[i] <= 16'b0;
            right_data_block[i] <= 16'b0;
            key[0][i] <= 16'b0;
            key[1][i] <= 16'b0;
            key[2][i] <= 16'b0;
            key[3][i] <= 16'b0;
        end
    end else begin
        for (int i = 0; i < NUM_STAGES; i++) begin
            round_sum[i] <= round_sum_nxt[i];
            left_data_block[i] <= left_data_block_nxt[i];
            right_data_block[i] <= right_data_block_nxt[i];
            key[0][i] <= key_nxt[0][i];
            key[1][i] <= key_nxt[1][i];
            key[2][i] <= key_nxt[2][i];
            key[3][i] <= key_nxt[3][i];
        end
    end
end

always_comb begin
    round_sum_nxt[0] = 16'b0;
    left_data_block_nxt[0] = tea_input_data[15:0];
    right_data_block_nxt[0] = tea_input_data[31:16];
    key_nxt[0][0] = tea_encryption_key[15:0];
    key_nxt[1][0] = tea_encryption_key[31:16];
    key_nxt[2][0] = tea_encryption_key[47:32];
    key_nxt[3][0] = tea_encryption_key[63:48];

    for (int i = 1; i < NUM_STAGES; i++) begin
        round_sum_nxt[i] = round_sum[i-1];
        left_data_block_nxt[i] = left_data_block[i-1];
        right_data_block_nxt[i] = right_data_block[i-1];
        key_nxt[0][i] = key[0][i-1];
        key_nxt[1][i] = key[1][i-1];
        key_nxt[2][i] = key[2][i-1];
        key_nxt[3][i] = key[3][i-1];
    end

    case (state)
    ENCRYPT: begin
        for (int i = 0; i < (NUM_STAGES); i++) begin
            for (int j = 0; j < (32/(NUM_STAGES)); j++) begin
                round_sum_nxt[i] += DELTA;
                left_data_block_nxt[i] += ((right_data_block_nxt[i]<<4) + key_nxt[0][i]) ^
                    (right_data_block_nxt[i] + round_sum_nxt[i]) ^
                    ((right_data_block_nxt[i]>>5) + key_nxt[1][i]);

                right_data_block_nxt[i] += ((left_data_block_nxt[i]<<4) + key_nxt[2][i]) ^
                    (left_data_block_nxt[i] + round_sum_nxt[i]) ^
                    ((left_data_block_nxt[i]>>5) + key_nxt[3][i]);
            end
        end
    end
    DECRYPT: begin
        round_sum_nxt[0] = 16'hC6E0;

        for (int i = 0; i < (NUM_STAGES); i++) begin
            for (int j = 0; j < (32/(NUM_STAGES)); j++) begin
                right_data_block_nxt[i] -= ((left_data_block_nxt[i]<<4) + key_nxt[2][i]) ^
                    (left_data_block_nxt[i] + round_sum_nxt[i]) ^
                    ((left_data_block_nxt[i]>>5) + key_nxt[3][i]);

                left_data_block_nxt[i] -= ((right_data_block_nxt[i]<<4) + key_nxt[0][i]) ^
                    (right_data_block_nxt[i] + round_sum_nxt[i]) ^
                    ((right_data_block_nxt[i]>>5) + key_nxt[1][i]);
                round_sum_nxt[i] -= DELTA;
            end
        end
    end
    endcase
end

endmodule
