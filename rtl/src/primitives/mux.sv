module mux #(
    parameter DATA_WIDTH = 32,
    parameter INPUT_NUM  = 2,

    parameter ADDR_WIDTH = $clog2(INPUT_NUM)
) (
    input  logic [DATA_WIDTH-1:0] data_i [INPUT_NUM],
    input  logic [ADDR_WIDTH-1:0] sel_i,
    output logic [DATA_WIDTH-1:0] data_o
);

    assign data_o = data_i[sel_i];
    
endmodule