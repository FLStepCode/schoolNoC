`timescale 1ns/1ns

module tb_XY_mesh_synth;

    // Parameters
    parameter DATA_WIDTH  = 32;
    parameter X_DIMENSION = 4;
    parameter Y_DIMENSION = 4;
    parameter FIFO_DEPTH  = 4;
    parameter PARALLEL    = 0;

    parameter X_DIM_W     = X_DIMENSION > 1 ? $clog2(X_DIMENSION) : 1;
    parameter Y_DIM_W     = Y_DIMENSION > 1 ? $clog2(Y_DIMENSION) : 1;

    // Clock and Reset
    logic clk;
    logic arstn;

    logic [DATA_WIDTH-1:0]  data_i;
    logic                   valid_i;
    logic                   ready_o;
    logic [X_DIM_W-1:0]     source_x_i;
    logic [Y_DIM_W-1:0]     source_y_i;

    logic [DATA_WIDTH-1:0]  data_o;
    logic                   valid_o;
    logic                   ready_i;
    logic [X_DIM_W-1:0]     monitor_x_i;
    logic [Y_DIM_W-1:0]     monitor_y_i;

    // Instantiate the DUT
    XY_mesh_synth #(
        .DATA_WIDTH  (DATA_WIDTH ),
        .X_DIMENSION (X_DIMENSION),
        .Y_DIMENSION (Y_DIMENSION),
        .FIFO_DEPTH  (FIFO_DEPTH ),
        .PARALLEL    (PARALLEL   )
    ) dut (
        .clk_i       (clk),
        .arstn_i     (arstn),

        .data_i      (data_i),
        .valid_i     (valid_i),
        .ready_o     (ready_o),
        .source_x_i  (source_x_i),
        .source_y_i  (source_y_i),

        .data_o      (data_o),
        .valid_o     (valid_o),
        .ready_i     (ready_i),
        .monitor_x_i (monitor_x_i),
        .monitor_y_i (monitor_y_i)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Reset generation
    initial begin
        arstn = 0;

        data_i  = '0;
        valid_i = '0;
        ready_i = '1;

        source_x_i = 1;
        source_y_i = 1;

        monitor_x_i = 2;
        monitor_y_i = 2;

        #20;
        arstn = 1;

        @(posedge clk);
            data_i = {2'b10, 2'b10, 28'hEADBEEF};
            valid_i = '1;
        @(posedge clk);
            valid_i = '0;
        #1000;
        $stop;
    end
    
endmodule