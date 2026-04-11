//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module convert_first_to_last_with_flow_control
# (
    parameter width = 8
)
(
    input                clock,
    input                reset,

    input  logic                up_valid,
    output logic                up_ready,
    input  logic                up_first,
    input  logic  [width - 1:0] up_data,

    output logic                down_valid,
    input  logic                down_ready,
    output logic                down_last,
    output logic  [width - 1:0] down_data
);

    // Task:
    // Implement a module that converts 'first' input status signal
    // to the 'last' output status signal.
    //
    // The module should respect and set correct valid and ready signals
    // to control flow from the upstream and to the downstream.

    // logic               buf_valid;
    // logic [width - 1:0] buf_data;

    // always_ff @ (posedge clk)
    // begin
    //     if (up_ready & ~ down_ready)
    //         buf_data <= up_data;

    //     if (down_ready)
    //         down_data <= up_ready ? up_data : buf_data;
    // end

    // always_ff @ (posedge clk or posedge rst)
    //     if (rst)
    //     begin
    //         buf_valid  <= 1'b0;
    //         down_valid <= 1'b0;
    //         up_ready   <= 1'b1;
    //     end
    //     else
    //     begin
    //         if (up_ready & ~ down_ready)
    //             buf_valid  <= up_valid;

    //         if (down_ready)
    //             down_valid <= up_ready ? up_valid : buf_valid;

    //         up_ready <= down_ready;
    //     end

    // always_ff @( posedge clock ) begin
    //     if(reset)

    //     else
    // end

    // logic up_hs   = up_valid   & up_ready;
    // logic down_hs = down_ready & down_valid;

    // assign up_ready = down_ready;

    // logic up_first_r;
    // logic [width - 1:0] up_data_r;
    // always_ff @( posedge clock ) begin
    //     if(reset) begin
    //         up_first_r <= '0;
    //         up_data_r  <= '0;
    //         down_valid <= '0;
    //     end
    //     else if (up_hs) begin
    //         up_first_r <= up_first;
    //         up_data_r <= up_data;
    //         down_valid <= up_valid;
    //     end
    // end

    // logic double;
    // always_ff @( posedge clock ) begin
    //     if(reset)
    //         double <= '0;
    //     else if (up_first & up_first_r)
    //         double <= '1;
    //     else
    //         double <= '0;
    // end    

    // // always_ff @( posedge clock ) begin
    // //     if(reset)

    // //     else
    // // end

        logic was_reset_r;
    always_ff @(posedge clock)
    begin
        if (reset)
            was_reset_r <= '1;
        else
            if (up_valid)
                was_reset_r <= '0;
            else 
                was_reset_r <= was_reset_r;
    end 

    logic shift_valid, shift_first;
    logic [width - 1:0] shift_data;

    always_ff @( posedge clock ) 
    begin
        if (reset)
            shift_data <= '0;
        else
            if (up_valid)
                shift_data <= up_data; 
            else
                shift_data <= shift_data;
    end

    always_ff @( posedge clock ) 
    begin
        if (reset)
            shift_valid <= '0;
        else
            shift_valid <= up_valid;
    end

    always_ff @( posedge clock ) 
    begin
        if (reset)
            shift_first <= '0;      
        else
            if (up_valid)
                shift_first <= up_first;
            else
                shift_first <= shift_first;       
    end

    logic [width - 1:0] output_r_data;
    always_ff @( posedge clock ) 
    begin
        if (reset)
            output_r_data <= '0;    
        else
            output_r_data <= down_data;   
    end

    logic output_r_valid;
    always_ff @( posedge clock ) 
    begin
        if (reset)
            output_r_valid <= '0;     
        else
            output_r_valid <= down_valid;   
    end

    logic output_r_last;
    always_ff @( posedge clock ) 
    begin
        if (reset)
            output_r_last <= '0; 
        else
            output_r_last <= down_last; 
    end

    logic [1:0] wire_out;
    always_comb 
    begin
        if (reset)
        begin
            wire_out = '0; 
        end        
        else
        begin
            casez ({up_first, shift_first, output_r_last, up_valid, shift_valid, output_r_valid, was_reset_r})

                7'b01?11?0: wire_out = {       1'b0, shift_valid};
                7'b10?11?0: wire_out = {       1'b1, shift_valid};
                7'b???0??0: wire_out = {       1'b1,        1'b0};
                7'b1?11??0: wire_out = {       1'b1,        1'b1};
                7'b0??1??0: wire_out = {       1'b0,        1'b1};

                default:   wire_out = {shift_first, shift_valid};

            endcase
        
        end      
    end

    assign down_data = shift_data;
    assign down_valid = wire_out [0];
    assign down_last = wire_out [1];


endmodule
