// Just show a possible solution for flexible switch count for every elevator..
//typedef struct #(parameter switch_count) { //syntax error lol
//    shortint switch_X_Pos [switch_count];
//    shortint switch_Y_Pos [switch_count];
//} switch_pack;

module ElevatorController (
    input Clk, frame_clk, Reset,
    input [9:0] DrawX, DrawY,
    input shortint player1_top, player1_bottom, player1_left, player1_right,
    input shortint player2_top, player2_bottom, player2_left, player2_right,
    output is_elevator, is_switch,
    output [7:0] elevator_data, switch_data,
    output is_collide_player1, is_collide_player2,
    output shortint player1_X_Min, player1_X_Max, player1_Y_Min, player1_Y_Max,
    output shortint player2_X_Min, player2_X_Max, player2_Y_Min, player2_Y_Max
);
    
    parameter elevator_count = 2;
    parameter shortint elevator_start_pos [elevator_count][2] = '{'{23,550}, '{252,192}};
    parameter shortint elevator_end_pos [elevator_count][2] = '{'{23,550}, '{308,249}};
    parameter shortint elevator_minmax_y_pos [elevator_count][2] = '{'{208,119}, '{335,272}};

    // parameter shortint switch_count [elevator_count] = '{2,2};
    parameter shortint max_switch_count = 2;
    parameter shortint switch_X_Pos [max_switch_count][elevator_count] = '{'{190,190},'{486,486}}; //could use -1 to represent non-use
    parameter shortint switch_Y_Pos [max_switch_count][elevator_count] = '{'{240,319},'{256,176}};

    logic is_elevators [elevator_count-1:0];
    logic [9:0] elevators_read_addr [elevator_count-1:0];
    logic elevators_on [elevator_count-1:0];
	 logic elevator_on;

    logic is_switchs [elevator_count-1:0];
    logic [7:0] switchs_data [elevator_count-1:0];

    logic is_collide_player1_in [elevator_count];
    logic is_collide_player2_in [elevator_count];
    shortint player1_X_Min_in [elevator_count];
    shortint player1_X_Max_in [elevator_count];
    shortint player1_Y_Min_in [elevator_count];
    shortint player1_Y_Max_in [elevator_count];
    shortint player2_X_Min_in [elevator_count];
    shortint player2_X_Max_in [elevator_count];
    shortint player2_Y_Min_in [elevator_count];
    shortint player2_Y_Max_in [elevator_count];

    always_comb begin

        is_elevator = 1'b0;
        elevator_read_addr = 9'h00;
        elevator_data = 8'h00;
        elevator_on = 1'b0;

        is_collide_player1=1'b0;
        is_collide_player2=1'b0;
        player1_X_Min=0;
        player1_X_Max=639;
        player1_Y_Min=0;
        player1_Y_Max=479;
        player2_X_Min=0;
        player2_X_Max=639;
        player2_Y_Min=0;
        player2_Y_Max=479;

        is_switch = 1'b0;
        switch_data = 8'h00;


        for (int i = 0; i < elevator_count ; i++) begin
            if(is_elevators[i]) begin
                is_elevator = 1'b1;
                elevator_on = elevators_on[i];
                elevator_read_addr = elevators_read_addr[i];
                elevator_data = elevator_data_buf;
            end

            if(is_collide_player1_in[i]) begin
                is_collide_player1=1'b1;
                player1_X_Min=player1_X_Min_in[i];
                player1_X_Max=player1_X_Max_in[i];
                player1_Y_Min=player1_Y_Min_in[i];
                player1_Y_Max=player1_Y_Max_in[i];
            end

            if(is_collide_player2_in[i]) begin
                is_collide_player2=1'b1;
                player2_X_Min=player2_X_Min_in[i];
                player2_X_Max=player2_X_Max_in[i];
                player2_Y_Min=player2_Y_Min_in[i];
                player2_Y_Max=player2_Y_Max_in[i];
            end

            if(is_switchs[i]) begin
                is_switch=1'b1;
                switch_data=switchs_data[i];
            end
        end
    end

    Elevator #(.switch_count(max_switch_count)) elevator_list [elevator_count-1:0] ( .*,
																					 .elevator_collider_min_y(elevator_minmax_y_pos[0]),
                                                                                     .elevator_collider_max_y(elevator_minmax_y_pos[1]),
                                                                                     .elevator_Start_Pos_X(elevator_start_pos[0]),
																					 .elevator_Start_Pos_Y(elevator_start_pos[1]),
																					 .elevator_End_Pos_X(elevator_end_pos[0]),
																					 .elevator_End_Pos_Y(elevator_end_pos[1]),
                                                                                     .is_elevator(is_elevators),
                                                                                     .elevator_on(elevators_on),
																					 .elevator_read_addr(elevators_read_addr),
                                                                                     .is_switch(is_switchs),
                                                                                     .switch_data(switchs_data),
																					 .is_collide_player1(is_collide_player1_in),
																					 .is_collide_player2(is_collide_player2_in),
																					 .switch_X_Pos(switch_X_Pos),
																					 .switch_Y_Pos(switch_Y_Pos),
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

    Elevator_ROM ElevatorROM_inst(.*, .on(elevator_on), .elevator_data_out(elevator_data_buf)); // Global elevatorRom Instance, can be shared assume no overlapping elevators

