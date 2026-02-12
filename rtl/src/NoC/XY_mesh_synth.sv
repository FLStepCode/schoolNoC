module XY_mesh_synth #(
    parameter DATA_WIDTH  = 32,
    parameter X_DIMENSION = 4,
    parameter Y_DIMENSION = 4,
    parameter FIFO_DEPTH  = 4,
    parameter PARALLEL    = 0,

    parameter X_DIM_W     = X_DIMENSION > 1 ? $clog2(X_DIMENSION) : 1,
    parameter Y_DIM_W     = Y_DIMENSION > 1 ? $clog2(Y_DIMENSION) : 1
) (
    input  logic                  clk_i,
    input  logic                  arstn_i,

    input  logic [DATA_WIDTH-1:0] data_i,
    input  logic                  valid_i,
    output logic                  ready_o,
    input  logic [X_DIM_W-1:0]    source_x_i,
    input  logic [Y_DIM_W-1:0]    source_y_i,

    output logic [DATA_WIDTH-1:0] data_o,
    output logic                  valid_o,
    input  logic                  ready_i,
    input  logic [X_DIM_W-1:0]    monitor_x_i,
    input  logic [Y_DIM_W-1:0]    monitor_y_i
);

    logic [DATA_WIDTH-1:0]  noc_data_i  [Y_DIMENSION][X_DIMENSION];
    logic [X_DIMENSION-1:0] noc_valid_i [Y_DIMENSION];
    logic [X_DIMENSION-1:0] noc_ready_o [Y_DIMENSION];

    logic [DATA_WIDTH-1:0]  noc_data_o  [Y_DIMENSION][X_DIMENSION];
    logic [X_DIMENSION-1:0] noc_valid_o [Y_DIMENSION];
    logic [X_DIMENSION-1:0] noc_ready_i [Y_DIMENSION];


    generate
        genvar i, j;

        for (i = 0; i < Y_DIMENSION; i++) begin : fill_rows
            for (j = 0; j < X_DIMENSION; j++) begin : fill_cols
                assign noc_data_i [i][j] = (i == source_y_i && j == source_x_i) ? data_i : '0;
                assign noc_valid_i[i][j] = (i == source_y_i && j == source_x_i) ? valid_i : '0;
                assign noc_ready_i[i][j] = (i == monitor_y_i && j == monitor_x_i) ? ready_i : '1;
            end
        end
    endgenerate

    assign data_o = noc_data_o[monitor_y_i][monitor_x_i];
    assign valid_o = noc_valid_o[monitor_y_i][monitor_x_i];
    assign ready_o = noc_ready_o[source_y_i][source_x_i];
    
    XY_mesh #(
        .DATA_WIDTH  (DATA_WIDTH ),
        .X_DIMENSION (X_DIMENSION),
        .Y_DIMENSION (Y_DIMENSION),
        .FIFO_DEPTH  (FIFO_DEPTH ),
        .PARALLEL    (PARALLEL   )
    ) dut (
        .clk_i  (clk_i  ),
        .arstn_i(arstn_i),

        .data_i (noc_data_i ),
        .valid_i(noc_valid_i),
        .ready_o(noc_ready_o),

        .data_o (noc_data_o ),
        .valid_o(noc_valid_o),
        .ready_i(noc_ready_i)
    );
    
endmodule