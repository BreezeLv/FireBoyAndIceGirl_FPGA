typedef enum logic [1:0] {
    Idle, Run, Jump, Fall
} anim_type_enum;

module FireBoy (
	input Clk, frame_clk, revive,
	input [9:0] DrawX, DrawY,
	input logic fireboy_jump, fireboy_left, fireboy_right,
    input logic is_collide_player1,
    input shortint player1_X_Min, player1_X_Max, player1_Y_Min, player1_Y_Max,
    input logic player1_dead,

    output logic is_fireboy,
    output logic player1_win,
	output logic [7:0] fireboy_data,
    output shortint player1_top, player1_bottom, player1_left, player1_right
);

// Fireboy parameters
parameter [9:0] fireboy_width = 32;
parameter [9:0] fireboy_height = 48;
parameter [9:0] fireboy_start_pos_X = 10'd32;
parameter [9:0] fireboy_start_pos_Y = 10'd414;
parameter [9:0] fireboy_max_velocity_X = 10'd2;

parameter [9:0] fireboy_end_pos_X = 10'd544;
parameter [9:0] fireboy_end_pos_Y = 10'd126;
parameter shortint exit_radius = 16;

parameter shortint fireboy_jump_v0 = -4; //initial velocity
parameter shortint fireboy_gravity = 1;

parameter [2:0] fireboy_idle_frame_size = 3'd4;
parameter [1:0] fireboy_idle_frame_duration = 2'd3;

parameter byte gravity_frame_rate_divider = 5;

// Movement variables
shortint fireboy_X_Pos, fireboy_X_Motion, fireboy_Y_Pos, fireboy_Y_Motion;
shortint fireboy_X_Pos_in, fireboy_X_Motion_in, fireboy_Y_Pos_in, fireboy_Y_Motion_in;

// Collision Boundary
shortint fireboy_X_Min, fireboy_X_Max, fireboy_Y_Min, fireboy_Y_Max;
Collider fireboy_collider_inst(.player_X_Pos(fireboy_X_Pos), .player_Y_Pos(fireboy_Y_Pos), .player_X_Min(fireboy_X_Min), .player_X_Max(fireboy_X_Max), .player_Y_Min(fireboy_Y_Min), .player_Y_Max(fireboy_Y_Max));

// jump variables
logic is_grounded, is_grounded_in;
byte gravity_counter, gravity_counter_in;

// Animation variables
logic [2:0] frame_index, frame_index_in;
logic [1:0] frame_counter, frame_counter_in; // for partially slow the frame rate
anim_type_enum anim_type, anim_type_in;

// "Fit" Sprite Helper Position
assign player1_top = fireboy_Y_Pos + 10;
assign player1_bottom = fireboy_Y_Pos + fireboy_height - 4;
assign player1_left = fireboy_X_Pos + 4;
assign player1_right = fireboy_X_Pos + fireboy_width - 4;

//Winning Condition
assign player1_win = (player1_right > fireboy_end_pos_X-exit_radius && player1_left < fireboy_end_pos_X+exit_radius && player1_bottom > fireboy_end_pos_Y-exit_radius && player1_top < fireboy_end_pos_Y+exit_radius);

// Detect rising edge of frame_clk
logic frame_clk_delayed, frame_clk_rising_edge;
always_ff @ (posedge Clk) begin
    frame_clk_delayed <= frame_clk;
    frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
end

// Update registers
always_ff @ (posedge Clk)
begin
    if (revive)
    begin
        fireboy_X_Pos <= fireboy_start_pos_X;
        fireboy_Y_Pos <= fireboy_start_pos_Y;
        fireboy_X_Motion <= 0;
        fireboy_Y_Motion <= 0;
        frame_index <= 3'b00;
        frame_counter <= 2'b00;
        anim_type <= Idle;
        is_grounded <= 1'b1;
        gravity_counter <= 0;
    end
    else
    begin
        fireboy_X_Pos <= fireboy_X_Pos_in;
        fireboy_Y_Pos <= fireboy_Y_Pos_in;
        fireboy_X_Motion <= fireboy_X_Motion_in;
        fireboy_Y_Motion <= fireboy_Y_Motion_in;
        frame_index <= frame_index_in;
        frame_counter <= frame_counter_in;
        anim_type <= anim_type_in;
        is_grounded <= is_grounded_in;
        gravity_counter <= gravity_counter_in;
    end
