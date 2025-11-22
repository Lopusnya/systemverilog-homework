//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01

    logic [1:0] reg_out;
    wire [3:0] module_out;

    
    always_ff @( posedge clk ) 
    begin

        if (rst) 
        begin

            reg_out <= 2'b01;
            
        end 
        else 
        begin
            
            if (|module_out [3:2]) begin

                reg_out <= ~module_out [3:2];
                
            end
            
                
        end
        
    end

    logic [1:0] mux_out;
    always_comb 
    begin

        case (requests)

              2'b01:  mux_out = requests;
              2'b10:  mux_out = requests;
              2'b11:  mux_out = reg_out;
            default:  mux_out = '0;

        endcase
        
    end

    assign module_out = {mux_out, mux_out};
    assign grants = module_out [1:0];

endmodule
