module demux #(
    parameter DATA_WIDTH = 32,
    parameter OUTPUT_NUM = 2,

    parameter ADDR_WIDTH = $clog2(OUTPUT_NUM)
) (
    input  logic [DATA_WIDTH-1:0] data_i,
    input  logic [ADDR_WIDTH-1:0] sel_i,
    output logic [DATA_WIDTH-1:0] data_o [OUTPUT_NUM]
);

    generate
        genvar i;
        for (i = 0; i < OUTPUT_NUM; i++) begin : assign_outputs
            assign data_o[i] = (sel_i == i) ? data_i : '0;
        end
    endgenerate
    
endmodule