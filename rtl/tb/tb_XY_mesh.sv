`timescale 1ns/1ns

module tb_XY_mesh;

    // Parameters
    parameter DATA_WIDTH  = 32;
    parameter X_DIMENSION = 4;
    parameter Y_DIMENSION = 4;
    parameter FIFO_DEPTH  = 4;
    parameter PARALLEL    = 0;

    // Clock and Reset
    logic clk;
    logic arstn;

    logic [DATA_WIDTH-1:0]  data_i  [Y_DIMENSION][X_DIMENSION];
    logic [X_DIMENSION-1:0] valid_i [Y_DIMENSION];
    logic [X_DIMENSION-1:0] ready_o [Y_DIMENSION];
    logic [DATA_WIDTH-1:0]  data_o  [Y_DIMENSION][X_DIMENSION];
    logic [X_DIMENSION-1:0] valid_o [Y_DIMENSION];
    logic [X_DIMENSION-1:0] ready_i [Y_DIMENSION];

    // Instantiate the DUT
    XY_mesh #(
        .DATA_WIDTH  (DATA_WIDTH ),
        .X_DIMENSION (X_DIMENSION),
        .Y_DIMENSION (Y_DIMENSION),
        .FIFO_DEPTH  (FIFO_DEPTH ),
        .PARALLEL    (PARALLEL   )
    ) dut (
        .clk_i   (clk),
        .arstn_i (arstn),

        .data_i  (data_i ),
        .valid_i (valid_i),
        .ready_o (ready_o),
        .data_o  (data_o ),
        .valid_o (valid_o),
        .ready_i (ready_i)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Reset generation
    initial begin
        arstn = 0;
        data_i  = '{default: '{default: '0}};
        valid_i = '{default: '{default: '0}};
        ready_i = '{default: '{default: '1}};
        #20;
        arstn = 1;

        for (int i = 0; i < 50; i += 2) begin
            @(posedge clk);
            data_i[0][1] = {2'b01, 2'b11, 28'(i)};
            valid_i[0][1] = '1;
            data_i[1][0] = {2'b11, 2'b01, 28'(i+1)};
            valid_i[1][0] = '1;
        end
        @(posedge clk);
        valid_i[0][1] = '0;
        valid_i[1][0] = '0;
        #1000;
        $stop;
    end
    
endmodule