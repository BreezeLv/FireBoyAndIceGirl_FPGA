module Elevator (
    input Clk, frame_clk, Reset,
    input on,
    input shortint player1_top, player1_bottom, player1_left, player1_right,
    input shortint player2_top, player2_bottom, player2_left, player2_right,
    output is_elevator, is_collide_player1, is_collide_player2,
    output shortint player1_X_Min, player1_X_Max, player1_Y_Min, player1_Y_Max,
    output shortint player2_X_Min, player2_X_Max, player2_Y_Min, player2_Y_Max
);
    parameter elevator_width = 64;
    parameter elevator_height = 16;
    parameter elevator_Start_Pos_X = 23;
    parameter elevator_Start_Pos_Y = 256;
    parameter elevator_End_Pos_X = 23;
    parameter elevator_End_Pos_Y = 303;

    parameter shortint elevator_max_velocity = 1;

    parameter frame_rate_divider = 3;

    shortint elevator_Pos_X, elevator_Pos_Y;
    shortint elevator_Pos_X_in, elevator_Pos_Y_in;
    logic stable, stable_in;

    logic [1:0] frame_counter, frame_counter_in; // for slow down the frame rate

    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

    always_ff @ (posedge Clk) begin
        if(Reset) begin
            elevator_Pos_X <= elevator_Start_Pos_X;
            elevator_Pos_Y <= elevator_Start_Pos_Y;
            stable <= 1'b0;
            frame_counter <= 2'b00;
        end
        else begin
            elevator_Pos_X <= elevator_Pos_X_in;
            elevator_Pos_Y <= elevator_Pos_Y_in;
            stable <= stable_in;
            frame_counter <= frame_counter_in;
        end
    end

    always_comb begin
        elevator_Pos_X_in = elevator_Pos_X;
        elevator_Pos_Y_in = elevator_Pos_Y;
        stable_in = stable;
        frame_counter_in = frame_counter;

        if (frame_clk_rising_edge) begin

            // Lower Frame Clk Rising Edge
            if(frame_counter == frame_rate_divider) begin

                // Elevator Movement
                if(on) begin
                    if(!stable) begin
                        if(elevator_Pos_Y_in == elevator_End_Pos_Y) stable_in=1'b1;
                        else elevator_Pos_Y_in += elevator_max_velocity;
                    end
                end
                else begin
                    if(!stable) begin
                        if(elevator_Pos_Y_in == elevator_Start_Pos_Y) stable_in=1'b1;
                        else elevator_Pos_Y_in -= elevator_max_velocity;
                    end
                end
            end

            // Update frame counter for lowered frame clk
            if(frame_counter == frame_rate_divider) frame_counter_in = 2'd0;
            else frame_counter_in = frame_counter+2'd1;
        end
    end


    // Calculate is_elevator Logic
    shortint offset_X, offset_Y;
    always_comb begin
        offset_X = DrawX-elevator_Pos_X;
        offset_Y = DrawY-elevator_Pos_Y;
        is_elevator = 1'b0;

        if(offset_X>=0 && offset_X<elevator_width && offset_Y>=0 && offset_Y<elevator_height) begin
            is_elevator=1'b1; 
        end
    end

endmodule



module Elevator_ROM (
	input Clk, on,
    input [9:0] elevator_read_addr,

	output logic [7:0] elevator_data_out
);

    parameter [7:0] fill_color_palette = 8'd62;

    logic [7:0] mem_elevator [0:1023];

    initial
    begin
        $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/elevator_template.txt", mem_elevator);
    end

    always_ff @ (posedge Clk)
    begin
        elevator_data_out <= mem_elevator[elevator_read_addr] == 8'h00 ? (on ? fill_color_palette+1 : fill_color_palette) : mem_elevator[elevator_read_addr];
    end
    
endmodule



module Elevator_Switch (
    input Clk, Reset,
    output state,
    output is_switch //for simplicity, we can only use same type of elevater switch thus one shared elevator together with switch state to determine the switch_data!
);
//TODO:
endmodule