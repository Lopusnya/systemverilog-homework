//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

    enum logic [2:0] 
    {
        st_idle = 3'd0,
        st_b_c = 3'd1,
        st_a_c = 3'd2,
        st_out = 3'd3
    } 
    state, next_state;

    always_ff @( posedge clk ) 
        if(rst)
            state <= st_idle;
        else
            state <= next_state;
    
    logic w_busy;
    assign busy = w_busy;
    always_comb 
    begin
        next_state = state;
        f_le_a = '0;
        f_le_b = '0;
        w_busy = '0;

        case (state)
           st_idle:
           begin
                f_le_a = unsorted [0];
                f_le_b = unsorted [1];

                if(f_le_err)
                    begin
                        next_state = st_idle;
                        err = '1;
                    end
                else
                    
                    if(valid_in)
                        begin
                            next_state = st_b_c;
                            w_busy = '1;
                        end
           end

           st_b_c:
           begin
                f_le_a = unsorted [1];
                f_le_b = unsorted [2];
                w_busy = '1;

                if(f_le_err)
                    begin
                        next_state = st_idle;
                        err = '1;
                    end
                else
                        next_state = st_a_c;

           end

           st_a_c:
           begin
                f_le_a = unsorted [0];
                f_le_b = unsorted [2];
                w_busy = '1;

                if(f_le_err)
                    begin
                        next_state = st_idle;
                        err = '1;
                    end
                else
                    next_state = st_out;
           end

           st_out:
           begin
                next_state = st_idle;
           end

        endcase
    end
    
    logic [2:0] compare;
    always_ff @( posedge clk ) 
        if(rst)
            compare <= '0;
        else
            begin
                if(state == st_idle & f_le_res & valid_in)
                    compare[0] <= 1'b1;

                if(state == st_b_c & f_le_res)
                    compare[1] <= 1'b1;

                if(state == st_a_c & f_le_res)
                    compare[2] <= 1'b1;

                if(state == st_out | f_le_err)
                    compare <= '0;

            end

    logic [0:2][FLEN - 1:0] mux_out;
    always_comb
    begin
        
        case ({compare, state == st_out})
            4'b000_1  : mux_out = {unsorted [2], unsorted [1], unsorted [0]}; // C < B < A
            4'b010_1  : mux_out = {unsorted [1], unsorted [2], unsorted [0]}; // B < C < A
            4'b110_1  : mux_out = {unsorted [1], unsorted [0], unsorted [2]}; // B < A < C
            4'b001_1  : mux_out = {unsorted [2], unsorted [0], unsorted [1]}; // C < A < B
            4'b101_1  : mux_out = {unsorted [0], unsorted [2], unsorted [1]}; // A < C < B
            4'b111_1  : mux_out = {unsorted [0], unsorted [1], unsorted [2]}; // A < B < C
            default  : mux_out = '0;
        endcase
    end

    assign sorted = (state == st_out) ? mux_out : sorted;
    assign valid_out = ((state == st_out) | f_le_err) ? '1 : '0;
    
    always_ff @( posedge clk ) 
        if(rst)
            err <= '0;
        else
            if (f_le_err)
                err <= '1;
            else
                err <= '0;


    




endmodule
