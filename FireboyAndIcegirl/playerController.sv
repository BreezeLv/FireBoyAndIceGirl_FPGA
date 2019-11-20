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
parameter [9:0] fireboy_X_Min = 10'd0;       // Leftmost point on the X axis
parameter [9:0] fireboy_X_Max = 10'd639;     // Rightmost point on the X axis
parameter [9:0] fireboy_Y_Min = 10'd0;       // Topmost point on the Y axis
parameter [9:0] fireboy_Y_Max = 10'd479;     // Bottommost point on the Y axis
parameter [9:0] fireboy_start_pos_X = 10'd32;
parameter [9:0] fireboy_start_pos_Y = 10'd416;
parameter [9:0] fireboy_max_velocity_X = 10'd2;

parameter [9:0] fireboy_max_jump_height = 10'd120;
parameter [9:0] fireboy_gravity = 10'd10;

parameter [2:0] fireboy_idle_frame_size = 2'd4;
parameter [1:0] fireboy_idle_frame_duration = 2'd3;

// movement variables
logic [9:0] fireboy_X_Pos, fireboy_X_Motion, fireboy_Y_Pos, fireboy_Y_Motion;
logic [9:0] fireboy_X_Pos_in, fireboy_X_Motion_in, fireboy_Y_Pos_in, fireboy_Y_Motion_in;

//animation variables
logic [2:0] frame_index, frame_index_in;
logic [1:0] frame_counter, frame_counter_in; // for partially slow the frame rate
enum logic [1:0] {
    Idle, Run, Jump, Fall
} anim_type, anim_type_in;

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
        fireboy_X_Motion <= 10'd0;
        fireboy_Y_Motion <= 10'd0;
        frame_index <= 3'b00;
        frame_counter <= 2'b00;
        anim_type <= Idle;
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
    end
end

always_comb
begin
    // By default, keep motion and position unchanged
    fireboy_X_Pos_in = fireboy_X_Pos;
    fireboy_Y_Pos_in = fireboy_Y_Pos;
    fireboy_X_Motion_in = fireboy_X_Motion;
    fireboy_Y_Motion_in = fireboy_Y_Motion;
	 
	frame_index_in = frame_index;
	frame_counter_in = frame_counter;
    anim_type_in = anim_type;

    //keybaord interrput
    // if(keycode == 8'h1a) begin fireboy_Y_Motion_in = (~(Ball_Y_Step) + 1'b1); end
    // else if(keycode == 8'h16) begin fireboy_Y_Motion_in = Ball_Y_Step; end
    if(keycode == 8'h04) begin fireboy_X_Motion_in = (~(fireboy_max_velocity_X) + 1'b1); end
    else if(keycode == 8'h07) begin fireboy_X_Motion_in = fireboy_max_velocity_X; end

    // Update position and motion only at rising edge of frame clock
    if (frame_clk_rising_edge)
    begin

        /* ---- Player Movement Logics ---- */

        // Be careful when using comparators with "logic" datatype because compiler treats 
        //   both sides of the operator as UNSIGNED numbers.
        // Bound the fireboy pos to be stayed in frame
        // if( fireboy_Y_Pos + fireboy_height >= fireboy_Y_Max && fireboy_Y_Motion_in>0) fireboy_Y_Motion_in = 10'b0;
        // else if ( fireboy_Y_Pos <= fireboy_Y_Min && fireboy_Y_Motion_in<0) fireboy_Y_Motion_in = 10'b0;
        // if( fireboy_X_Pos + fireboy_width >= fireboy_X_Max && fireboy_X_Motion_in>0) fireboy_X_Motion_in = 10'b0; 
        // else if ( fireboy_X_Pos <= fireboy_X_Min && fireboy_X_Motion_in<0) fireboy_X_Motion_in = 10'b0;
    
        // Update the ball's position with its motion
        fireboy_X_Pos_in = fireboy_X_Pos + fireboy_X_Motion_in;
        fireboy_Y_Pos_in = fireboy_Y_Pos + fireboy_Y_Motion_in;
		
        // Bound the fireboy pos to be stayed in frame
        if(fireboy_X_Pos_in < fireboy_X_Min) fireboy_X_Pos_in=10'b0;
        else if(fireboy_X_Pos_in + fireboy_width >= fireboy_X_Max) fireboy_X_Pos_in=fireboy_X_Max-10'b01;
        if(fireboy_Y_Pos_in < fireboy_Y_Min) fireboy_Y_Pos_in=10'b0;
        else if(fireboy_Y_Pos_in + fireboy_height >= fireboy_Y_Max) fireboy_Y_Pos_in=fireboy_Y_Max-10'b01;
		

        /* ---- Animation Logics ---- */
        frame_counter_in = frame_counter+2'd1; //increment frame counter every frame
        if(frame_counter == 2'd3) begin
            frame_counter_in = 2'd0;
            frame_index_in = (frame_index+3'b01)%fireboy_idle_frame_size;
        end
        // Update Animation Type
        if(fireboy_Y_Motion_in > 0) anim_type_in = Jump;
        else if(fireboy_Y_Motion_in < 0) anim_type_in = Fall;
        else if(fireboy_X_Motion_in != 0) anim_type_in = Run;
        // Overwrite/Reset Frame Index if switch Animation Type
        if(anim_type_in != anim_type) begin frame_index_in=2'd0; frame_counter_in=2'd0 end

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
// assign fireboy_read_addr = is_fireboy ? (fireboy_X_Motion_in<0 ? (fireboy_width-offset_X) + offset_Y*fireboy_width : offset_X + offset_Y*fireboy_width) : 19'b00;
fireboyROM fireboyROM_inst(.*, .frame_index(frame_index), .fireboy_data_out(fireboy_data));
	
endmodule



module fireboyROM
(
	input [18:0] fireboy_read_addr,
	input Clk,
    input logic [1:0] frame_index, anim_type,

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
                2'd1: mem_content = mem_run_1[fireboy_read_addr];
                2'd2: mem_content = mem_run_2[fireboy_read_addr];
                2'd3: mem_content = mem_run_3[fireboy_read_addr];
                default: mem_content = mem_run_0[fireboy_read_addr];
            endcase
        end

        default: begin
            case(frame_index)
                2'd1: mem_content = mem_idle_1[fireboy_read_addr];
                2'd2: mem_content = mem_idle_2[fireboy_read_addr];
                2'd3: mem_content = mem_idle_3[fireboy_read_addr];
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