end

always_comb
begin
    // By default, keep motion and position unchanged
    fireboy_X_Pos_in = fireboy_X_Pos;
    fireboy_Y_Pos_in = fireboy_Y_Pos;
    fireboy_X_Motion_in = 32'b0;
    fireboy_Y_Motion_in = fireboy_Y_Motion;
	 
	frame_index_in = frame_index;
	frame_counter_in = frame_counter;
    anim_type_in = anim_type;
    is_grounded_in = is_grounded;
    gravity_counter_in = gravity_counter;

    //keybaord interrput
    if(fireboy_left && !player1_dead) begin fireboy_X_Motion_in = (~(fireboy_max_velocity_X) + 1'b1); end
    else if(fireboy_right && !player1_dead) begin fireboy_X_Motion_in = fireboy_max_velocity_X; end

    // Update position and motion only at rising edge of frame clock
    if (frame_clk_rising_edge && !player1_dead)
    begin

        /* ---- Player Movement Logics ---- */
        // Jump
        // make fireboy always pulling by gravity, and falling as much as possible
        // (think about the case when fireboy falling from an edge of a platform..)
		  gravity_counter_in = gravity_counter + 1;
        if(gravity_counter == gravity_frame_rate_divider) begin
            gravity_counter_in = 0;
            fireboy_Y_Motion_in = fireboy_Y_Motion + fireboy_gravity; // add a divisor to gravitiy..
        end
        if(fireboy_jump && is_grounded) begin fireboy_Y_Motion_in = fireboy_jump_v0; is_grounded_in=1'b0; end
        
    
        // Update the ball's position with its motion
        fireboy_X_Pos_in = fireboy_X_Pos + fireboy_X_Motion_in;
        fireboy_Y_Pos_in = fireboy_Y_Pos + fireboy_Y_Motion_in;
		
        // Bound the fireboy pos to be stayed in frame
        if(fireboy_X_Pos_in < fireboy_X_Min - 4) fireboy_X_Pos_in=fireboy_X_Min-4;
        else if(fireboy_X_Pos_in + fireboy_width >= fireboy_X_Max+4) fireboy_X_Pos_in=fireboy_X_Max-fireboy_width-1+4;
        if(fireboy_Y_Pos_in < fireboy_Y_Min) begin fireboy_Y_Pos_in=fireboy_Y_Min; fireboy_Y_Motion_in=0; end //jump touch the ceiling
        else if(fireboy_Y_Pos_in + fireboy_height >= fireboy_Y_Max) begin fireboy_Y_Pos_in=fireboy_Y_Max-fireboy_height-1; is_grounded_in=1'b1; fireboy_Y_Motion_in=0; end // fall to the floor

        // Additional Collision Bounding from Elevators..
        if(is_collide_player1) begin
           if(fireboy_X_Pos_in < player1_X_Min - 4) fireboy_X_Pos_in=player1_X_Min-4;
            else if(fireboy_X_Pos_in + fireboy_width >= player1_X_Max+4) fireboy_X_Pos_in=player1_X_Max-fireboy_width-1+4;
            if(fireboy_Y_Pos_in < player1_Y_Min-10) begin fireboy_Y_Pos_in=player1_Y_Min-10; fireboy_Y_Motion_in=0; end
            else if(fireboy_Y_Pos_in + fireboy_height >= player1_Y_Max+4) begin fireboy_Y_Pos_in=player1_Y_Max-fireboy_height-1+4; is_grounded_in=1'b1; fireboy_Y_Motion_in=0; end 
        end

        /* ---- Animation Logics ---- */
        frame_counter_in = frame_counter+2'd1; //increment frame counter every frame, this is for lower the frame rate..
        if(frame_counter == 2'd3) begin
            frame_counter_in = 2'd0;
            frame_index_in = (frame_index+3'b01)%fireboy_idle_frame_size;
        end
        // Update Animation Type
//        if(fireboy_Y_Motion_in > 0) anim_type_in = Jump;
//        else if(fireboy_Y_Motion_in < 0) anim_type_in = Fall;
        if(fireboy_X_Motion_in != 32'b0) anim_type_in = Run;
		  else anim_type_in = Idle;
        // Overwrite/Reset Frame Index if switch Animation Type
        if(anim_type_in != anim_type) begin frame_index_in=3'd0; frame_counter_in=2'd0; end

    end

end

// Calculate the is_fireboy logic
logic [9:0] offset_X, offset_Y;
always_comb begin
    offset_X = DrawX-fireboy_X_Pos;
    offset_Y = DrawY-fireboy_Y_Pos;
    is_fireboy = 1'b0;

    if(offset_X>=0 && offset_X<fireboy_width && offset_Y>=0 && offset_Y<fireboy_height) begin
       if(fireboy_X_Motion_in<0) offset_X = fireboy_width-offset_X;
       is_fireboy=1'b1; 
    end
end


// Sprite Data Processing
logic [18:0] fireboy_read_addr;
assign fireboy_read_addr = is_fireboy ? offset_X + offset_Y*fireboy_width : 19'b00;
fireboyROM fireboyROM_inst(.*, .frame_index(frame_index), .fireboy_data_out(fireboy_data));
	
endmodule



module fireboyROM
(
	input [18:0] fireboy_read_addr,
	input Clk,
    input logic [2:0] frame_index, 
    input anim_type_enum anim_type,

	output logic [7:0] fireboy_data_out
);

//logic [7:0] mem [0:2][0:1535];
logic [7:0] mem_idle_0 [0:1535];
logic [7:0] mem_idle_1 [0:1535];
logic [7:0] mem_idle_2 [0:1535];
logic [7:0] mem_idle_3 [0:1535];

logic [7:0] mem_run_0 [0:1535];
logic [7:0] mem_run_1 [0:1535];
logic [7:0] mem_run_2 [0:1535];
logic [7:0] mem_run_3 [0:1535];

initial
begin
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_idle_frame_0.txt", mem_idle_0);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_idle_frame_1.txt", mem_idle_1);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_idle_frame_2.txt", mem_idle_2);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_idle_frame_3.txt", mem_idle_3);

     $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_run_frame_0.txt", mem_run_0);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_run_frame_2.txt", mem_run_1);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_run_frame_4.txt", mem_run_2);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_run_frame_6.txt", mem_run_3);
