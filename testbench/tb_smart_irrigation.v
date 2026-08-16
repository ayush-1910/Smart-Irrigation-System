`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.07.2026 16:47:12
// Design Name: 
// Module Name: tb_smart_irrigation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_smart_irrigation(

    );
reg clk;
reg rst;

reg [7:0] moisture;
reg [7:0] temperature;
reg [7:0] humidity;

reg rain;
reg tank_empty;
reg manual_mode;
reg manual_cmd;
wire pump;

wire [4:0] status;
wire [2:0] state;
wire [2:0] inhibit_reason;
wire [3:0] env_status;

smart_irrigation_top DUT
(

    .clk(clk),
    .rst(rst),

    .moisture(moisture),
    .temperature(temperature),
    .humidity(humidity),

    .rain(rain),
    .tank_empty(tank_empty),

    .manual_mode(manual_mode),
    .manual_cmd(manual_cmd),

    .pump(pump),

    .status(status),

    .state(state),

    .inhibit_reason(inhibit_reason),

    .env_status(env_status)

);
integer pass_count = 0;
integer fail_count = 0;

reg visited_reset = 0;
reg visited_idle = 0;
reg visited_water =0;
reg visited_fault =0;

always #5 clk = ~clk;

initial
begin
    clk = 0;
    rst = 0;
    moisture = 0;
    temperature = 0;
    humidity = 0;
    rain = 0;
    tank_empty = 0;
    manual_mode = 0;
    manual_cmd = 0;
end

//--------------------------------------------------
// Reset DUT
//--------------------------------------------------

task reset_dut;

begin

    rst = 1;

    repeat(3) @(posedge clk);

    rst = 0;

    @(posedge clk);

    $display("--------------------------------------");
    $display("RESET COMPLETE");
    $display("--------------------------------------");
end
endtask

//--------------------------------------------------
// Set Environment
//--------------------------------------------------

task set_environment;

input [7:0] moist;
input [7:0] temp;
input [7:0] hum;

input rain_in;
input tank_in;

begin

    moisture   = moist;
    temperature = temp;
    humidity    = hum;

    rain       = rain_in;
    tank_empty = tank_in;

    @(posedge clk);

end
endtask

//--------------------------------------------------
// Manual Mode
//--------------------------------------------------

task manual_control;

input mode;
input cmd;

begin

    manual_mode = mode;
    manual_cmd  = cmd;

    @(posedge clk);

end
endtask

//--------------------------------------------------
// Output Checker
//--------------------------------------------------

task check_output;

input expectedPump;

input [2:0] expectedState;

begin

    if(pump == expectedPump &&
       state == expectedState)

    begin

        pass_count = pass_count + 1;

        $display("[PASS] Time = %0t", $time);

    end

    else

    begin

        fail_count = fail_count + 1;

        $display("[FAIL] Time = %0t", $time);

        $display("Expected Pump : %b", expectedPump);
        $display("Actual Pump   : %b", pump);

        $display("Expected State: %d", expectedState);
        $display("Actual State  : %d", state);

    end

end
endtask

always @(posedge clk)
begin

    case(state)

    3'd0:
        visited_reset = 1;

    3'd1:
        visited_idle = 1;

    3'd2:
        visited_water = 1;

    3'd3:
        visited_fault = 1;

    endcase
end

initial
begin
//--------------------------------------------------
// TEST 1 : RESET
//--------------------------------------------------

$display("\n========== TEST 1 : RESET ==========");

reset_dut();

check_output(
    0,
    3'd1      // IDLE State
);

//--------------------------------------------------
// TEST 2 : AUTOMATIC WATERING
//--------------------------------------------------

$display("\n========== TEST 2 : DRY SOIL ==========");

set_environment(

    10,     // Moisture

    35,     // Temperature

    40,     // Humidity

    0,      // Rain

    0       // Tank Empty

);

repeat(3) @(posedge clk);

check_output(

    1,

    3'd2     // WATERING

);

//--------------------------------------------------
// TEST 3 : TIMER
//--------------------------------------------------

$display("\n========== TEST 3 : TIMER ==========");

repeat(110) @(posedge clk);

set_environment(

    85,

    35,

    40,

    0,

    0

);

repeat(2) @(posedge clk);

check_output(

    0,

    3'd1

);

//--------------------------------------------------
// TEST 4 : RAIN
//--------------------------------------------------

$display("\n========== TEST 4 : RAIN ==========");

set_environment(

    10,

    35,

    40,

    1,

    0

);

repeat(2) @(posedge clk);

check_output(

    0,

    3'd1

);

//--------------------------------------------------
// TEST 5 : TANK EMPTY
//--------------------------------------------------

$display("\n========== TEST 5 : TANK EMPTY ==========");

set_environment(

    10,

    35,

    40,

    0,

    1

);

repeat(2) @(posedge clk);

check_output(

    0,

    3'd3      // FAULT

);

//--------------------------------------------------
// TEST 6 : RECOVERY
//--------------------------------------------------

$display("\n========== TEST 6 : RECOVERY ==========");

set_environment(

    85,
    35,
    40,
    0,
    0

);

repeat(2) @(posedge clk);

check_output(

    0,
    3'd1

);

//--------------------------------------------------
// TEST 7 : MANUAL MODE
//--------------------------------------------------

$display("\n========== TEST 7 : MANUAL ==========");

manual_control(

    1,

    1

);

repeat(2) @(posedge clk);

check_output(

    1,

    3'd2

);

manual_control(

    1,

    0

);

repeat(2) @(posedge clk);

check_output(

    0,

    3'd1

);

manual_control(

    0,

    0

);

repeat(2) @(posedge clk);

//--------------------------------------------------
// SUMMARY
//--------------------------------------------------

$display("\n====================================");

$display("Simulation Summary");

$display("====================================");

$display("Tests Passed : %0d",pass_count);

$display("Tests Failed : %0d",fail_count);

if(fail_count==0)

    $display("ALL TESTS PASSED");

else

    $display("SOME TESTS FAILED");
    
$display("");

$display("FSM Coverage");

$display("RESET     : %b",visited_reset);

$display("IDLE      : %b",visited_idle);

$display("WATERING  : %b",visited_water);

$display("FAULT     : %b",visited_fault);

$finish;
end
endmodule
