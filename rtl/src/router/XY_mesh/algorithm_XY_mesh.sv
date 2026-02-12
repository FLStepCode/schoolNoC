module algorithm_XY_mesh #(
    parameter DATA_WIDTH = 32,
    parameter X_WIDTH    = 2,
    parameter Y_WIDTH    = 2,
    parameter SOURCE_X   = 1,
    parameter SOURCE_Y   = 1
) (
    input  logic [DATA_WIDTH-1:0] data_i,
    input  logic                  valid_i,
    output logic                  ready_o,

    output logic [DATA_WIDTH-1:0] data_o [5],
    output logic [4:0]            valid_o,
    input  logic [4:0]            ready_i
);

/*
    sel values depending on direction:

    0 . . . . i . . . . X coordinates
    .    
    .    
    .         1
    .         |
    j    4 -- R -- 2
    .         |
    .         3
    .
    .
    Y coordinates

    sel == 0 is local connection
*/

    // === Algorithm logic ===

    logic [X_WIDTH-1:0] dest_x;
    logic [Y_WIDTH-1:0] dest_y;
    logic [2:0]         sel;

    assign {dest_x, dest_y} = data_i[DATA_WIDTH-1:DATA_WIDTH-(X_WIDTH+Y_WIDTH)];

    always_comb begin
        sel = 0;

        if (dest_x > SOURCE_X) begin
            sel = 2;
        end
        else if (dest_x < SOURCE_X) begin
            sel = 4;
        end
        else if (dest_y > SOURCE_Y) begin
            sel = 3;
        end
        else if (dest_y < SOURCE_Y) begin
            sel = 1;
        end
        else begin
            sel = 0;
        end
    end


    // === Signal and data routing ===

    demux #(
        .DATA_WIDTH (DATA_WIDTH),
        .OUTPUT_NUM (5)
    ) u_demux (
        .data_i (data_i),
        .sel_i  (sel),
        .data_o (data_o)
    );

    assign valid_o = (valid_i << sel);
    assign ready_o = ready_i[sel];
    
endmodule