end

logic [7:0] mem_content;
always_comb begin
    case(anim_type)
        Run: begin
            case(frame_index)
                3'd1: mem_content = mem_run_1[fireboy_read_addr];
                3'd2: mem_content = mem_run_2[fireboy_read_addr];
                3'd3: mem_content = mem_run_3[fireboy_read_addr];
                default: mem_content = mem_run_0[fireboy_read_addr];
            endcase
        end

        default: begin
            case(frame_index)
                3'd1: mem_content = mem_idle_1[fireboy_read_addr];
                3'd2: mem_content = mem_idle_2[fireboy_read_addr];
                3'd3: mem_content = mem_idle_3[fireboy_read_addr];
                default: mem_content = mem_idle_0[fireboy_read_addr];
            endcase
        end
    endcase
end
//assign mem_content = mem[frame_index][fireboy_read_addr];

always_ff @ (posedge Clk)
begin
	fireboy_data_out <= mem_content;
end

endmodule






module IceGirl (
	input Clk, frame_clk, revive,
	input [9:0] DrawX, DrawY,
	input logic icegirl_jump, icegirl_left, icegirl_right,
    input logic is_collide_player2,
    input shortint player2_X_Min, player2_X_Max, player2_Y_Min, player2_Y_Max,
    input logic player2_dead,

    output logic is_icegirl,
    output logic player2_win,
	output logic [7:0] icegirl_data,
    output shortint player2_top, player2_bottom, player2_left, player2_right
);

