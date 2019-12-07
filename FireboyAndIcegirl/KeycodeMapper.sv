module KeycodeMapper (
    input logic [7:0] keycode,
    output logic fireboy_jump, fireboy_left, fireboy_right,
    output logic icegirl_jump, icegirl_left, icegirl_right
);
    assign fireboy_jump = keycode[6];
    assign fireboy_left = keycode[5];
    assign fireboy_right = keycode[4];

    assign icegirl_jump = keycode[2];
    assign icegirl_left = keycode[1];
    assign icegirl_right = keycode[0];
endmodule