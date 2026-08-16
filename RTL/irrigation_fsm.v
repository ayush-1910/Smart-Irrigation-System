//------------------------------------------------------------
// Module : irrigation_fsm
// Description : Moore FSM for Smart Irrigation Controller
//------------------------------------------------------------

module irrigation_fsm(
    input wire timer_done,
    input wire clk,
    input wire rst,
    
    input dry,
    input hot,
    input low_humidity,
    input rain,

    input wire watering_request,
    input wire [2:0] inhibit_reason,
    input wire wet,

    input wire tank_empty,

    input wire manual_mode,
    input wire manual_cmd,

    output reg pump,
    output reg timer_enable,
    output reg [4:0] status,
    output wire [7:0] diagnostic,
    output wire [2:0] state

);

//------------------------------------------------------------
// State Encoding
//------------------------------------------------------------

localparam RESET_ST = 3'd0;
localparam IDLE_ST  = 3'd1;
localparam WATER_ST = 3'd2;
localparam FAULT_ST = 3'd3;

reg [2:0] current_state;
reg [2:0] next_state;

assign state = current_state;

///////////////////////////////////////////////////////////////
// State Register
///////////////////////////////////////////////////////////////

always @(posedge clk or posedge rst)
begin

    if(rst)
        current_state <= RESET_ST;
    else
        current_state <= next_state;

end

///////////////////////////////////////////////////////////////
// Next State Logic
///////////////////////////////////////////////////////////////

always @(*)
begin

    next_state = current_state;

    case(current_state)

    //--------------------------------------------------------
    RESET_ST:
    //--------------------------------------------------------

        next_state = IDLE_ST;

    //--------------------------------------------------------
    //IDLE
    //--------------------------------------------------------

    IDLE_ST:
    begin

        if(tank_empty)

            next_state = FAULT_ST;

        else if(manual_mode)

        begin

            if(manual_cmd)

                next_state = WATER_ST;

            else

                next_state = IDLE_ST;

        end

        else

        begin

            if(watering_request)

                next_state = WATER_ST;

            else

                next_state = IDLE_ST;

        end

    end

    //--------------------------------------------------------
    //WATERING
    //--------------------------------------------------------

    WATER_ST:
    begin

        if(tank_empty)

            next_state = FAULT_ST;

        else if(manual_mode)

        begin

            if(manual_cmd)

                next_state = WATER_ST;

            else

                next_state = IDLE_ST;

        end

        else if(timer_done && wet)

            next_state = IDLE_ST;

        else

            next_state = WATER_ST;

    end

    //--------------------------------------------------------
    //FAULT
    //--------------------------------------------------------

    FAULT_ST:
    begin

        if(tank_empty)

            next_state = FAULT_ST;

        else

            next_state = IDLE_ST;

    end

    default:

        next_state = RESET_ST;

    endcase

end

///////////////////////////////////////////////////////////////
// Output Logic (Moore)
///////////////////////////////////////////////////////////////

always @(*)
begin

    //--------------------------------------------------------
    //Default Outputs
    //--------------------------------------------------------

    pump   = 1'b0;
    timer_enable = 1'b0;
    status = 5'b00000;

    case(current_state)

    //--------------------------------------------------------
    //RESET
    //--------------------------------------------------------

    RESET_ST:

    begin

        pump   = 1'b0;
        status = 5'b00000;

    end

    //--------------------------------------------------------
    //IDLE
    //--------------------------------------------------------

    IDLE_ST:

    begin

        pump = 1'b0;

        status[1] = 1'b1;

        if(manual_mode)
            status[4] = 1'b1;

    end

    //--------------------------------------------------------
    //WATERING
    //--------------------------------------------------------

    WATER_ST:

    begin

        pump = 1'b1;
        timer_enable = 1'b1;

        status[0] = 1'b1;
        status[2] = 1'b1;

        if(manual_mode)
            status[4] = 1'b1;

    end

    //--------------------------------------------------------
    //FAULT
    //--------------------------------------------------------

    FAULT_ST:

    begin

        pump = 1'b0;

        status[3] = 1'b1;

    end

    endcase

end

assign diagnostic = {watering_request, timer_done, tank_empty, rain, low_humidity, hot, wet, dry};

endmodule