module FrameBuffer (
    input Clk, blank,
    input [9:0] DrawX, DrawY,

    output [7:0] pixel_out
);

logic [18:0] frame_read_addr, frame_write_addr;
assign frame_read_addr = blank ? 0 : DrawX+DrawY*480;

FrameRAM FrameRAM_inst (.*, .WE(), .frame_data_out(pixel_out));

endmodule



module FrameRAM (
    input Clk, WE,
    input [18:0] frame_read_addr, frame_write_addr,
    input [7:0] frame_data_in,

    output logic [7:0] frame_data_out
);

logic [7:0] frameBuffer [0:307199];

always_ff @(posedge Clk) begin
    if(WE && frame_data_in!=8'b00) frameBuffer[frame_write_addr] <= frame_data_in;
    frame_data_out <= frameBuffer[frame_read_addr];
end
    
endmodule