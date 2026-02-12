module stream_arbiter #(
    parameter DATA_WIDTH = 32,
    parameter INPUT_NUM  = 2,
    parameter ADDR_WIDTH = $clog2(INPUT_NUM)
) (
    input  logic                  clk_i,
    input  logic                  arstn_i,

    input  logic [DATA_WIDTH-1:0] data_i [INPUT_NUM],
    input  logic [INPUT_NUM-1:0]  valid_i,
    output logic [INPUT_NUM-1:0]  ready_o,

    output logic [DATA_WIDTH-1:0] data_o,
    output logic                  valid_o,
    input  logic                  ready_i
);

    logic [ADDR_WIDTH-1:0] grant_ff;
    logic [ADDR_WIDTH-1:0] grant_next;
    logic [ADDR_WIDTH-1:0] increment;

    logic [INPUT_NUM*2-1:0] double_valid_i;

    assign double_valid_i = INPUT_NUM'({valid_i, valid_i} >> grant_ff);

    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (!arstn_i) begin
            grant_ff <= 0;
        end
        else begin
            grant_ff <= grant_next;
        end
    end

    always_comb begin
        grant_next = grant_ff;
        increment = 0;

        for (int i = INPUT_NUM-1; i > 0; i--) begin
            if (double_valid_i[i]) begin
                increment = i;
            end
        end
        
        if (ready_i || !valid_o) begin
            grant_next = (grant_ff + increment) < INPUT_NUM ? (grant_ff + increment) : (grant_ff + increment) - INPUT_NUM;
        end
    end

    mux #(
        .DATA_WIDTH (DATA_WIDTH),
        .INPUT_NUM  (INPUT_NUM)
    ) u_mux_data (
        .data_i (data_i),
        .sel_i  (grant_ff),
        .data_o (data_o)
    );

    assign valid_o = valid_i[grant_ff];
    assign ready_o = (ready_i << grant_ff);
    
endmodule