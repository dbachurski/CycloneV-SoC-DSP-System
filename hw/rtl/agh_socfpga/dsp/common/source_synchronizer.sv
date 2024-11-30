module source_synchronizer #(
    parameter N = 5
)(
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

logic [N-1:0] ready;
logic [N-1:0] eop;
logic [N-1:0] valid;
logic [N-1:0] sop;


/* Local assignments */

assign source_synchronizer_ready = ready[N-1];
assign source_synchronizer_endofpacket = eop[N-1];
assign source_synchronizer_valid = valid[N-1];
assign source_synchronizer_startofpacket = sop[N-1];


/* Internal logic */

always_ff @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin
        ready <= {N{1'b0}};
        eop <= {N{1'b0}};
        valid <= {N{1'b0}};
        sop <= {N{1'b0}};
    end else begin
        ready[0] <= avalon_streaming_source_ready;
        eop[0] <= avalon_streaming_sink_endofpacket;
        valid[0] <= avalon_streaming_sink_valid;
        sop[0] <= avalon_streaming_sink_startofpacket;

        for (int i = 1; i < N; i++) begin
            ready[i] <= ready[i-1];
            eop[i] <= eop[i-1];
            valid[i] <= valid[i-1];
            sop[i] <= sop[i-1];
        end
    end
end

endmodule