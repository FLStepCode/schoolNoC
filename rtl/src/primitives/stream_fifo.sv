module stream_fifo #(
    parameter DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 16,

    parameter ADDR_WIDTH = $clog2(FIFO_DEPTH)
) (
    input  logic                  clk_i,
    input  logic                  arstn_i,
    
    input  logic [DATA_WIDTH-1:0] data_i,
    input  logic                  valid_i,
    output logic                  ready_o,

    output logic [DATA_WIDTH-1:0] data_o,
    output logic                  valid_o,
    input  logic                  ready_i
    
);

    logic [DATA_WIDTH-1:0] fifo_mem [FIFO_DEPTH];
    logic [ADDR_WIDTH-1:0] read_ptr, write_ptr;
    logic [ADDR_WIDTH:0] count;

    assign data_o = fifo_mem[read_ptr];

    assign valid_o = (count > 0);
    assign ready_o = !(count == FIFO_DEPTH);

    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (!arstn_i) begin
            read_ptr <= 0;
            write_ptr <= 0;
            count <= 0;
        end
        else begin
            if (valid_i && ready_o) begin
                write_ptr <= (write_ptr == (FIFO_DEPTH - 1)) ? 0 : write_ptr + 1;
            end
            if (valid_o && ready_i) begin
                read_ptr <= (read_ptr == (FIFO_DEPTH - 1)) ? 0 : read_ptr + 1;
            end

            if (valid_i && ready_o && !(valid_o && ready_i)) begin
                count <= count + 1;
            end
            else if (!(valid_i && ready_o) && (valid_o && ready_i)) begin
                count <= count - 1;
            end
        end
    end

    always @(posedge clk_i) begin
        if (valid_i && ready_o) begin
            fifo_mem[write_ptr] <= data_i;
        end
    end
    
endmodule