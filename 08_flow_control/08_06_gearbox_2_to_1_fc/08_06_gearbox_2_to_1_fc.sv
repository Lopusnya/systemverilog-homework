//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_2_to_1_fc
# (
    parameter width = 8
)
(
    input                    clk,
    input                    rst,

    input                    up_valid,
    output                   up_ready,
    input   [ 2*width - 1:0] up_data,

    output                   down_valid,
    input                    down_ready,
    output  [   width - 1:0] down_data
);

    // Task:
    // Implement a module that generates tokens from of one token.
    // Example:
    // "0110" => "01", "10"
    //
    // The module must use signals valid-ready for transfer tokens.

    logic               half_vld;
    logic [width - 1:0] half;

    always_ff @ (posedge clk or posedge rst)
        if (rst)
        half_vld <= '0;
        else if (down_valid & down_ready)
        half_vld <= ~ half_vld;

    assign down_valid  = up_valid;

    assign down_data
        = half_vld ?
            up_data [    0 +: width]
        : up_data [width +: width];

    assign up_ready = half_vld & down_ready;


endmodule
