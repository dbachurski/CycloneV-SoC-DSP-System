module source_synchronizer (
    input logic  clk,
    input logic  rst_n,

    input logic  avalon_streaming_source_ready,
    input logic  avalon_streaming_sink_endofpacket,
    input logic  avalon_streaming_sink_valid,
    input logic  avalon_streaming_sink_startofpacket,

    output logic source_synchronizer_ready,
    output logic source_synchronizer_endofpacket,
    output logic source_synchronizer_valid,
    output logic source_synchronizer_startofpacket
);

/* Local variables */

logic ready_0, ready_0_nxt;
logic eop_0, eop_0_nxt;
logic valid_0, valid_0_nxt;
logic sop_0, sop_0_nxt;

logic ready_1, ready_1_nxt;
logic eop_1, eop_1_nxt;
logic valid_1, valid_1_nxt;
logic sop_1, sop_1_nxt;

logic ready_2, ready_2_nxt;
logic eop_2, eop_2_nxt;
logic valid_2, valid_2_nxt;
logic sop_2, sop_2_nxt;

logic ready_3, ready_3_nxt;
logic eop_3, eop_3_nxt;
logic valid_3, valid_3_nxt;
logic sop_3, sop_3_nxt;

logic ready_4, ready_4_nxt;
logic eop_4, eop_4_nxt;
logic valid_4, valid_4_nxt;
logic sop_4, sop_4_nxt;


/* Local assigments */

assign source_synchronizer_ready = ready_4;
assign source_synchronizer_endofpacket = eop_4;
assign source_synchronizer_valid = valid_4;
assign source_synchronizer_startofpacket = sop_4;


/* Internal logic */

always_ff @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        ready_0 <= 1'h0;
        eop_0 <= 1'h0;
        valid_0 <= 1'h0;
        sop_0 <= 1'h0;

        ready_1 <= 1'h0;
        eop_1 <= 1'h0;
        valid_1 <= 1'h0;
        sop_1 <= 1'h0;

        ready_2 <= 1'h0;
        eop_2 <= 1'h0;
        valid_2 <= 1'h0;
        sop_2 <= 1'h0;

        ready_3 <= 1'h0;
        eop_3 <= 1'h0;
        valid_3 <= 1'h0;
        sop_3 <= 1'h0;

        ready_4 <= 1'h0;
        eop_4 <= 1'h0;
        valid_4 <= 1'h0;
        sop_4 <= 1'h0;

    end else begin
        ready_0 <= ready_0_nxt;
        eop_0 <= eop_0_nxt;
        valid_0 <= valid_0_nxt;
        sop_0 <= sop_0_nxt;

        ready_1 <= ready_1_nxt;
        eop_1 <= eop_1_nxt;
        valid_1 <= valid_1_nxt;
        sop_1 <= sop_1_nxt;

        ready_2 <= ready_2_nxt;
        eop_2 <= eop_2_nxt;
        valid_2 <= valid_2_nxt;
        sop_2 <= sop_2_nxt;

        ready_3 <= ready_3_nxt;
        eop_3 <= eop_3_nxt;
        valid_3 <= valid_3_nxt;
        sop_3 <= sop_3_nxt;

        ready_4 <= ready_4_nxt;
        eop_4 <= eop_4_nxt;
        valid_4 <= valid_4_nxt;
        sop_4 <= sop_4_nxt;

    end
end

always_comb begin

    /* Pipeline 1 stage */
    ready_0_nxt = avalon_streaming_source_ready;
    eop_0_nxt = avalon_streaming_sink_endofpacket;
    valid_0_nxt = avalon_streaming_sink_valid;
    sop_0_nxt = avalon_streaming_sink_startofpacket;

    /* Pipeline 2 stage */
    ready_1_nxt = ready_0_nxt;
    eop_1_nxt = eop_0_nxt;
    valid_1_nxt = valid_0_nxt;
    sop_1_nxt = sop_0_nxt;

    /* Pipeline 3 stage */
    ready_2_nxt = ready_1_nxt;
    eop_2_nxt = eop_1_nxt;
    valid_2_nxt = valid_1_nxt;
    sop_2_nxt = sop_1_nxt;

    /* Pipeline 4 stage */
    ready_3_nxt = ready_2_nxt;
    eop_3_nxt = eop_2_nxt;
    valid_3_nxt = valid_2_nxt;
    sop_3_nxt = sop_2_nxt;

    /* Pipeline 5 stage */
    ready_4_nxt = ready_3_nxt;
    eop_4_nxt = eop_3_nxt;
    valid_4_nxt = valid_3_nxt;
    sop_4_nxt = sop_3_nxt;
end

endmodule

