module ElevatorController (
    input Clk, frame_clk, Reset,
    input shortint player1_top, player1_bottom, player1_left, player1_right,
    input shortint player2_top, player2_bottom, player2_left, player2_right,
    output is_elevator, is_switch,
    output [7:0] elevator_data, switch_data,
    output shortint player1_X_Min, player1_X_Max, player1_Y_Min, player1_Y_Max,
    output shortint player2_X_Min, player2_X_Max, player2_Y_Min, player2_Y_Max
);
    
    parameter elevator_count = 2;
    parameter shortint elevator_start_pos [elevator_count][2] = '{'{23,550}, '{256,192}};
    parameter shortint elevator_end_pos [elevator_count][2] = '{'{23,550}, '{303,256}};
    parameter shortint elevator_minmax_y_pos [elevator_count][2] = '{'{208,119}, '{335,272}};

    logic is_elevators [elevator_count-1:0];
    logic [9:0] elevators_read_addr [elevator_count-1:0];
    logic elevators_on [elevator_count-1:0];

    logic is_collide_player1 [elevator_count-1:0];
    logic is_collide_player2 [elevator_count-1:0];
    shortint player1_X_Min_in, player1_X_Max_in, player1_Y_Min_in, player1_Y_Max_in [elevator_count-1:0];
    shortint player2_X_Min_in, player2_X_Max_in, player2_Y_Min_in, player2_Y_Max_in [elevator_count-1:0];

    always_comb begin

        is_elevator = 1'b0;
        elevator_read_addr = 9'h00;
        elevator_data = 8'h00;

        for (int i = 0; i < elevator_count ; i++) begin
            else if(is_elevators[i]) begin
                is_elevator = 1'b1;
                elevator_read_addr = elevators_read_addr[i];
                elevator_data = elevator_data_buf + elevators_on[i];
            end
        end
    end

    Elevator #( .elevator_collider_min_y(elevator_minmax_y_pos[0]),
                .elevator_collider_max_y(elevator_minmax_y_pos[1]),
                .elevator_Start_Pos_X(elevator_start_pos[0]),
                .elevator_Start_Pos_Y(elevator_start_pos[1]),
                .elevator_End_Pos_X(elevator_end_pos[0]),
                .elevator_End_Pos_Y(elevator_end_pos[1])) elevator_list [elevator_count-1:0] ( .*,
                                                                            .is_elevator(is_elevators),
                                                                            .elevator_on(elevators_on),
                                                                            .player1_X_Min(player1_X_Min_in),
                                                                            .player1_X_Max(player1_X_Max_in),
                                                                            .player1_Y_Min(player1_Y_Min_in),
                                                                            .player1_Y_Max(player1_Y_Max_in),
                                                                            .player2_X_Min(player2_X_Min_in),
                                                                            .player2_X_Max(player2_X_Max_in),
                                                                            .player2_Y_Min(player2_Y_Min_in),
                                                                            .player2_Y_Max(player2_Y_Max_in)
                                                                        );

    // Elevator Sprite Data Processing
    logic [9:0] elevator_read_addr;
    logic [7:0] elevator_data_buf;

    ElevatorROM ElevatorROM_inst(.*, .elevator_data_out(elevator_data_buf)); // Global elevatorRom Instance, can be shared assume no overlapping elevators

endmodule



module Elevator #(
    elevator_collider_min_y,
    elevator_collider_max_y,
    elevator_Start_Pos_X,
    elevator_Start_Pos_Y,
    elevator_End_Pos_X,
    elevator_End_Pos_Y
    ) (
    input Clk, frame_clk, Reset,
    input shortint player1_top, player1_bottom, player1_left, player1_right,
    input shortint player2_top, player2_bottom, player2_left, player2_right,
    output is_elevator, is_collide_player1, is_collide_player2,
    output elevator_on,
    output [9:0] elevator_read_addr,
    output shortint player1_X_Min, player1_X_Max, player1_Y_Min, player1_Y_Max,
    output shortint player2_X_Min, player2_X_Max, player2_Y_Min, player2_Y_Max
);
    parameter elevator_width = 64;
    parameter elevator_height = 16;
    // parameter elevator_Start_Pos_X = 23;
    // parameter elevator_Start_Pos_Y = 256;
    // parameter elevator_End_Pos_X = 23;
    // parameter elevator_End_Pos_Y = 303;

    parameter shortint elevator_max_velocity = 1;
    parameter shortint elevator_collider_max_x_range = 80;

    parameter frame_rate_divider = 3;

    shortint elevator_Pos_X, elevator_Pos_Y;
    shortint elevator_Pos_X_in, elevator_Pos_Y_in;
    logic stable, stable_in;
    logic on, on_in;

    logic [1:0] frame_counter, frame_counter_in; // for slow down the frame rate

    assign elevator_on = on;

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

            // Calculate Elevator-Player Collision Logics
            player1_X_Min=0;
            player1_X_Max=639;
            player1_Y_Min=0;
            player1_Y_Max=479;
            player2_X_Min=0;
            player2_X_Max=639;
            player2_Y_Min=0;
            player2_Y_Max=479;
            is_collide_player1=1'b0;
            is_collide_player2=1'b0;

            if(elevator_Pos_Y+elevator_height > player1_top && elevator_Pos_Y < player1_bottom && player1_right>=elevator_Pos_X-elevator_collider_max_x_range && player1_left<=elevator_Pos_X+elevator_width+elevator_collider_max_x_range) begin
                is_collide_player1=1'b1;
                if(player1_left >= elevator_Pos_X + elevator_width) player1_X_Min = elevator_Pos_X + elevator_width;
                else if(player1_right <= elevator_Pos_X) player1_X_Max = elevator_Pos_X;
            end
            if(elevator_Pos_X+elevator_width > player1_left && elevator_Pos_X < player1_right && player1_top>=elevator_collider_min_y && player1_bottom<=elevator_collider_max_y) begin
                is_collide_player1=1'b1;
                if(player1_bottom <= elevator_Pos_Y) player1_Y_Max=elevator_Pos_Y;
                else if(player1_top >= elevator_Pos_Y+elevator_height) player1_Y_Min=elevator_Pos_Y+elevator_height;
            end

            if(elevator_Pos_Y+elevator_height > player2_top && elevator_Pos_Y < player2_bottom && player2_right>=elevator_Pos_X-elevator_collider_max_x_range && player2_left<=elevator_Pos_X+elevator_width+elevator_collider_max_x_range) begin
                is_collide_player2=1'b1;
                if(player2_left >= elevator_Pos_X + elevator_width) player2_X_Min = elevator_Pos_X + elevator_width;
                else if(player2_right <= elevator_Pos_X) player2_X_Max = elevator_Pos_X;
            end
            if(elevator_Pos_X+elevator_width > player2_left && elevator_Pos_X < player2_right && player2_top>=elevator_collider_min_y && player2_bottom<=elevator_collider_max_y) begin
                is_collide_player2=1'b1;
                if(player2_bottom <= elevator_Pos_Y) player2_Y_Max=elevator_Pos_Y;
                else if(player2_top >= elevator_Pos_Y+elevator_height) player2_Y_Min=elevator_Pos_Y+elevator_height;
            end

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

    assign elevator_read_addr = is_elevator ? offset_X + offset_Y*elevator_width : 19'b00;

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