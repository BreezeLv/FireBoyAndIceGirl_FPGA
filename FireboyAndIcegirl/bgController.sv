module bgController (
	input Clk,
	input [9:0] DrawX, DrawY,

	output logic [7:0] bg_data
);

// Background(Wall) parameters
parameter [9:0] bg_wall_width = 96;
parameter [9:0] bg_wall_height = 32;

logic [18:0] bg_read_addr;

assign bg_read_addr = DrawX%bg_wall_width + (DrawY%bg_wall_height)*bg_wall_width;

bgROM bgRom_inst(.*, .bg_data_out(bg_data));
	
endmodule


module bgROM
(
	input [18:0] bg_read_addr,
	input Clk,

	output logic [7:0] bg_data_out
);

logic [7:0] mem_bg [0:3071];

initial
begin
	 $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/wall.txt", mem_bg);
end

// assign bg_data_out = mem_bg[bg_read_addr];
always_ff @ (posedge Clk)
begin
	bg_data_out <= mem_bg[bg_read_addr];
end

endmodule
