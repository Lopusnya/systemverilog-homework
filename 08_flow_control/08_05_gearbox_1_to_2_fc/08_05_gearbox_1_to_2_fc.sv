//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module gearbox_1_to_2_fc
# (
    parameter width = 2
)
(
    input                         clk,
    input                         rst,
    input  logic                       up_valid,
    output logic                       up_ready,
    input  logic      [   width - 1:0] up_data,
    output logic                  down_valid,
    output logic [ 2*width - 1:0] down_data,
    input  logic                       down_ready
);

    // Task:
    // Implement a module that generates one token from of two tokens.
    // Example:
    // "01", "10" => "0110"
    //
    // The module must use signals valid-ready for transfer tokens.

    logic [width-1:0] buffer;
    logic             first_flag;

    assign up_ready = !down_valid || down_ready;

    always_ff @(posedge clk) begin
        if (rst) begin
            first_flag  <= 1'b0;
            down_valid <= 1'b0;
            down_data  <= '0;
            buffer     <= '0;
        end else begin

            if (down_ready & down_valid) begin
                down_valid <= 1'b0;
            end

            if (up_valid & up_ready) begin
                if (!first_flag) begin
                    buffer    <= up_data;
                    first_flag <= 1'b1;
                end else begin
                    down_data  <= {buffer, up_data};
                    down_valid <= 1'b1;
                    first_flag  <= 1'b0;
                end
            end 
        end
    end


endmodule
