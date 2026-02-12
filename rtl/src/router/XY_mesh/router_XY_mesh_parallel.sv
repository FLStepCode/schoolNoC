module router_XY_mesh_parallel #(
    parameter DATA_WIDTH  = 32,
    parameter CHANNEL_NUM = 5,
    parameter FIFO_DEPTH  = 4,

    parameter X_WIDTH     = 2,
    parameter Y_WIDTH     = 2,
    parameter SOURCE_X    = 1,
    parameter SOURCE_Y    = 1
) (
    input  logic                   clk_i,
    input  logic                   arstn_i,

    input  logic [DATA_WIDTH-1:0]  data_i [CHANNEL_NUM],
    input  logic [CHANNEL_NUM-1:0] valid_i,
    output logic [CHANNEL_NUM-1:0] ready_o,

    output logic [DATA_WIDTH-1:0]  data_o [CHANNEL_NUM],
    output logic [CHANNEL_NUM-1:0] valid_o,
    input  logic [CHANNEL_NUM-1:0] ready_i
);

    logic [DATA_WIDTH-1:0] fifo_data_rd [CHANNEL_NUM];
    logic [CHANNEL_NUM-1:0] fifo_valid_rd, fifo_ready_rd;

    logic [DATA_WIDTH-1:0]  algorithm_data_rd [CHANNEL_NUM][CHANNEL_NUM];
    logic [CHANNEL_NUM-1:0] algorithm_valid_rd [CHANNEL_NUM];
    logic [CHANNEL_NUM-1:0] algorithm_ready_rd [CHANNEL_NUM];

    generate
        genvar i, j;
        for (i = 0; i < CHANNEL_NUM; i++) begin : generate_queues
            stream_fifo #(
                .DATA_WIDTH (DATA_WIDTH),
                .FIFO_DEPTH (FIFO_DEPTH)
            ) u_stream_fifo (
                .clk_i   (clk_i),
                .arstn_i (arstn_i),

                .data_i  (data_i[i]),
                .valid_i (valid_i[i]),
                .ready_o (ready_o[i]),

                .data_o  (fifo_data_rd[i]),
                .valid_o (fifo_valid_rd[i]),
                .ready_i (fifo_ready_rd[i])
            );

            algorithm_XY_mesh #(
                .DATA_WIDTH (DATA_WIDTH),
                .X_WIDTH    (X_WIDTH),
                .Y_WIDTH    (Y_WIDTH),
                .SOURCE_X   (SOURCE_X),
                .SOURCE_Y   (SOURCE_Y)
            ) u_algorithm_XY (
                .data_i  (fifo_data_rd[i]),
                .valid_i (fifo_valid_rd[i]),
                .ready_o (fifo_ready_rd[i]),

                .data_o  (algorithm_data_rd[i]),
                .valid_o (algorithm_valid_rd[i]),
                .ready_i (algorithm_ready_rd[i])
            );

            logic [DATA_WIDTH-1:0] arbiter_data_wr [CHANNEL_NUM];
            logic [CHANNEL_NUM-1:0] arbiter_valid_wr, arbiter_ready_wr;

            for (j = 0; j < CHANNEL_NUM; j++) begin : algs_to_arbs
                assign arbiter_data_wr[j] = algorithm_data_rd[j][i];
                assign arbiter_valid_wr[j] = algorithm_valid_rd[j][i];
                assign algorithm_ready_rd[j][i] = arbiter_ready_wr[j];
            end

            stream_arbiter #(
                .DATA_WIDTH (DATA_WIDTH),
                .INPUT_NUM  (CHANNEL_NUM)
            ) u_stream_arbiter (
                .clk_i   (clk_i),
                .arstn_i (arstn_i),

                .data_i  (arbiter_data_wr),
                .valid_i (arbiter_valid_wr),
                .ready_o (arbiter_ready_wr),

                .data_o  (data_o[i]),
                .valid_o (valid_o[i]),
                .ready_i (ready_i[i])
            );
        end
    endgenerate
    
endmodule