endmodule



module Elevator #(shortint switch_count) (
    input Clk, frame_clk, Reset,
    input [9:0] DrawX, DrawY,
    input shortint player1_top, player1_bottom, player1_left, player1_right,
    input shortint player2_top, player2_bottom, player2_left, player2_right,
    input shortint elevator_collider_min_y,
    input shortint elevator_collider_max_y,
    input shortint elevator_Start_Pos_X,
    input shortint elevator_Start_Pos_Y,
    input shortint elevator_End_Pos_X,
    input shortint elevator_End_Pos_Y,
    input shortint switch_X_Pos[switch_count], switch_Y_Pos[switch_count],
    output is_elevator, is_switch,
    output [7:0] switch_data,
    output is_collide_player1, is_collide_player2,
    output elevator_on,
    output [9:0] elevator_read_addr,
    output shortint player1_X_Min, player1_X_Max, player1_Y_Min, player1_Y_Max,
    output shortint player2_X_Min, player2_X_Max, player2_Y_Min, player2_Y_Max
);
    parameter elevator_width = 64;
    parameter elevator_height = 16;

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
            stable <= 1'b1;
            frame_counter <= 2'b00;
            on <= 1'b0;
        end
        else begin
            elevator_Pos_X <= elevator_Pos_X_in;
            elevator_Pos_Y <= elevator_Pos_Y_in;
            stable <= stable_in;
            frame_counter <= frame_counter_in;
            on <= on_in;
        end
    end

    always_comb begin
        elevator_Pos_X_in = elevator_Pos_X;
        elevator_Pos_Y_in = elevator_Pos_Y;
        stable_in = stable;
        frame_counter_in = frame_counter;
		  
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

        if (frame_clk_rising_edge) begin

            // Lower Frame Clk Rising Edge
            if(frame_counter == frame_rate_divider) begin

                // Elevator Movement
                if(on) begin
							if(stable && elevator_Pos_Y != elevator_End_Pos_Y) stable_in=1'b0;
                    if(!stable) begin
                        if(elevator_Pos_Y_in == elevator_End_Pos_Y) stable_in=1'b1;
                        else elevator_Pos_Y_in += elevator_max_velocity;
                    end
                end
                else begin
							if(stable && elevator_Pos_Y != elevator_Start_Pos_Y) stable_in=1'b0;
                    if(!stable) begin
                        if(elevator_Pos_Y_in == elevator_Start_Pos_Y) stable_in=1'b1;
                        else elevator_Pos_Y_in -= elevator_max_velocity;
                    end
                end
            end

            // Update frame counter for lowered frame clk
            if(frame_counter == frame_rate_divider) frame_counter_in = 2'd0;
            else frame_counter_in = frame_counter+2'd1;

            /* --- Calculate Elevator-Player Collision Logics --- */

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




    /* --- Gathering and producing info for related switches --- */

    // Example for really use the flexible switch count for each elevator below: (might use latch)
    // But for simplicity, we'll just assume and use universal max_switch_count and it should always be filled..
    // shortint switch_count, switch_count_in;
    // initial begin
    //     switch_count=max_switch_count;
    //     switch_count_in=switch_count;
    //     for (int i = 0; i < max_switch_count; i++) begin
    //         if(switch_X_Pos[i] < 0) switch_count_in--;
    //     end
    //     switch_count=switch_count_in;
    // end

    logic switchs_on [switch_count-1:0];
    logic is_switchs [switch_count-1:0];
    logic [8:0] switchs_read_addr [switch_count-1:0];

    always_comb begin

        is_switch = 1'b0;
        switch_read_addr = 9'h00;
        switch_data = 8'h00;
        on_in = 1'b0;

        for (int i = 0; i < switch_count ; i++) begin
            if(switchs_on[i]) on_in=1'b1;
            else if(is_switchs[i]) begin //use elif for skipping rendering for cases switch being pressed
                is_switch = 1'b1;
                switch_read_addr = switchs_read_addr[i];
                switch_data = switch_data_buf;
            end
        end
    end

    Elevator_Switch switch_list [switch_count-1:0] (.*, .state(switchs_on), .is_switch(is_switchs), .switch_read_addr(switchs_read_addr));

    // switch Sprite Data Processing
    logic [8:0] switch_read_addr;
    logic [7:0] switch_data_buf;

    // For simplicity reason, didnt do even higher level abstract/sorting data..
    // which means, each elevator will have one switchROM for its own switches..
    switchROM switchROM_inst(.*, .switch_data_out(switch_data_buf));


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
    input [9:0] DrawX, DrawY,
    input shortint switch_X_Pos, switch_Y_Pos,
    input shortint player1_top, player1_bottom, player1_left, player1_right,
    input shortint player2_top, player2_bottom, player2_left, player2_right,
    output state, //0 for not pressed, 1 for pressed
    output is_switch, //for simplicity, we can only use same type of elevater switch thus one shared elevator together with switch state to determine the switch_data!
    output logic [8:0] switch_read_addr
);

    parameter shortint switch_width = 32;
    parameter shortint switch_height = 12;

    shortint switch_left, switch_right;
	 assign switch_left = switch_X_Pos+8;
    assign switch_right = switch_X_Pos+switch_width-8;

    logic state_in;

    always_ff @ (posedge Clk) begin
        if(Reset) state <= 1'b0;
        else begin
            state <= state_in;
        end
    end

    always_comb begin
        state_in = 1'b0;
        if(player1_right > switch_left && player1_left < switch_right && player1_bottom > switch_Y_Pos && player1_top < switch_Y_Pos+switch_height) state_in=1'b1;
        if(player2_right > switch_left && player2_left < switch_right && player2_bottom > switch_Y_Pos && player2_top < switch_Y_Pos+switch_height) state_in=1'b1;
    end

    /* ---- Sprite Logics ---- */
    // Calculate is_switch logic
    shortint offset_X, offset_Y;

    always_comb begin
        offset_X = DrawX-switch_X_Pos;
        offset_Y = DrawY-switch_Y_Pos;
        is_switch = 1'b0;

        if(offset_X>=0 && offset_X<switch_width && offset_Y>=0 && offset_Y<switch_height) begin
            is_switch=1'b1;
        end
    end

    // Sprite Data Processing ==> Pass to the parent controller for saving Rom space
    assign switch_read_addr = is_switch ? offset_X + offset_Y*switch_width : 19'b00;

endmodule



module switchROM
(
	input [8:0] switch_read_addr,
	input Clk,

	output logic [7:0] switch_data_out
);

    logic [7:0] mem_switch [0:383];

    initial
    begin
        $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/switch.txt", mem_switch);
    end

    always_ff @ (posedge Clk)
    begin
        switch_data_out <= mem_switch[switch_read_addr];
    end

endmodule