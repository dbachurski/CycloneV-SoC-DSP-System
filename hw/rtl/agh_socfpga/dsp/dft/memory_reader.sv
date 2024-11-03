module memory_reader (
    input  logic        clk,
    input  logic        rst_n,

    input logic         memory_reader_trigger,

    output logic [12:0] memory_reader_readaddress,
    output logic        memory_reader_read,
    input logic [31:0]  memory_reader_readdata,

    output logic [1:0]  memory_reader_status,

    output logic [31:0] memory_reader_source_data,
    output logic        memory_reader_source_valid,
    output logic        memory_reader_source_sop,
    output logic        memory_reader_source_eop,
    input logic         memory_reader_source_ready
);


/* Local parameters */

// localparam COUNTER_MAX_VALUE = 8192;
localparam COUNTER_MAX_VALUE = 1024;


/* User defined types */

typedef enum logic [1:0] {
    IDLE,
    MEMORY_READOUT,
    DATA_TRANSMISSION
} state_t;


/* Local variables */

state_t      state, state_nxt;

logic [31:0] data, data_nxt;
logic [13:0] counter, counter_nxt;


/* Signal assigments */

assign memory_reader_status = state;


/* Internal logic */

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
    end else begin
        state <= state_nxt;
    end
end

always_comb begin
    state_nxt = state;

    case (state)
    IDLE: begin
        if (memory_reader_trigger)
            state_nxt = MEMORY_READOUT;
    end
    MEMORY_READOUT: begin
        state_nxt = DATA_TRANSMISSION;
    end
    DATA_TRANSMISSION: begin
        if (memory_reader_source_ready) begin
            state_nxt = MEMORY_READOUT;

            if (counter == COUNTER_MAX_VALUE)
                state_nxt = IDLE;
        end
    end
    endcase
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data <= 32'b0;
        counter <= 14'b0;
    end else begin
        data <= data_nxt;
        counter <= counter_nxt;
    end
end

always_comb begin
    memory_reader_readaddress = 13'b0;
    memory_reader_read = 1'b0;
    memory_reader_source_data = 32'b0;
    memory_reader_source_valid = 1'b0;
    memory_reader_source_sop = 1'b0;
    memory_reader_source_eop = 1'b0;

    data_nxt = data;
    counter_nxt = counter;

    case (state)
    IDLE: begin
        if (memory_reader_trigger) begin
            memory_reader_readaddress = counter;
            memory_reader_read = 1'b1;
        end
    end
    MEMORY_READOUT: begin
        counter_nxt = counter + 1;
        data_nxt = memory_reader_readdata;
    end
    DATA_TRANSMISSION: begin
        if (memory_reader_source_ready) begin
            if (counter == 14'b1)
                memory_reader_source_sop = 1'b1;
            else if (counter == COUNTER_MAX_VALUE)
                memory_reader_source_eop = 1'b1;

            memory_reader_source_valid = 1'b1;
            memory_reader_source_data = data;

            memory_reader_readaddress = counter;
            memory_reader_read = 1'b1;
        end
    end
    endcase
end

endmodule
