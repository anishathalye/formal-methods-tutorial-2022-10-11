module fifo_impl #(
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

reg [WIDTH-1:0] data [3:0]; /* we waste a slot in this buffer */
reg [1:0] head;
reg [1:0] tail;

wire empty = head == tail;
wire full = tail + 2'h1 == head;

always @(posedge clk) begin
    if (!resetn) begin
        head <= 0;
        tail <= 0;
    end else begin
        if (wr) begin
            if (!full) begin
                data[tail] <= data_in;
                tail <= tail + 1;
            end
        end else if (rd) begin
            if (!empty) begin
                head <= head + 1; /* note that we don't clear data */
            end
        end
    end
end

always @(*) begin
    data_out = empty ? 0 : data[head];
end

endmodule
