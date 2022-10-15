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

reg [WIDTH-1:0] data [2:0];
reg [1:0] len;

wire empty = len == 2'd0;
wire full = len == 2'd3;

integer i;

always @(posedge clk) begin
    if (!resetn) begin
        len <= 0;
    end else begin
        if (wr) begin
            if (!full) begin
                data[len] <= data_in;
                len <= len + 1;
            end
        end else if (rd) begin
            if (!empty) begin
                /* shift all the data */
                for (i = 0; i < 2; i++) begin
                    /* multi-port memory! good for a spec, but not for an
                     * implementation */
                    data[i] <= data[i+1];
                end
                /* would be more inefficient if we had a bigger fifo... */
                len <= len - 1;
            end
        end
    end
end

always @(*) begin
    data_out = empty ? 0 : data[0];
end

endmodule
