typedef enum logic [1:0] {
    Idle, Run, Jump, Fall
} anim_type_enum;

module FireBoy (
	input Clk, frame_clk, revive,
	input [7:0] keycode,
	input [9:0] DrawX, DrawY,

    output logic is_fireboy,
	output logic [7:0] fireboy_data
);

// Fireboy parameters
parameter [9:0] fireboy_width = 32;
parameter [9:0] fireboy_height = 48;
// integer         fireboy_X_Min = 0;       // Leftmost point on the X axis
// integer         fireboy_X_Max = 639;     // Rightmost point on the X axis
// integer         fireboy_Y_Min = 0;       // Topmost point on the Y axis
// integer         fireboy_Y_Max = 479;     // Bottommost point on the Y axis
parameter [9:0] fireboy_start_pos_X = 10'd32;
parameter [9:0] fireboy_start_pos_Y = 10'd416;
parameter [9:0] fireboy_max_velocity_X = 10'd2;

parameter integer fireboy_jump_v0 = -7; //initial velocity
parameter integer fireboy_gravity = 1;

parameter [2:0] fireboy_idle_frame_size = 3'd4;
parameter [1:0] fireboy_idle_frame_duration = 2'd3;

// movement variables
integer fireboy_X_Pos, fireboy_X_Motion, fireboy_Y_Pos, fireboy_Y_Motion;
integer fireboy_X_Pos_in, fireboy_X_Motion_in, fireboy_Y_Pos_in, fireboy_Y_Motion_in;

// Collision Boundary
integer fireboy_X_Min, fireboy_X_Max, fireboy_Y_Min, fireboy_Y_Max;
Collider fireboy_collider_inst(.player_X_Pos(fireboy_X_Pos), .player_Y_Pos(fireboy_Y_Pos), .player_X_Min(fireboy_X_Min), .player_X_Max(fireboy_X_Max), .player_Y_Min(fireboy_Y_Min), .player_Y_Max(fireboy_Y_Max));

// jump variables
logic is_grounded, is_grounded_in;

//animation variables
logic [2:0] frame_index, frame_index_in;
logic [1:0] frame_counter, frame_counter_in; // for partially slow the frame rate
anim_type_enum anim_type, anim_type_in;

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

    //keybaord interrput
    // if(keycode == 8'h1a && is_grounded) begin fireboy_Y_Motion_in = fireboy_jump_v0; is_grounded=1'b0; end //Jump
    if(keycode == 8'h04) begin fireboy_X_Motion_in = (~(fireboy_max_velocity_X) + 1'b1); end
    else if(keycode == 8'h07) begin fireboy_X_Motion_in = fireboy_max_velocity_X; end
//	 else begin fireboy_Y_Motion_in = 0; end

    // Update position and motion only at rising edge of frame clock
    if (frame_clk_rising_edge)
    begin

        /* ---- Player Movement Logics ---- */
        // Jump
        // make fireboy always pulling by gravity, and falling as much as possible
        // (think about the case when fireboy falling from an edge of a platform..)
        if(frame_counter == 2'd3) begin
            fireboy_Y_Motion_in = fireboy_Y_Motion + fireboy_gravity; // add a divisor to gravitiy..
        end
        if(keycode == 8'h1a && is_grounded) begin fireboy_Y_Motion_in = fireboy_jump_v0; is_grounded_in=1'b0; end
        
    
        // Update the ball's position with its motion
        fireboy_X_Pos_in = fireboy_X_Pos + fireboy_X_Motion_in;
        fireboy_Y_Pos_in = fireboy_Y_Pos + fireboy_Y_Motion_in;
		
        // Bound the fireboy pos to be stayed in frame
        if(fireboy_X_Pos_in < fireboy_X_Min) fireboy_X_Pos_in=fireboy_X_Min;
        else if(fireboy_X_Pos_in + fireboy_width >= fireboy_X_Max) fireboy_X_Pos_in=fireboy_X_Max-fireboy_width-1;
        if(fireboy_Y_Pos_in < fireboy_Y_Min) begin fireboy_Y_Pos_in=fireboy_Y_Min; fireboy_Y_Motion_in=0; end //jump touch the ceiling
        else if(fireboy_Y_Pos_in + fireboy_height >= fireboy_Y_Max) begin fireboy_Y_Pos_in=fireboy_Y_Max-fireboy_height-1; is_grounded_in=1'b1; fireboy_Y_Motion_in=0; end // fall to the floor
		
        // // TODO: Collison Detection
        // if(new_pos/pos_in is going to collide) begin
        //     new_pos/pos_in = pos of surface of that colission;
        //     if(fireboy_Y_Motion_in<0) begin 
        //         //case touch the ceiling
        //         fireboy_Y_Motion_in=0;
        //     end
        //     else begin 
        //         //case fall onto the floor
        //         is_grounded_in=1'b1;
        //         fireboy_Y_Motion_in=0;
        //     end
        // end

        /* ---- Animation Logics ---- */
        frame_counter_in = frame_counter+2'd1; //increment frame counter every frame, this is for lower the frame rate..
        if(frame_counter == 2'd3) begin
            frame_counter_in = 2'd0;
            frame_index_in = (frame_index+3'b01)%fireboy_idle_frame_size;
        end
        // Update Animation Type
        if(fireboy_Y_Motion_in > 0) anim_type_in = Jump;
        else if(fireboy_Y_Motion_in < 0) anim_type_in = Fall;
        else if(fireboy_X_Motion_in != 32'b0) anim_type_in = Run;
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