// Icegirl parameters
parameter [9:0] icegirl_width = 48;
parameter [9:0] icegirl_height = 48;
parameter [9:0] icegirl_start_pos_X = 10'd24;
parameter [9:0] icegirl_start_pos_Y = 10'd350;
parameter [9:0] icegirl_max_velocity_X = 10'd2;

parameter [9:0] icegirl_end_pos_X = 10'd544;
parameter [9:0] icegirl_end_pos_Y = 10'd126;
parameter shortint exit_radius = 16;

parameter shortint icegirl_jump_v0 = -4; //initial velocity
parameter shortint icegirl_gravity = 1;

parameter [2:0] icegirl_idle_frame_size = 3'd4;
parameter [1:0] icegirl_idle_frame_duration = 2'd3;

parameter byte gravity_frame_rate_divider = 5;

// Movement variables
shortint icegirl_X_Pos, icegirl_X_Motion, icegirl_Y_Pos, icegirl_Y_Motion;
shortint icegirl_X_Pos_in, icegirl_X_Motion_in, icegirl_Y_Pos_in, icegirl_Y_Motion_in;

// Collision Boundary
shortint icegirl_X_Min, icegirl_X_Max, icegirl_Y_Min, icegirl_Y_Max;
Collider icegirl_collider_inst(.player_X_Pos(icegirl_X_Pos), .player_Y_Pos(icegirl_Y_Pos), .player_X_Min(icegirl_X_Min), .player_X_Max(icegirl_X_Max), .player_Y_Min(icegirl_Y_Min), .player_Y_Max(icegirl_Y_Max));

// Jump variables
logic is_grounded, is_grounded_in;
byte gravity_counter, gravity_counter_in;

// Animation variables
logic [2:0] frame_index, frame_index_in;
logic [1:0] frame_counter, frame_counter_in; // for partially slow the frame rate
anim_type_enum anim_type, anim_type_in;

// "Fit" Sprite Helper Position
assign player2_top = icegirl_Y_Pos + 10;
assign player2_bottom = icegirl_Y_Pos + icegirl_height - 4;
assign player2_left = icegirl_X_Pos + 13;
assign player2_right = icegirl_X_Pos + icegirl_width - 13;

//Winning Condition
assign player2_win = (player2_right > icegirl_end_pos_X-exit_radius && player2_left < icegirl_end_pos_X+exit_radius && player2_bottom > icegirl_end_pos_Y-exit_radius && player2_top < icegirl_end_pos_Y+exit_radius);

// Detect rising edge of frame_clk
logic frame_clk_delayed, frame_clk_rising_edge;
always_ff @ (posedge Clk) begin
    frame_clk_delayed <= frame_clk;
    frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
end

// Update registers
always_ff @ (posedge Clk)
begin
    if (revive)
    begin
        icegirl_X_Pos <= icegirl_start_pos_X;
        icegirl_Y_Pos <= icegirl_start_pos_Y;
        icegirl_X_Motion <= 0;
        icegirl_Y_Motion <= 0;
        frame_index <= 3'b00;
        frame_counter <= 2'b00;
        anim_type <= Idle;
        is_grounded <= 1'b1;
        gravity_counter <= 0;
    end
    else
    begin
        icegirl_X_Pos <= icegirl_X_Pos_in;
        icegirl_Y_Pos <= icegirl_Y_Pos_in;
        icegirl_X_Motion <= icegirl_X_Motion_in;
        icegirl_Y_Motion <= icegirl_Y_Motion_in;
        frame_index <= frame_index_in;
        frame_counter <= frame_counter_in;
        anim_type <= anim_type_in;
        is_grounded <= is_grounded_in;
        gravity_counter <= gravity_counter_in;
    end
