module XY_mesh #(
    parameter DATA_WIDTH  = 32,
    parameter X_DIMENSION = 4,
    parameter Y_DIMENSION = 4,
    parameter FIFO_DEPTH  = 4,
    parameter PARALLEL    = 0
) (
    input  logic                   clk_i,
    input  logic                   arstn_i,

    input  logic [DATA_WIDTH-1:0]  data_i  [Y_DIMENSION][X_DIMENSION],
    input  logic [X_DIMENSION-1:0] valid_i [Y_DIMENSION],
    output logic [X_DIMENSION-1:0] ready_o [Y_DIMENSION],

    output logic [DATA_WIDTH-1:0]  data_o  [Y_DIMENSION][X_DIMENSION],
    output logic [X_DIMENSION-1:0] valid_o [Y_DIMENSION],
    input  logic [X_DIMENSION-1:0] ready_i [Y_DIMENSION]
);

    logic [DATA_WIDTH-1:0] router_data_o  [Y_DIMENSION][X_DIMENSION][5];
    logic [4:0]            router_valid_o [Y_DIMENSION][X_DIMENSION];
    logic [4:0]            router_ready_o [Y_DIMENSION][X_DIMENSION];

    generate
        genvar i, j;

        for (i = 0; i < Y_DIMENSION; i++) begin : generate_rows
            for (j = 0; j < X_DIMENSION; j++) begin : generate_cols

                logic [DATA_WIDTH-1:0] router_data_i  [5];
                logic [4:0]            router_valid_i;
                logic [4:0]            router_ready_i;

                assign router_data_i [0] = data_i [i][j];
                assign router_valid_i[0] = valid_i[i][j];
                assign router_ready_i[0] = ready_i[i][j];
                assign data_o [i][j] = router_data_o [i][j][0];
                assign valid_o[i][j] = router_valid_o[i][j][0];
                assign ready_o[i][j] = router_ready_o[i][j][0];

                assign router_data_i [1] = (i == 0)             ? '0 : router_data_o [i-1][j][3];
                assign router_valid_i[1] = (i == 0)             ? '0 : router_valid_o[i-1][j][3];
                assign router_ready_i[1] = (i == 0)             ? '1 : router_ready_o[i-1][j][3];

                assign router_data_i [2] = (j == X_DIMENSION-1) ? '0 : router_data_o [i][j+1][4];
                assign router_valid_i[2] = (j == X_DIMENSION-1) ? '0 : router_valid_o[i][j+1][4];
                assign router_ready_i[2] = (j == X_DIMENSION-1) ? '1 : router_ready_o[i][j+1][4];

                assign router_data_i [3] = (i == Y_DIMENSION-1) ? '0 : router_data_o [i+1][j][1];
                assign router_valid_i[3] = (i == Y_DIMENSION-1) ? '0 : router_valid_o[i+1][j][1];
                assign router_ready_i[3] = (i == Y_DIMENSION-1) ? '1 : router_ready_o[i+1][j][1];

                assign router_data_i [4] = (j == 0)             ? '0 : router_data_o [i][j-1][2];
                assign router_valid_i[4] = (j == 0)             ? '0 : router_valid_o[i][j-1][2];
                assign router_ready_i[4] = (j == 0)             ? '1 : router_ready_o[i][j-1][2];

                if (PARALLEL) begin : parallel_router
                    router_XY_mesh_parallel #(
                        .DATA_WIDTH  (DATA_WIDTH),
                        .CHANNEL_NUM (5),
                        .FIFO_DEPTH  (FIFO_DEPTH),

                        .X_WIDTH     ($clog2(X_DIMENSION)),
                        .Y_WIDTH     ($clog2(Y_DIMENSION)),
                        .SOURCE_X    (j),
                        .SOURCE_Y    (i)
                    ) u_router_XY_mesh (
                        .clk_i   (clk_i),
                        .arstn_i (arstn_i),

                        .data_i  (router_data_i),
                        .valid_i (router_valid_i),
                        .ready_o (router_ready_o[i][j]),

                        .data_o  (router_data_o[i][j]),
                        .valid_o (router_valid_o[i][j]),
                        .ready_i (router_ready_i)
                    );
                end
                else begin : sequential_router
                    router_XY_mesh #(
                        .DATA_WIDTH  (DATA_WIDTH),
                        .CHANNEL_NUM (5),
                        .FIFO_DEPTH  (FIFO_DEPTH),

                        .X_WIDTH     ($clog2(X_DIMENSION)),
                        .Y_WIDTH     ($clog2(Y_DIMENSION)),
                        .SOURCE_X    (j),
                        .SOURCE_Y    (i)
                    ) u_router_XY_mesh (
                        .clk_i   (clk_i),
                        .arstn_i (arstn_i),

                        .data_i  (router_data_i),
                        .valid_i (router_valid_i),
                        .ready_o (router_ready_o[i][j]),

                        .data_o  (router_data_o[i][j]),
                        .valid_o (router_valid_o[i][j]),
                        .ready_i (router_ready_i)
                    );
                end

            end
        end
    endgenerate
    
endmodule