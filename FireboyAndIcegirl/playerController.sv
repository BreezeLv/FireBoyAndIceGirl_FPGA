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

parameter [1:0] fireboy_idle_frame_size = 2'd3;
parameter [1:0] fireboy_idle_frame_duration = 2'd3;

// movement variables
logic [9:0] fireboy_X_Pos, fireboy_X_Motion, fireboy_Y_Pos, fireboy_Y_Motion;
logic [9:0] fireboy_X_Pos_in, fireboy_X_Motion_in, fireboy_Y_Pos_in, fireboy_Y_Motion_in;

//animation variables
logic [1:0] frame_index, frame_index_in;
logic [1:0] frame_counter, frame_counter_in;

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
        frame_index <= 2'b00;
		  frame_counter <= 2'b00;
    end
    else
    begin
        fireboy_X_Pos <= fireboy_X_Pos_in;
        fireboy_Y_Pos <= fireboy_Y_Pos_in;
        fireboy_X_Motion <= fireboy_X_Motion_in;
        fireboy_Y_Motion <= fireboy_Y_Motion_in;
        frame_index <= frame_index_in;
		  frame_counter <= frame_counter_in;
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

    //keybaord interrput
    // if(keycode == 8'h1a) begin fireboy_Y_Motion_in = (~(Ball_Y_Step) + 1'b1); end
    // else if(keycode == 8'h16) begin fireboy_Y_Motion_in = Ball_Y_Step; end
    if(keycode == 8'h04) begin fireboy_X_Motion_in = (~(fireboy_max_velocity_X) + 1'b1); end
    else if(keycode == 8'h07) begin fireboy_X_Motion_in = fireboy_max_velocity_X; end

    // Update position and motion only at rising edge of frame clock
    if (frame_clk_rising_edge)
    begin
        // Be careful when using comparators with "logic" datatype because compiler treats 
        //   both sides of the operator as UNSIGNED numbers.
        // Bound the fireboy pos to be stayed in frame
        if( fireboy_Y_Pos + fireboy_height >= fireboy_Y_Max && fireboy_Y_Motion_in>10'b0) fireboy_Y_Motion_in = 10'b0;
        else if ( fireboy_Y_Pos <= fireboy_Y_Min && fireboy_Y_Motion_in<10'b0) fireboy_Y_Motion_in = 10'b0;
        if( fireboy_X_Pos + fireboy_width >= fireboy_X_Max && fireboy_X_Motion_in>10'b0) fireboy_X_Motion_in = 10'b0; 
        else if ( fireboy_X_Pos <= fireboy_X_Min && fireboy_X_Motion_in<10'b0) fireboy_X_Motion_in = 10'b0;
    
        // Update the ball's position with its motion
        fireboy_X_Pos_in = fireboy_X_Pos + fireboy_X_Motion_in;
        fireboy_Y_Pos_in = fireboy_Y_Pos + fireboy_Y_Motion_in;
		  
		  
		  // Animation logics
		  frame_counter_in = frame_counter+2'd1;
		  if(frame_counter == 2'd3) begin
				frame_counter_in = 2'd0;
				frame_index_in = (frame_index+2'b01)%fireboy_idle_frame_size;
		  end
		  
    end

end

// Calculate the is_fireboy logic
logic [9:0] offset_X, offset_Y;
always_comb begin
    offset_X = DrawX-fireboy_X_Pos;
    offset_Y = DrawY-fireboy_Y_Pos;
    is_fireboy = 1'b0;
    if(offset_X>=0 && offset_X<fireboy_width && offset_Y>=0 && offset_Y<fireboy_height) is_fireboy=1'b1;
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
    input logic [1:0] frame_index,

	output logic [7:0] fireboy_data_out
);

//logic [7:0] mem [0:2][0:1535];
 logic [7:0] mem_0 [0:1535];
 logic [7:0] mem_1 [0:1535];
 logic [7:0] mem_2 [0:1535];

initial
begin
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_idle_frame_0.txt", mem_0);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_idle_frame_1.txt", mem_1);
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/fireboy_idle_frame_2.txt", mem_2);
end

logic [7:0] mem_content;
always_comb begin
	case(frame_index)
		2'd1: mem_content = mem_1[fireboy_read_addr];
		2'd2: mem_content = mem_2[fireboy_read_addr];
		default: mem_content = mem_0[fireboy_read_addr];
	endcase
end
//assign mem_content = mem[frame_index][fireboy_read_addr];

always_ff @ (posedge Clk)
begin
	fireboy_data_out <= mem_content;
end

endmodule