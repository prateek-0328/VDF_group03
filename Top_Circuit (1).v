`timescale 1ns / 1ps

module dff1(
   input clk, in, 
   output reg out
    );
    always @(posedge clk) begin
        out<=in;
    end
endmodule

module dff2(
   input clk, 
   input[1:0] in, 
   output reg[1:0] out
    );
    always @(posedge clk) begin
        out<=in;
    end
endmodule

module dff5(
   input clk, 
   input[4:0] in, 
   output reg[4:0] out
    );
    always @(posedge clk) begin
        out<=in;
    end
endmodule

module dff6(
   input clk, 
   input[5:0] in, 
   output reg[5:0] out
    );
    always @(posedge clk) begin
        out<=in;
    end
endmodule

module dff7(
   input clk, 
   input[6:0] in, 
   output reg[6:0] out
    );
    always @(posedge clk) begin
        out<=in;
    end
endmodule

module dff8(
   input clk, 
   input[7:0] in, 
   output reg[7:0] out
    );
    always @(posedge clk) begin
        out<=in;
    end
endmodule

module Recharge(
   input clk, reset, recharge, setup,
   input[5:0] recharge_code_init, recharge_code,
   input[5:0] in_balance, input[1:0] option,
   output reg[5:0] out_balance, output reg update
    );
    
    wire[7:0] cost;
    assign cost=in_balance; 
    always@(posedge clk) begin
        //Reset state sets the balance to zero
        if(reset==1'b1) begin out_balance<=6'b0; update<=1'b0; end  
        
        //If device is set up and only if recharge code is correct, we can make changes in balance  
        else if(setup==1'b1 && recharge==1'b1 && (recharge_code_init==recharge_code)) begin case(option)
        
                  //Based on options of the user, difference balance units is incremented(max balance is 50 units)
                  2'b00: out_balance<=(cost+5>50)?6'd50:cost+5;
                  2'b01: out_balance<=(cost+10>50)?6'd50:cost+10;
                  2'b10: out_balance<=(cost+15>50)?6'd50:cost+15;
                  2'b11: out_balance<=(cost+20>50)?6'd50:cost+20;
             endcase
             update<=1'b1;
        end
        else update<=1'b0;
    end
    
endmodule


module Seven_Segment_Controller 
  (
   input rst, 
   input [3:0] num,
   output [6:0] out
   );

  reg [6:0] BCD_code = 7'h00;

  always @(*)
    begin
        if (rst) 
            begin
                BCD_code <= 7'h7E;
            end
        else 
            begin
                case (num)
                    4'b0000 : BCD_code <= 7'h7E;
                    4'b0001 : BCD_code <= 7'h30;
                    4'b0010 : BCD_code <= 7'h6D;
                    4'b0011 : BCD_code <= 7'h79;
                    4'b0100 : BCD_code <= 7'h33;          
                    4'b0101 : BCD_code <= 7'h5B;
                    4'b0110 : BCD_code <= 7'h5F;
                    4'b0111 : BCD_code <= 7'h70;
                    4'b1000 : BCD_code <= 7'h7F;
                    4'b1001 : BCD_code <= 7'h7B;
                    4'b1010 : BCD_code <= 7'h77;
                    4'b1011 : BCD_code <= 7'h1F;
                    4'b1100 : BCD_code <= 7'h4E;
                    4'b1101 : BCD_code <= 7'h3D;
                    4'b1110 : BCD_code <= 7'h4F;
                    4'b1111 : BCD_code <= 7'h47;
                endcase
            end
    end 

  assign out = BCD_code;
 
endmodule 

module balance_display(
    input rst,
    input [5:0] balance,
    output [6:0] out_ones,
    output [6:0] out_tense
);
    reg [3:0] ones_place;
    reg [3:0] tens_place;
    Seven_Segment_Controller ss_controller_ones(.rst(rst),
                                                .num(ones_place),
                                                .out(out_ones));

    Seven_Segment_Controller ss_controller_tens(.rst(rst),
                                                .num(tens_place),
                                                .out(out_tense));

    always @ (*)
        begin
            ones_place = balance % 10;
        end
    always @ (*)
        begin
            tens_place = (balance / 10) % 10;
        end

endmodule

module units_display(
    input rst,
    input [7:0] units,
    output [6:0] out_ones,
    output [6:0] out_tense,
    output  [6:0] out_hundreds
);

    reg [3:0] ones_place;
    reg [3:0] tens_place;
    reg [3:0] hundreds_place;

    Seven_Segment_Controller ss_controller_ones(
        .rst(rst),
        .num(ones_place),
        .out(out_ones)
    );

    Seven_Segment_Controller ss_controller_tens(
        .rst(rst),
        .num(tens_place),
        .out(out_tense)
    );

    Seven_Segment_Controller ss_controller_hundreds(
        .rst(rst),
        .num(hundreds_place),
        .out(out_hundreds)
    );

    always @ (*) begin
        ones_place = units % 10;
        tens_place = (units / 10) % 10;
        hundreds_place = (units / 100) % 10;
    end

endmodule

module Main_circuit(
    input clk, reset, recharge,
    input[1:0] recharge_option,
    input[5:0] password, recharge_code,
    output reg[5:0] balance,
    output reg[7:0] units,
    output reg LED1, LED2, LED3, sys_status,
    output reg[4:0] backup,
    // Wires for Balance display 
    output [6:0] BD_ones,
    output [6:0] BD_tense,
    output [6:0] UD_ones,
    output [6:0] UD_tense,
    output [6:0] UD_hundreds
    );
    
    wire[5:0] balance_calc;
    reg setup;
    reg[2:0] counter;
    reg[5:0] recharge_code_init;
    wire update;
    
    //Condition for reset
//    assign password=(reset==1'b1)?5'd0:password; 
//    assign recharge_code=(reset==1'b1)? 6'd0:recharge_code;
//    assign recharge=(reset==1'b1)?1'b0:recharge;
//    assign recharge_option=(reset==1'b1)?1'b0:recharge_option;
    
    Recharge r1(.clk(clk), .reset(reset), .recharge(recharge), .recharge_code_init(recharge_code_init), .recharge_code(recharge_code), .setup(setup), .in_balance(balance), .option(recharge_option), .out_balance(balance_calc), .update(update));
    //Recharge module allows to make increments in balance 
    
    balance_display balance_display_inst(
        .rst(reset),
        .balance(balance),
        .out_ones(BD_ones),
        .out_tense(BD_tense)
         );
      
    units_display units_display_inst(
        .rst(reset),
        .units(units),
        .out_ones(UD_ones),
        .out_tense(UD_tense),
        .out_hundreds(UD_hundreds)
        );
    
    
    always@(posedge clk) begin
            if(reset==1'b1) begin
            //Set a non zero backup state but make sure device is not set up
               setup=1'b0;
               backup=5'd20;
               units=8'd0;
               balance=6'd0;
               sys_status=1'b0; LED1=1'b0; LED2=1'b0; LED3=1'b0;
               recharge_code_init=6'd0;
            end
            else if(setup==1'b0) begin //The only way to setup the system back on is if it goes to reset state 
            //after system turns off
               //Device is only setup once the installation password matches
               if(password==6'b011011) begin //Password in built with the system
                   setup=1'b1;
                   sys_status=1'b1;
                   recharge_code_init=recharge_code;
                   counter=3'b000;
                end
            end
            //System status implies the device is on or off. It becomes off only when balance and backup is zero
            else if(sys_status==1'b1) begin
                 //Check whether balance was updated. If balance is non zero, backup is reset
                 if(update==1'b1) begin
                     balance=balance_calc;
                     backup=5'd20;
                     counter=3'b000;
                 end
                 else begin
                 counter=counter+1;
                 if(counter==3'd5 && balance>0) begin
                   balance=balance-6'd1;
                   counter=3'd0;
                   end
                 end
                 
                 counter=counter+1;
                 //Measure units only if balance is non zero
                 units=units+1;
                 
                 //With every increment of 5 in the electrical units, a deduction of 1 comes in balance
                 if(counter==3'd5 && balance>0) begin
                   balance=balance-6'd1;
                   counter=3'd0;
                 end
                 
                 
                 //If balance is zero, we are dependent on the remaining backup units 
                 if(balance==6'd0 && backup>5'd0) begin
                      LED3=1'b1; LED2=1'b0; LED1=1'b0;
                      backup=backup-5'd1;
                      //Set system to off if both balance and backup is zero 
                      if(backup==5'd0) begin sys_status=1'b0; LED1=1'b0; LED2=1'b0; LED3=1'b0; end
                 end
                 
                 //Some conditions to warn regarding the balance in the machine 
                 else if(balance<6'd5)begin LED2=1'b1; LED1=1'b0; LED3=1'b0; end
                 else if(balance<6'd10) begin LED1=1'b1;LED2=1'b0; LED3=1'b0; end
                 else begin LED1=1'b0; LED2=1'b0; LED3=1'b0; end
            end        
    end
    
    //Initialise the LEDs and the balance update status on the positive edge of the clock
//    always@(posedge clk) begin update=(balance_calc>balance)?1'b1: 1'b0; end
endmodule

module Top_Circuit(
    input clk, reset, recharge,
    input[1:0] recharge_option,
    input[5:0] password, recharge_code,
    output [5:0] balance,
    output [4:0] units, backup,
    output LED1, LED2, LED3, sys_status,
    
    output [6:0] BD_ones,
    output [6:0] BD_tense,
    output [6:0] UD_ones,
    output [6:0] UD_tense,
    output [6:0] UD_hundred
    );
    
    wire recharge_check;
    wire[1:0] recharge_option_check;
    wire[5:0] password_check, recharge_code_check;
    wire[5:0] balance_check;
    wire[7:0] units_check;
    wire LED1_check, LED2_check, LED3_check;
    wire sys_status_check;
    wire[4:0] backup_check;
    
    
    wire [6:0] BD_ones_check;
    wire [6:0] BD_tense_check;
    wire [6:0] UD_ones_check;
    wire [6:0] UD_tense_check;
    wire [6:0] UD_hundred_check;

    
    //The input is sent into an FF. On the next clock cycle, the input values is sent into main circuit  
    dff1 in1(.clk(clk), .in(recharge), .out(recharge_check));
    dff2 in2(.clk(clk), .in(recharge_option), .out(recharge_option_check));
    dff6 in3(.clk(clk), .in(password), .out(password_check));
    dff6 in4(.clk(clk), .in(recharge_code), .out(recharge_code_check));
    
    Main_circuit m1(.clk(clk), .reset(reset), .recharge(recharge_check),
                    .recharge_option(recharge_option_check),
                    .password(password_check), 
                    .recharge_code(recharge_code_check),
                    .balance(balance_check),
                    .units(units_check),
                    .LED1(LED1_check),
                    .LED2(LED2_check),
                    .LED3(LED3_check),
                    .sys_status(sys_status_check),
                    .backup(backup_check),
                    .BD_ones(BD_ones_check),
                    .BD_tense(BD_tense_check),
                    .UD_ones(UD_ones_check),
                    .UD_hundreds(UD_hundred_check),
                    .UD_tense(UD_tense_check));
    
    //Refer to the project sheet for an idea on the top module implementation                
    dff6 out1(.clk(clk), .in(balance_check), .out(balance));
    dff8 out2(.clk(clk), .in(units_check), .out(units));
    dff1 out3(.clk(clk), .in(LED1_check), .out(LED1));
    dff1 out4(.clk(clk), .in(LED2_check), .out(LED2));
    dff1 out5(.clk(clk), .in(LED3_check), .out(LED3));
    dff1 out6(.clk(clk), .in(sys_status_check), .out(sys_status));
    dff5 out7(.clk(clk), .in(backup_check), .out(backup));
    
    dff7 out8(.clk(clk), .in(BD_ones_check), .out(BD_ones));
    dff7 out9(.clk(clk), .in(BD_tense_check), .out(BD_tense));
    dff7 out10(.clk(clk), .in(UD_ones_check), .out(UD_ones));
    dff7 out11(.clk(clk), .in(UD_tense_check), .out(UD_tense));
    dff7 out12(.clk(clk), .in(UD_hundred_check), .out(UD_hundred));
endmodule




