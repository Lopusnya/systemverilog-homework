//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts single-bit serial data to the multi-bit parallel value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits and receiving last 'serial_valid' input,
    // the module should assert the 'parallel_valid' at the same clock cycle
    // and output 'parallel_data' value.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

    // ------------------------------------------- FSM BLOCK --------------------------------------------------------------------


    // localparam w_index = $clog2 (width); 

    // logic [w_index - 1:0] index = '0;
    // logic [  width - 1:0] reg_serial_in_parallel;

    // //Named all states for fsm
    // typedef enum bit  
    // {  
    //     DATA_IN = 1'b0,
    //     DATA_OUT = 1'b1

    // } state_fsm;
    // state_fsm state, next_state;

    // always_ff @( posedge clk ) // Reg next state

    //     if (rst)
    //         state <= DATA_IN;
    //     else
    //         state <= next_state;

    // always_comb // Next state logic

    //     case (state)

    //         DATA_IN   : if( index == (width - 2) && serial_valid) next_state = DATA_OUT;
    //         DATA_OUT  : if( serial_valid ) next_state = DATA_IN;
    //         default   : next_state = state;

    //     endcase
    
    // always_ff @( posedge clk )

    //     if (rst) 
    //     begin

    //         reg_serial_in_parallel <= '0;
    //         index <= '0;

    //     end 
    //     else 
    //     begin

    //         case (state)

    //         DATA_IN   : if(serial_valid)
    //                     begin

    //                         reg_serial_in_parallel [index] <= serial_data;
    //                         index <= index + 1'd1;
                        
    //                     end
                                        
    //         DATA_OUT  : if(serial_valid)
    //                     begin

    //                         reg_serial_in_parallel [index] <= serial_data;
    //                         index <= '0;
                        
    //                     end
            
    //         default   : begin

    //                         reg_serial_in_parallel <= reg_serial_in_parallel;
    //                         index <= index;
                
    //                     end
            
    //         endcase
            
    //     end

        
    
    // assign parallel_data  = (index == w_index' (width - 1)) ? {serial_data, reg_serial_in_parallel [width -2:0]} : '0;
    // assign parallel_valid = (serial_valid && state == DATA_OUT) ? 1'b1 : 1'b0;
    
    // ------------------------------------------- FSM BLOCK END -----------------------------------------------------------------



    // ------------------------------------------- REG SERIAL IN PARALLEL BLOCK --------------------------------------------------
    
    localparam w_index = $clog2 (width); 

    logic [w_index - 1:0] index = '0;
    logic [  width - 1:0] reg_serial_in_parallel;

    always_ff @( posedge clk ) // Register serial data
    begin
        if (rst)
            reg_serial_in_parallel <= '0;
        else
            if (serial_valid) 
            begin
              
                reg_serial_in_parallel [index] <= serial_data;
                index <= index == w_index' (width - 1) ? w_index' (0) : index + 1'd1;

            end
    end

    // ------------------------------------------- REG SERIAL IN PARALLEL BLOCK END ----------------------------------------------



    // ------------------------------------------- OUTPUT SIGNAL BLOCK -----------------------------------------------------------

    assign parallel_data  = ( index == w_index' (width - 1) ? {serial_data, reg_serial_in_parallel[width - 2:0]} : '0);
    assign parallel_valid = ( index == w_index' (width - 1) && serial_valid ) ? 1'b1 : 1'b0;


endmodule
