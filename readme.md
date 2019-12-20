# Fireboy & Icegirl

## Table of Contents

- [Introduction](#introduction)
- [Description](#written-description)
- [Module Break-down](#module-break-down)
- [Resources Usage](#design-resources-and-statistics-table)
- [Authors](#authors)
- [License](#license)

## Introduction
This is a FPGA implementation of a classic dual player strategy H5/flash game, "Fireboy & Watergirl". We use Altera DE2-115 Development Board as our development board.

This is the major game scene:

![](https://lh4.googleusercontent.com/21kP7BK-jauh41wJt0_v_0UpfAChfHNgvvcx93sYgqeSb6yG65vrFXWO88cDTNWWybGXVCwwUoZQlUVXJj3upt8AvNPjVZ391lpXHGyS6CRziAbEeph5lIcsWRxek0C9aNH0CGw)

## Written Description

### Important Design Components Usage

We plan to develop our project using the On-Chip Memory of the DE2 board. Therefore, in order to fit in the 3.88 Mbit space, we plan and design each game elements as efficient as possible. We use palettes to describe the main colors in graphs to save space.

Memory: Use On-Chip Memory for our sprite storage (as ROM). Use On-Chip Memory for our Background sprites as well as short sound effects, but plan on moving these large storage content to SRAM for saving both compiling time and on-chip memory with affecting the game much.

SoC: Used for FPGA-OTGCY7 chip communication and read HPI ports of OTGCY7 chip as a USB host device from the connected USB device (USB keyboard).

Video: VGA normal mode with 640x480 actual screen size.

Audio: WM8731 stereo codec chip.

  
## Module Break-down

### Top Level: FireboyAndIcegirl_toplevel.sv

--- Module: FireboyAndIcegirl_toplevel

Inputs & Outputs: Clock, On-Board Button-Key, VGA interfaces, OTG CY7C67200, SDRAM interfaces, WM8731 Audio interfaces

The top level of our final project wires up different modules, including the nios system (SoC), hpi_to_intf (Interface between nios ii and OTG chip), vga_clk (PLL generated clk for vga’s usage), VGA_controller (control the VGA monitor to draw colors, define drawing area and control VGA scanlines), Game_Controller (FSM control over the whole game), bgController (Controller over background rendering), Fireboy&Icegirl (Player Controller), KeycodeMapper (Wrapper for keycode output produced from OTG->nios ii->fpga), ScoreController (Controller for gems collecting, score keeping and gems, fonts rendering), ElevatorController (Controller for Elevators and their related switches in the level), WaterController (Controller over water traps in the level), ColorMapper (Palette To 24bit true color transformation and overall rendering logics), HexDriver (For Debug use Hex Display).

In short, we created all parts that are essential to our project in this top level file and wires them up. To conclude, there are 4 parts: 1, Game Components 2, Graphics/Rendering Components 3, I/O Device Driver/Wrapper 4, VGA Monitor Components.

The following graph is the block diagram of the project’s top level module:

![](https://lh4.googleusercontent.com/TzXcrmz9Jm9rSSfqv0VwbMYiE-K2Xe3olY5V46XzSAhyqiAWSS7h-bTnstH2grblqam2EGNdyDw6bazVevRcHKJduImrj3ADySBYfroHbtubCwLK0sHwZHyyvbMy7JdJpG-Fqi8)

### Player: playerController.sv

--- Enum: anim_type_enum

This Enum is constructed by “Idle”, “Run”, “Jump” and “Fall”, which are the ONLY four animation types (in fact, also the only four possible states) of our player. To declare this globally is for better Code Clarity. They are related to different animation thus different sprites, mostly used by animation logics in the player controller.

  

--- Module: fireboy_ROM, icegirl_ROM

Inputs: Clock, Read_Addr, frame_index, anim_type

Output: Data_Out

Each of the two is of the same thing. They are the Sprite ROM for the player1: fireboy and player2: icegirl. They basically did the work that, 1: Load the sprite data into the On-Chip Memory, as a ROM variable in the code; 2: Given the Read_Addr, frame_index, anim_type upper level provided, output the right/matching data stored in the ROM.

To be specific, due to the complexity that our players have many different movements/states (thus different animations for each movement) and the nature of multiple frames of animation, there are actually a lot of ROMs for different player state and different frame in a single animation. So the code actually works out in a way that it FIRST selects a right/matched animation type given anim_type, THEN selects the right spriteROM according to the frame_index given to determine the right one in that specific animation type, FINALLY picks right/matched data given the address/offset in that specific ROM.

The following graph is the block diagram of fireboy module (ice girl is the same):

![](https://lh3.googleusercontent.com/qd3Mo8uIL-bf13m6KGl9TzGI1Ld__zqyYdVyDuoBu0TLH-BxMcThDEU78C7W2MgN5vy4-Fy3acvnNL8-b32-ubTxjk53JHgulG9E_M8MSHLydf0r_aCTfWBJXW-YAgGs3cD49bQ)

--- Module: fireboy, icegirl

Inputs: Clock, frame_clk, reset/revive, DrawX, DrawY, Keyboard Interaction (jump, left, right), Elevators Collider, Water Traps Collider,

Outputs: Graphics/Rendering Logics, Player Tight-Bounded Pos (player’s left, right, top, bottom coordinates), player winning boolean/flag

These two modules are the controller for the player 1: fireboy and player 2: icegirl, respectively. They are mostly the same except for some parameters can not be found common.

The first part of this module is in-module parameter region, where we declare and define/give value to some constant parameters that are used in the scope of the module. Things like, player’s sprites parameter, the width, height, of it; the start (revive/reset point) and end (winning) position of the player; Parameters for the player’s movement and physical/gravity system; the divider for frame_clk (found 60 Hz too fast at some point), etc.

The second part of this module is Declaration of all inner variables.

The third part is a always_ff @ (posedge Clk) procedure block which synchronizes all latch variable to the clock and to its input.

The fourth part is where most logics happen and get calculated. It’s a big always_comb procedure block together with another small always_comb procedure block and some instantiation and assignment clause. The logics in it can be categorized into 3:

1.  Player Movement: For the player movement, we set our base on the lab8’s bouncing ball control. There are four key variables (latches) regulating player’s movement: (take fireboy as our example:) fireboy_X_Pos, fireboy_Y_Pos, fireboy_X_Motion, fireboy_Y_Motion. And they all have their input variables (next to update) with a suffix of “_in”.
    

First and foremost, all the player movement latches are only updated every frame_clk cycle since we want to maintain a 60HZ game, which is a very standard and enough refreshing rate for our game.

For the horizontal motion, i.e. motions in +x or -x direction. We simply check keyboard pressing state (fireboy_left, fireboy_right) and then update the fireboy_X_motion_in accordingly, so that in the next clock cycle (before next frame clock) the position of the player will be updated accordingly.

For the vertical motion, it’s a bit more complicated. In order to make our game looks more real. We implement the physical (gravity) system, which together with the collider, creating an effect of falling and colliding just like in the real world. More importantly, we design a free falling pattern for our jump and falling, which set an initial speed (Impulse Force) to our character when it starts to jump, then make it be dragged by gravity constantly so that the player will jump pretty exactly follow the movement pattern of classical free falling (a parabola). The implementation of this part is, 1, drag the player by gravity every frame_clk/gravity_divider clock cycle; 2, enable/disable jump ability based on whether the player is in the air; 3, detect keyboard press and give player impulse force is applicable. One more thing to address is that the gravity part is tricky because the actual resolution of our game is relatively low (VGA ia an old standard..), the most appropriate value of gravity would be 0.25/frame for our game. However, fpga don’t have a synthesizable floating point type. Thus, we come up with a solution that making a new clock: gravity_counter, and it’s parameterized by gravity_frame_rate_divider. So that we can set the gravity to be one and gravity_counter to be ¼ of the original frame_clk, which will give us a 0.25 gravity.

  

2.  Player Collision with different objects: Right before collision reset (for not get into colliding object) of the player. We will update player_Pos_in according to the calculated motion at this moment. Then we do Collision Detection. So our approach is to set up a bounding box for the player in the collider, and then whenever the transition from previous position to the new, to-be-updated pos_in is prohibited by this collider, no matter to which game object it comes from (could be either floor or elevator), we will force the player not get out of that bound and thus set the pos_in to be at the bound. Therefore we make a collision effect, where, when setting up bounding box correctly, players will act like they could never pass through the objects’ border.
    

  

3.  Player Graphics / Rendering: First of all, we’ll instantiate a player sprite ROM, which is introduced in the previous section. For the regular part of rendering, we need to configure the Read_Addr for the sprite, and as for the ColorMapper (middle man between VGA and fpga inner rendering logics) to know whether to use the data retrieved, we have to determine and output a boolean variable, is_fireboy (as for fireboy module). The way we calculated is_fireboy and the read_addr is through first calculated the x, y offset between DrawX, DrawY and current position of the player, if the offset is within the range of the size of the player sprite, then we could say is_fireboy is true, that is, we are going to draw the pixels for the current fireboy. Then the read_addr can also be easily work out given offset. Moreover, we haven’t handled the animation yet. For animation part of the sprite rendering, we simply follow the rule of switching animation according to latest player motion (motion_in) and switching from the different frames in an animation through a lowered clk: frame_counter, which is of frequency frame_clk/frame_size, this is intentionally reduced because our animation is cut, 24HZ animation rather than a more framed 60HZ one.
    

To this point, all features and functionalities of our player controller is introduced and explained.

  

### Multiple Keycodes USB Keyboard & Keycode wrapper: software/usb_kb/main.c, KeycodeMapper.sv

--- C file: software/usb_kb/main.c:

We support multiple keycodes/presses in our game (since it’s a dual player game), we support up to 4 different keyboard presses at the same time (since there would be at most two presses for each player (jump & move)). We accomplish the goal by extending the keycode parsing/reading process by three more bytes. (one more usb_read since the OTG_DATA bus is 16-bit width, which means two consecutive data bytes read at one time) Further, we prioritize the keycode by their pressing time, the first pressed key has the highest priority, which further means, for example, in the case of both “A” and “D” is pressed, only the one first pressed will be effective. This is done through sorting the keycodes by priority then fill in a mask (which later treated as keycode and transmitted to the fpga) by priority.

  

--- Module: KeycodeMapper

input logic [7:0] keycode,

output logic fireboy_jump, fireboy_left, fireboy_right,

output logic icegirl_jump, icegirl_left, icegirl_right,

output logic confirm

This module acts as a wrapper function or like a tristate, interface between game logics and fpga-nios ii data transmission. It basically interpreted the keycode (actually a bit mask) transmitted from nios ii which further read from HPI ports of OTG chip, to the more game logic friendly, readable boolean/flag which later transmitted to the player controller and game controller respectively. The name is pretty self-explanatory, while the confirm is for enter/space key detection when player wants to restart the game whenever it’s passed or failed.

  

The following graph is the block diagram of Keycode Mapper:

![](https://lh3.googleusercontent.com/27-RIUAVIUC-pWcDI8eCLK6KTcaU793V1FQdlIb6pJMhx10Q1jhNGQQxwOghz6CsYCSJh0NXIxAjs0jVdZa32QqI_zR0X-dFKKB7E7X1H9tUE4WpV86DPTRa7opaacZ_8Qy-xww)

  

### Game Score, Font and Gems: ScoreController.sv

--- Module: gemROM

This is the sprite ROM for gems, which are interactive, collectable game objects. This is a one-state, one-frame static sprite. Given a read address, output a data pixel at the right/matched address.

  

--- Module: Gem

input Clk, Reset,

input [9:0] DrawX, DrawY,

input shortint gem_X_Pos, gem_Y_Pos,

input shortint player1_top, player1_bottom, player1_left, player1_right,

input shortint player2_top, player2_bottom, player2_left, player2_right,

output dead, is_gem,

output logic [8:0] gem_read_addr

Gems are user-interactive, collectable game objects. This is a recyclable, templated module for a gem object, it produces the graphics information (is_gem, gem_read_addr) and maintain the state of the gem (dead). The interaction between gem and player happens through the way of one-directional collision detection (from gem’s end) in which utilizes the inputs player1_top, player1_bottom, player1_left, player1_right, player2_… as well as the gem’s own position to determine the collision. Once the collision is detected, the state of gem (dead) will be changed permanently. (no going back for gems) and we output that state as well as other graphical information to the upper level (ScoreController) due to the hierarchical design.

  

--- Module: Font_ROM

This is the ASCII coded characters FONT ROM in a preloaded 8*16 pixel format. The read_addr of this ROM is of 11-bit width where the first 7 bits is the ASCII code of the desired character and the latter 4 bits is the row index of the character font. (Note it has 16 rows, so 4 bits to represent each row) The returned/outputted data is the whole row of 8-bit data, which should be further addressed to get the actual code for a specific address/pixel location on screen.

  

--- Module: ScoreController

input Clk, Reset,

input [9:0] DrawX, DrawY,

input shortint player1_top, player1_bottom, player1_left, player1_right,

input shortint player2_top, player2_bottom, player2_left, player2_right,

output logic is_score, is_gem,

output logic [7:0] score_data, gem_data,

output logic [3:0] score_hex

This is the top level module of the whole Score, Font, and Gem sub-system. In this module, we assigned the position of each children gems and instantiate them and keep them and all their outputs in a list, then to determine the final is_gem and gem_data, assuming we don’t have overlapping gems (which actually have no reason to do that), then at most one gem is rendered/drawn at a time. So that we simply sort it out and provide it to the ColorMapper. For the score, we just keep track of the total number of gems being collected/dead, and display the score by first finding out the correct ASCII code of the number we are going to display, then read out its data and calculated the offset of it with the score display region to gives out the final data of the font to the ColorMapper. Moreover, since the effect of the score is not very good with the original resolution, 8x16, too small! We figure out a way to scale the font, so we simply put one more layer right before output the actual font data. First, we assume the font to be one time larger, then we enter an additional Scaling Layer that rescaled the offset between DrawX, DrawY and font display position to the normal 8*16 size, thus making a scaling effect. (In short, every k neighbor pixels share on same pixel on original resolution.)

The following graph is the jumping of fire boy and collecting of two Gems:

![](https://lh4.googleusercontent.com/OkGtTHdZPSdDtQRhSqZ8ovZeYTBQVCQlnNu1LSXhNDUdWHjAv-Ubb8UtCVhA4S3L3jc2DfWhEWdQRq2-T900Fx5V_Uc32F0-66aP1_MNLx4Pf6-jkm4ub1tE2nTKjGhaAvEOGts)

The following graph is the block diagram of Score Controller module:

![](https://lh5.googleusercontent.com/PWrJMqtKhyxiW1894o9v5yDTOd0G8aTnPhCSLkD-qEhxEaZMUxaDtgjdOCtj9W_khYsRV59AgW_EpkNpwl9DKdObs5mefhuPS-GjonMjIPome3YOlp7NZwLGwF8ktsbL4WtbVPU)

  
  
  
  

### More Complicated Mechs And Game Objects: ElevatorController.sv

--- Module: switchRom

This is a simple sprite ROM for an interactive game object --- switch. This is a one-state, one-frame static sprite. Given a read address, it should output a data pixel at the right/matched address.

  

--- Module: Elevator_Switch

input Clk, Reset,

input [9:0] DrawX, DrawY,

input shortint switch_X_Pos, switch_Y_Pos,

input shortint player1_top, player1_bottom, player1_left, player1_right,

input shortint player2_top, player2_bottom, player2_left, player2_right,

output state,

output is_switch,

output logic [8:0] switch_read_addr

Switch is an interactive game object. Specifically, switches are always linked with an elevator, which we will discuss later. Every switch will maintain a state, using a boolean variable state to represent, 0 for the switch not being pressed and 1 for the switch is being pressed. The state of the switch will determine the movement and behavior of the linked elevator objects. The switch will use the same way gems address the collision: The interaction between switch and player happens through the way of one-directional collision detection (from switch’s end) in which utilizes the inputs player1_top, player1_bottom, player1_left, player1_right, player2_… as well as the switch’s own position to determine the collision. Once the collision is detected, the state of switch will be changed to 1 (pressed). And whenever the player is not colliding with the switch, the state will always be 0 (not pressed) and we output that state as well as other graphical information to the upper level (Elevator) due to the hierarchical design.

  
  
  

--- Module: Elevator_ROM

This is a simple sprite ROM for a complicated mech game object --- elevator. This is a two-state, one-frame static sprite. Apart from a given read address, it also takes in a one-bit state variable (on), which determine the filled palette of the centre of the elevator, it should output a data pixel at the right/matched address with the right offset about the state.

  

--- Module: Elevator

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

  

This is probably the most complicated part of code in the whole project. It takes huge amount of variable inputs, mostly for templated position and property set up, for not only itself, but also its children elements. This module will take in the setup and all needed information for inner logics as input and output the rendering information about itself (elevator) and its children components (switches) as well as the elevator collider to the upper/higher level of the elevator-switch-group system. To explain the module in more detail, we would like to separate it into two parts:

1.  Children Switches Logics: This module will instantiate a group of children switches object that linked to itself, and collecting the rendering/graphical information it feedbacks as well as instantiate a Switch_ROM to finally produce the render data.
    
2.  Elevator Logics: This part of this module will calculate and produce the elevator rendering information as well as the collider to the higher level.
    

  

--- Module: ElevatorController

The following graph is the block diagram of Elevator module:

![](https://lh4.googleusercontent.com/-CNyXjHsOiYXPCzkA7lFZmiezPexJzdbD9kAPMUrYXOmgTcASJ71lmJUsYMeNHeS7RbZu8I9mJQIGdluXCEQJJjA4tVvDrDBt_oU1PQBLTF_44BfETejF1Eo4VRERa_NT1CXHSs)

  
  
  

### Game Controller: GameController.sv

input Clk, Reset,

input logic gameover, gamewin,

input logic confirm,

output logic revive,

input AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,

output logic AUD_DACDAT, AUD_XCK, I2C_SCLK, I2C_SDAT,

input logic jump

The game controller module is responsible for the state machines of the game. State StartMenu initializes the audio interface module. When the audio interface status is confirmed, the game will start. If either player is dead due to the water traps, state GameOver is reached. If both of the players arrive at the two doors, state GameWin is reached. The confirm signal is connected to the keyboard so that the user can restart a game by pressing ENTER. After the confirm signal is sent, state StartMenu is reached and the revive signal will be sent to Player Controller so that the players will return to the original start positions and live again. On the other hand, the audio interface module is called and the audio file is read.

The following graph is the block diagram of Game Controller module:

![](https://lh3.googleusercontent.com/XeNHLZ4vUaXXGjpuLKe_nTYNMFdWpHgdUm9NnIfTnOh1Go3SmVUFrjyOEk8b28HqQJJoMLbrApjiOs5wfLNbM_cxSOzTIdrCn8lUlWl96oBtlEJAzDVqB5udwlKgKvUq1xcS1Sg)

  

This is the state machine for Game Controller module: ![](https://lh6.googleusercontent.com/ZYzBuzf-Qajr2hPYLq8FLMebPuwO2S2TfBgzqKDc-Mrmd2o2RXID-sBszNyfP4UVr0VuMYjRoKIdG8rOtGEwV9SjlMB_yl2Ov49lkADfXeK9wdrobJMpSZ28YNlHuX3WANXXoEI)

  

Color Mapper: Color_Mapper.sv

input logic is_fireboy, is_icegirl, is_score, is_gem, is_elevator, is_switch,

input logic [7:0] bg_data, fireboy_data, icegirl_data, score_data, gem_data, elevator_data, switch_data,

input [9:0] DrawX, DrawY,

output logic [7:0] VGA_R, VGA_G, VGA_B

This is the color mapper utility file for our game, which decides the exact VGA output color for each pixel. In order to save space, we selected the most prominent colors in any image and created a palette for it. In total, we make use of 69 different colors for all the game elements and characters. The 24 bit palette value is composed of three 8 bit colors (Red [23:16], Green [15:8], Blue [7:0]). The always_comb condition decides the VGA output so that the right color is displayed on right time. When the input logic for the specific game object is raised, the corresponding colors from the palette are read and sent to Red (VGA_R), Green (VGA_G), and Blue (VGA_B).

The following graph is the block diagram of Color Mapper module:

![](https://lh4.googleusercontent.com/9MJoFr7z4ddpgT31cJs2Ufg9Gh_aKbsyWIP6Wpf7c-Pf7GzlUcfTQ4S_p4mwZIaieKIhOOGbIbCpk2ttVwNpAlFkSPiooCO0DZ5hTEncGEHG3YWvr8S0ZZJIII_ANs0fPGza5AA)

### Collision
Module: Collider.sv

input shortint player_X_Pos, player_Y_Pos,

output shortint player_X_Min, player_X_Max, player_Y_Min, player_Y_Max

At the beginning of the collision detection design proposal, we considered using pixel differences or the black line between wall and space to realize the restriction. However, we found out that the delay due to clock is inevitable, which leads to the characters stuck in the walls. Nonetheless, if the clock is removed, the compilation time will explode to more than an hour. Instead, we choose to hard-code the boundaries and restrictions meticulously. Luckily, the time-consuming process results in a decent effect. The statistics are so precise that the players can stop right at the boundaries. The player movement on the slopes are realized by differentiate the slope into several pieces in order to better display the slider effect from the slope. The input player_X_Pos and player_Y_Pos indicate the top left corner of the character, which is compared to the statistics of all the boundary conditions to detect collision. We apply binary search method when we calculate the movement space. The map is divided into plenty of small pieces for boundary analysis, which are constrained by contemporary map requirements. The output signals player_X_Min, player_X_Max constrain the horizontal movement of the two characters; the output signals player_Y_Min, player_Y_Max constrain the vertical movement of the two characters.

  

### Background: bgController.sv

--- Module: bgController.sv

input Clk, input [9:0] DrawX, DrawY,

output logic [7:0] bg_data

The background controller is responsible for reading in the pixels of 640 * 480 map sprite line by line according to the formula:

bg_read_addr = DrawX%bg_wall_width + (DrawY%bg_wall_height)*bg_wall_width;

  

--- Module: bgROM.sv

input [18:0] bg_read_addr, input Clk,

output logic [7:0] bg_data_out

The background reader module is responsible for reading in the massive 640 * 480 map sprite. The original data contains [0:307199] of [7:0] Hex. The output is sent line by line by [7:0] bg_data_out according to the [18:0] bg_read_addr.

  

### Water Traps: Water.sv

--- Module: WaterController.sv

input Clk, Reset, input [9:0] DrawX, DrawY,

input shortint player1_top, player1_bottom, player1_left, player1_right,

input shortint player2_top, player2_bottom, player2_left, player2_right,

output player1_dead, player2_dead

The water controller class parameterized the poisonous water traps. In this way, if we would like to make more water traps in other game levels or game scenes, we can directly call this module. The number of water traps will be generated according to the parameter water_count. The positions of water traps are based on parameter shortint water_pos_x, water_pos_y. The types of water traps are based on parameter logic [2:0] water_types. After that, the water traps collison module is called and those parameters are sent in.

The following graph is the block diagram of Water module:

![](https://lh5.googleusercontent.com/1BMS5CqF9rAHxI7V5LnjbyWaw-8uEWnUQDYqeYBjVmmoc-fUv0FZOygvyDtxDahi9zTrk5w2atTaaWKDVpCKMtQBigSN1jibHtyN-K3zWiTxsO-iXNNjkRLe1ZBtKg8tPpMi2CY)

  

--- Module: Water.sv

input Clk, Reset, input [9:0] DrawX, DrawY, input [2:0] water_type,

input shortint water_X_Pos, water_Y_Pos,

input shortint player1_top, player1_bottom, player1_left, player1_right,

input shortint player2_top, player2_bottom, player2_left, player2_right,

output player1_dead, player2_dead

This module is used to detect whether the player is in contact with the correct water. If the red player falls into the blue water, the blue player falls into the red water, or either of the player falls into the green (poisonous) water, the player dies and the game loses. The output is based on whether the players’ positions are in contact with the boundaries of water positions and decided by the corresponding water types.

  

### Audio: audio_interface.vhd

LDATA, RDATA : IN std_logic_vector(15 downto 0); -- parallel external data inputs

clk, Reset, INIT : IN std_logic;

INIT_FINISH : OUT std_logic;

adc_full : OUT std_logic;

data_over : OUT std_logic; -- sample sync pulse

AUD_MCLK : OUT std_logic; -- Codec master clock OUTPUT

AUD_BCLK : IN std_logic; -- Digital Audio bit clock

AUD_ADCDAT : IN std_logic;

AUD_DACDAT : OUT std_logic; -- DAC data line

AUD_DACLRCK, AUD_ADCLRCK : IN std_logic; -- DAC data left/right select

I2C_SDAT : OUT std_logic; -- serial interface data line

I2C_SCLK : OUT std_logic; -- serial interface clock

ADCDATA : OUT std_logic_vector(31 downto 0)

The audio interface module is provided on ECE 385 website. In order to make use of this module correctly, we looked up the datasheet for the WM8731 Audio CODEC chip present on the DE2 board as well as the WAV format definition. We compared many WAV files and discovered that the first 158 bytes of Hex number in a common WAV file indicates the size of file, mono/stereo flag, sample rate (bytes/second), sample frequency, and number of bits per sample. We converted our .mp3 audio files into WAV files using the 48 KHz sampling rate and 16 bit resolution and set the corresponding setup registers in the audio_interface module to the same values. Since the audio data fetch frequency is modified to work with the 50MHz global clock, the pitch of the original audio required to be raised so that the output sound is optimal. Since the audio interface requires initialization, the INIT and INIT_FINISH signals are added to the game controller state machine. As the INIT_FINISH is raised, our music Hex data is feed into the LDATA and RDATA. The .qsf file is updated so that the WM8731 Audio CODEC chip can be connected.

This is the state machine for audio interface module:

![](https://lh5.googleusercontent.com/mxxs1cWDJBKdkZ8jhJqvPsH_auX3cXq8GwaaIxDUK80IX4WAWpWZneY1066OrVD8Tsywi84XdDEsdjR-l9G5LvMoW8FZsT6Hb_6Toc0Yj9mlAjYZBHtlZpFMkcPLLGOxGgpZv7s)

Module: Hexdriver.sv

Inputs: [3:0] In0

Outputs: [6:0] Out0

This is the driver for 7-segment Hex LED display on board. Basically takes in a 1-bit Hex and output the exact 7-bit data pattern for that Hex.

  

## Design Resources and Statistics Table

|Resource|Usage|
|--|--|
| LUT | 12156 |
| DSP  | 0  |
| Memory (BRAM)  | 3096576  |
| Flip-Flop  | 2567  |
| Frequency  | 140.37 MHz  |
| Static Power  | 105.82 mW  |
| Dynamic Power  | 0.79 mW  |
| Total Power  | 173.90 mW  |


## Authors

* **Bernard Lyu** - [BreezeLv](https://github.com/BreezeLv)
* **Albert Wang** - [Albert](https://github.com/albert9904)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