end

always_comb
begin
    // By default, keep motion and position unchanged
    icegirl_X_Pos_in = icegirl_X_Pos;
    icegirl_Y_Pos_in = icegirl_Y_Pos;
    icegirl_X_Motion_in = 32'b0;
    icegirl_Y_Motion_in = icegirl_Y_Motion;
	 
	frame_index_in = frame_index;
	frame_counter_in = frame_counter;
    anim_type_in = anim_type;
    is_grounded_in = is_grounded;
    gravity_counter_in = gravity_counter;

    //keybaord interrput
    if(icegirl_left && !player2_dead) begin icegirl_X_Motion_in = (~(icegirl_max_velocity_X) + 1'b1); end
    else if(icegirl_right && !player2_dead) begin icegirl_X_Motion_in = icegirl_max_velocity_X; end

    // Update position and motion only at rising edge of frame clock
    if (frame_clk_rising_edge && !player2_dead)
    begin

        /* ---- Player Movement Logics ---- */
        // Jump
        // make icegirl always pulling by gravity, and falling as much as possible
        // (think about the case when icegirl falling from an edge of a platform..)
		  gravity_counter_in = gravity_counter + 1;
        if(gravity_counter == gravity_frame_rate_divider) begin
            gravity_counter_in = 0;
            icegirl_Y_Motion_in = icegirl_Y_Motion + icegirl_gravity; // add a divisor to gravitiy..
        end
        if(icegirl_jump && is_grounded) begin icegirl_Y_Motion_in = icegirl_jump_v0; is_grounded_in=1'b0; end
        
    
        // Update the ball's position with its motion
        icegirl_X_Pos_in = icegirl_X_Pos + icegirl_X_Motion_in;
        icegirl_Y_Pos_in = icegirl_Y_Pos + icegirl_Y_Motion_in;
		
        // Bound the icegirl pos to be stayed in frame
        if(icegirl_X_Pos_in < icegirl_X_Min-13) icegirl_X_Pos_in=icegirl_X_Min-13;
        else if(icegirl_X_Pos_in + icegirl_width >= icegirl_X_Max+13) icegirl_X_Pos_in=icegirl_X_Max-icegirl_width-1+13;
        if(icegirl_Y_Pos_in < icegirl_Y_Min) begin icegirl_Y_Pos_in=icegirl_Y_Min; icegirl_Y_Motion_in=0; end //jump touch the ceiling
        else if(icegirl_Y_Pos_in + icegirl_height >= icegirl_Y_Max) begin icegirl_Y_Pos_in=icegirl_Y_Max-icegirl_height-1; is_grounded_in=1'b1; icegirl_Y_Motion_in=0; end // fall to the floor
		
        // Additional Collision Bounding from Elevators..
        if(is_collide_player2) begin
           if(icegirl_X_Pos_in < player2_X_Min - 13) icegirl_X_Pos_in=player2_X_Min-13;
            else if(icegirl_X_Pos_in + icegirl_width >= player2_X_Max+13) icegirl_X_Pos_in=player2_X_Max-icegirl_width-1+13;
            if(icegirl_Y_Pos_in < player2_Y_Min - 10) begin icegirl_Y_Pos_in=player2_Y_Min-10; icegirl_Y_Motion_in=0; end
            else if(icegirl_Y_Pos_in + icegirl_height >= player2_Y_Max+4) begin icegirl_Y_Pos_in=player2_Y_Max-icegirl_height-1+4; is_grounded_in=1'b1; icegirl_Y_Motion_in=0; end 
        end

        /* ---- Animation Logics ---- */
        frame_counter_in = frame_counter+2'd1; //increment frame counter every frame, this is for lower the frame rate..
        if(frame_counter == 2'd3) begin
            frame_counter_in = 2'd0;
            frame_index_in = (frame_index+3'b01)%icegirl_idle_frame_size;
        end
        // Update Animation Type
//        if(icegirl_Y_Motion_in > 0) anim_type_in = Jump;
//        else if(icegirl_Y_Motion_in < 0) anim_type_in = Fall;
        if(icegirl_X_Motion_in != 32'b0) anim_type_in = Run;
		  else anim_type_in = Idle;
        // Overwrite/Reset Frame Index if switch Animation Type
        if(anim_type_in != anim_type) begin frame_index_in=3'd0; frame_counter_in=2'd0; end

    end

end

// Calculate the is_icegirl logic
logic [9:0] offset_X, offset_Y;
always_comb begin
    offset_X = DrawX-icegirl_X_Pos;
    offset_Y = DrawY-icegirl_Y_Pos;
    is_icegirl = 1'b0;

    if(offset_X>=0 && offset_X<icegirl_width && offset_Y>=0 && offset_Y<icegirl_height) begin
       if(icegirl_X_Motion_in<0) offset_X = icegirl_width-offset_X;
       is_icegirl=1'b1; 
    end
end


// Sprite Data Processing
logic [18:0] icegirl_read_addr;
assign icegirl_read_addr = is_icegirl ? offset_X + offset_Y*icegirl_width : 19'b00;
icegirlROM icegirlROM_inst(.*, .frame_index(frame_index), .icegirl_data_out(icegirl_data));
	
endmodule



module icegirlROM
(
	input [18:0] icegirl_read_addr,
	input Clk,
    input logic [2:0] frame_index, 
    input anim_type_enum anim_type,

	output logic [7:0] icegirl_data_out
);

//logic [7:0] mem [0:2][0:2303];
logic [7:0] mem_idle_0 [0:2303];
logic [7:0] mem_idle_1 [0:2303];
logic [7:0] mem_idle_2 [0:2303];
logic [7:0] mem_idle_3 [0:2303];

logic [7:0] mem_run_0 [0:2303];
logic [7:0] mem_run_1 [0:2303];
logic [7:0] mem_run_2 [0:2303];
logic [7:0] mem_run_3 [0:2303];

initial
begin
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/icegirl_idle_frame_0.txt", mem_idle_0);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/icegirl_idle_frame_1.txt", mem_idle_1);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/icegirl_idle_frame_2.txt", mem_idle_2);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/icegirl_idle_frame_3.txt", mem_idle_3);

     $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/icegirl_run_frame_0.txt", mem_run_0);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/icegirl_run_frame_1.txt", mem_run_1);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/icegirl_run_frame_2.txt", mem_run_2);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/icegirl_run_frame_3.txt", mem_run_3);
end

logic [7:0] mem_content;
always_comb begin
    case(anim_type)
        Run: begin
            case(frame_index)
                3'd1: mem_content = mem_run_1[icegirl_read_addr];
                3'd2: mem_content = mem_run_2[icegirl_read_addr];
                3'd3: mem_content = mem_run_3[icegirl_read_addr];
                default: mem_content = mem_run_0[icegirl_read_addr];
            endcase
        end

        default: begin
            case(frame_index)
                3'd1: mem_content = mem_idle_1[icegirl_read_addr];
                3'd2: mem_content = mem_idle_2[icegirl_read_addr];
                3'd3: mem_content = mem_idle_3[icegirl_read_addr];
                default: mem_content = mem_idle_0[icegirl_read_addr];
            endcase
        end
    endcase
end
//assign mem_content = mem[frame_index][icegirl_read_addr];

always_ff @ (posedge Clk)
begin
	icegirl_data_out <= mem_content;
end

endmodule