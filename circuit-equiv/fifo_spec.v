module fifo_spec #(
    parameter WIDTH = 32
) (
    input clk,
    input resetn,
    input rd,
    input wr,
    input [WIDTH-1:0] data_in,
    output full,
    output empty,
    output [WIDTH-1:0] data_out
);

reg [3*WIDTH-1:0] data; /* packed to work around a yosys bug */
reg [1:0] len;

wire empty = len == 2'd0;
wire full = len == 2'd3;

always @(posedge clk) begin
    if (!resetn) begin
        len <= 0;
    end else begin
        if (wr) begin
            if (!full) begin
                data[WIDTH*(3-len)-1:WIDTH*(2-len)] <= data_in;
                len <= len + 1;
            end
        end else if (rd) begin
            if (!empty) begin
                /* shift all the data */
                data <= {data[2*WIDTH-1:0], WIDTH'd0};
                /* would be more inefficient if we had a bigger fifo... */
                len <= len - 1;
            end
        end
    end
end

always @(*) begin
    data_out = empty ? 0 : data[3*WIDTH-1:2*WIDTH];
end

endmodule
